//
//  NowPlayingService.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import Foundation
import Combine
import AppKit

/// Service to get currently playing song from macOS
/// Uses AppleScript to query Music and Spotify apps
@MainActor
class NowPlayingService: ObservableObject {
    static let shared = NowPlayingService()
    
    @Published private(set) var currentSong: Song?
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var playbackPosition: TimeInterval = 0
    @Published private(set) var activePlayer: String?
    
    private var monitoringTask: Task<Void, Never>?
    private var positionTask: Task<Void, Never>?
    private var lastKnownPosition: TimeInterval = 0
    private var lastPositionUpdate: Date = Date()
    
    private init() {
        startMonitoring()
    }
    
    // MARK: - Monitoring
    
    func startMonitoring() {
        stopMonitoring()
        
        print("🎧 Starting now playing monitoring...")
        
        // Poll for now playing info every 2 seconds
        monitoringTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.updateNowPlaying()
                try? await Task.sleep(for: .seconds(2))
            }
        }
        
        // Update position more frequently for synced lyrics
        positionTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.updatePosition()
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }
    
    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
        positionTask?.cancel()
        positionTask = nil
    }
    
    /// Force refresh now playing info
    func refresh() {
        Task {
            await updateNowPlaying()
        }
    }
    
    // MARK: - Playback Controls
    
    func playPause() {
        guard let player = activePlayer else { return }
        let script = "tell application \"\(player)\" to playpause"
        Task { await runAppleScript(script) }
    }
    
    func nextTrack() {
        guard let player = activePlayer else { return }
        let script = "tell application \"\(player)\" to next track"
        Task { await runAppleScript(script) }
    }
    
    func previousTrack() {
        guard let player = activePlayer else { return }
        let script = "tell application \"\(player)\" to previous track"
        Task { await runAppleScript(script) }
    }

    func seekForward(seconds: Double = 10) {
        guard let player = activePlayer else { return }
        let script: String
        if player == "Spotify" {
            script = """
            tell application "Spotify"
                set newPos to (player position) + \(seconds)
                set player position to newPos
            end tell
            """
        } else {
            script = """
            tell application "Music"
                set newPos to (player position) + \(seconds)
                set player position to newPos
            end tell
            """
        }
        Task { await runAppleScript(script) }
    }

    func seekBackward(seconds: Double = 10) {
        guard let player = activePlayer else { return }
        let script: String
        if player == "Spotify" {
            script = """
            tell application "Spotify"
                set newPos to (player position) - \(seconds)
                if newPos < 0 then set newPos to 0
                set player position to newPos
            end tell
            """
        } else {
            script = """
            tell application "Music"
                set newPos to (player position) - \(seconds)
                if newPos < 0 then set newPos to 0
                set player position to newPos
            end tell
            """
        }
        Task { await runAppleScript(script) }
    }

    func openPlayerApp() {
        guard let player = activePlayer else { return }
        let script = "tell application \"\(player)\" to activate"
        Task { await runAppleScript(script) }
    }
    
    // MARK: - Now Playing Updates
    
    private func updateNowPlaying() async {
        // Try Spotify first (more common), then Music
        if let result = await fetchFromSpotify() {
            applyResult(result, player: "Spotify")
            return
        }
        
        if let result = await fetchFromMusicApp() {
            applyResult(result, player: "Music")
            return
        }
        
        // Nothing playing
        if currentSong != nil {
            print("⏹️ Playback stopped")
            currentSong = nil
            isPlaying = false
            activePlayer = nil
        }
    }
    
    private func applyResult(_ result: (Song, TimeInterval, Bool), player: String) {
        let (song, position, playing) = result
        
        // If it's a new song, try to get artwork
        if currentSong?.title != song.title || currentSong?.artist != song.artist {
            let songTitle = song.title
            let songArtist = song.artist
            
            Task {
                var songWithArtwork = song
                
                if player == "Music" {
                    if let artwork = await fetchArtworkFromMusic() {
                        songWithArtwork = Song(title: song.title, artist: song.artist, album: song.album, duration: song.duration, artwork: artwork)
                    }
                } else if player == "Spotify" {
                    if let artworkUrl = await fetchSpotifyArtworkUrl(), let url = URL(string: artworkUrl) {
                        do {
                            let (data, _) = try await URLSession.shared.data(from: url)
                            if let artwork = NSImage(data: data) {
                                songWithArtwork = Song(title: song.title, artist: song.artist, album: song.album, duration: song.duration, artwork: artwork)
                            }
                        } catch {
                            print("⚠️ Failed to download Spotify artwork: \(error)")
                        }
                    }
                }
                
                // Verify we're still on the same song before applying
                await MainActor.run {
                    // Re-check current tracking to avoid race conditions from fast skipping
                    if let latest = self.currentSong, latest.title == songTitle && latest.artist == songArtist {
                        // Keep current artwork if we failed to fetch new one but titles match? 
                        // No, just apply what we have.
                        self.currentSong = songWithArtwork
                    } else if self.currentSong == nil {
                        // First song ever
                        self.currentSong = songWithArtwork
                    } else if currentSong?.title != song.title || currentSong?.artist != song.artist {
                        // If it's a new song but we haven't updated yet
                        self.currentSong = songWithArtwork
                    }
                }
            }
        }
        
        isPlaying = playing
        activePlayer = player
        lastKnownPosition = position
        lastPositionUpdate = Date()
        playbackPosition = position
    }
    
    private func fetchSpotifyArtworkUrl() async -> String? {
        let script = "tell application \"Spotify\" to return artwork url of current track"
        return await runAppleScript(script)
    }
    
    private func fetchArtworkFromMusic() async -> NSImage? {
        let script = """
        tell application "Music"
            try
                if exists (artwork 1 of current track) then
                    return data of artwork 1 of current track
                end if
            on error
                return ""
            end try
            return ""
        end tell
        """
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var error: NSDictionary?
                guard let scriptObj = NSAppleScript(source: script) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let descriptor = scriptObj.executeAndReturnError(&error)
                
                let data = descriptor.data
                if !data.isEmpty, let image = NSImage(data: data) {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    private func updatePosition() {
        guard isPlaying else { return }
        
        // Interpolate position between updates
        let elapsed = Date().timeIntervalSince(lastPositionUpdate)
        playbackPosition = lastKnownPosition + elapsed
    }
    
    // MARK: - Music.app
    
    private func fetchFromMusicApp() async -> (Song, TimeInterval, Bool)? {
        let script = """
        tell application "System Events"
            if not (exists process "Music") then return "NOT_RUNNING"
        end tell
        
        tell application "Music"
            if player state is stopped then return "STOPPED"
            
            set isPlaying to (player state is playing)
            set trackName to name of current track
            set trackArtist to artist of current track
            set trackAlbum to album of current track
            set trackDuration to duration of current track
            set trackPosition to player position
            
            return trackName & "||" & trackArtist & "||" & trackAlbum & "||" & trackDuration & "||" & trackPosition & "||" & isPlaying
        end tell
        """
        
        guard let output = await runAppleScript(script), 
              output != "NOT_RUNNING", 
              output != "STOPPED" else {
            return nil
        }
        
        return parseOutput(output)
    }
    
    // MARK: - Spotify
    
    private func fetchFromSpotify() async -> (Song, TimeInterval, Bool)? {
        let script = """
        tell application "System Events"
            if not (exists process "Spotify") then return "NOT_RUNNING"
        end tell
        
        tell application "Spotify"
            if player state is stopped then return "STOPPED"
            
            set isPlaying to (player state is playing)
            set trackName to name of current track
            set trackArtist to artist of current track
            set trackAlbum to album of current track
            set trackDuration to (duration of current track) / 1000
            set trackPosition to player position
            
            return trackName & "||" & trackArtist & "||" & trackAlbum & "||" & trackDuration & "||" & trackPosition & "||" & isPlaying
        end tell
        """
        
        guard let output = await runAppleScript(script),
              output != "NOT_RUNNING",
              output != "STOPPED" else {
            return nil
        }
        
        return parseOutput(output)
    }
    
    // MARK: - Helpers
    
    private func parseOutput(_ output: String) -> (Song, TimeInterval, Bool)? {
        let parts = output.components(separatedBy: "||")
        guard parts.count >= 6 else {
            print("⚠️ Invalid output format: \(output)")
            return nil
        }
        
        let title = parts[0]
        let artist = parts[1]
        let album = parts[2]
        let duration = Double(parts[3])
        let position = Double(parts[4]) ?? 0
        let playing = parts[5] == "true"
        
        let song = Song(title: title, artist: artist, album: album.isEmpty ? nil : album, duration: duration)
        return (song, position, playing)
    }
    
    private func runAppleScript(_ source: String) async -> String? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var error: NSDictionary?
                let script = NSAppleScript(source: source)
                let result = script?.executeAndReturnError(&error)
                
                if let errorDict = error {
                    let errorNum = errorDict["NSAppleScriptErrorNumber"] as? Int ?? -1
                    // -1728 = "can't get" (app not running properly)
                    // -600 = "application isn't running"
                    if errorNum != -1728 && errorNum != -600 {
                        print("⚠️ AppleScript error: \(errorDict["NSAppleScriptErrorMessage"] ?? errorDict)")
                    }
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: result?.stringValue)
            }
        }
    }
}
