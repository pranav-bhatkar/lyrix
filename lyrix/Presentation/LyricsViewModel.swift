//
//  LyricsViewModel.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import Foundation
import Combine
import SwiftUI
import AppKit

/// ViewModel for lyrics display and synchronization
@MainActor
class LyricsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var currentSong: Song?
    @Published private(set) var lyrics: Lyrics?
    @Published private(set) var lyricsOptions: [Lyrics] = []
    @Published var selectedLyricsIndex: Int = 0 {
        didSet {
            if lyricsOptions.indices.contains(selectedLyricsIndex) {
                // Wrap in async to avoid "Publishing changes from within view updates" warning
                let newLyrics = lyricsOptions[selectedLyricsIndex]
                DispatchQueue.main.async {
                    self.lyrics = newLyrics
                }
            }
        }
    }
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published private(set) var currentLineIndex: Int?
    @Published private(set) var playbackPosition: TimeInterval = 0
    @Published private(set) var isPlaying = false
    @Published private(set) var activePlayer: String?
    @Published private(set) var isCached = false
    
    // MARK: - Private Properties
    
    private let nowPlayingService = NowPlayingService.shared
    private var cancellables = Set<AnyCancellable>()
    private var lastFetchedSong: Song?
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Observe song changes
        nowPlayingService.$currentSong
            .receive(on: DispatchQueue.main)
            .sink { [weak self] song in
                self?.handleSongChange(song)
            }
            .store(in: &cancellables)
        
        // Observe playback position for synced lyrics
        nowPlayingService.$playbackPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] position in
                self?.updateCurrentLine(for: position)
            }
            .store(in: &cancellables)
        
        // Observe playing state
        nowPlayingService.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playing in
                self?.isPlaying = playing
                self?.updateWidgetData()
            }
            .store(in: &cancellables)
        
        // Observe active player
        nowPlayingService.$activePlayer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] player in
                self?.activePlayer = player
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Song Change Handling

    private func handleSongChange(_ song: Song?) {
        let previousSong = currentSong
        currentSong = song

        guard let song = song else {
            lyrics = nil
            lyricsOptions = []
            error = nil
            currentLineIndex = nil
            isCached = false
            return
        }

        // Only fetch if song actually changed
        if lastFetchedSong != song {
            lastFetchedSong = song

            // Show notification for new song (not on first load)
            if previousSong != nil {
                NotificationManager.shared.showNowPlayingNotification(for: song)
            }

            Task {
                await fetchLyrics(for: song)
            }
        }
    }
    
    // MARK: - Lyrics Fetching
    
    func fetchLyrics(for song: Song) async {
        isLoading = true
        error = nil
        currentLineIndex = nil
        
        print("🔍 Fetching lyrics for: \(song.displayName)")
        
        let options = await LyricsManager.shared.fetchAllLyrics(for: song)
        
        isLoading = false
        
        if !options.isEmpty {
            lyricsOptions = options.options
            selectedLyricsIndex = options.defaultIndex
            lyrics = options.defaultLyrics

            // Check if this was from cache (fast response)
            isCached = LyricsCache.shared.get(for: song) != nil

            print("✅ Loaded \(options.options.count) lyrics options, cached: \(isCached)")
        } else {
            lyricsOptions = []
            lyrics = nil
            error = "Lyrics not found"
            isCached = false
            print("❌ No lyrics found")
        }

        updateWidgetData()
    }
    
    /// Manually trigger lyrics fetch for current song (bypasses cache)
    func refreshLyrics() async {
        guard let song = currentSong else { return }
        
        // Clear cache for this song first
        await LyricsManager.shared.clearCache()
        lastFetchedSong = nil
        
        await fetchLyrics(for: song)
    }
    
    /// Force refresh now playing info
    func refreshNowPlaying() {
        nowPlayingService.refresh()
    }
    
    // MARK: - Playback Controls
    
    func playPause() {
        nowPlayingService.playPause()
    }
    
    func nextTrack() {
        nowPlayingService.nextTrack()
    }
    
    func previousTrack() {
        nowPlayingService.previousTrack()
    }
    
    func openActivePlayer() {
        nowPlayingService.openPlayerApp()
    }
    
    // MARK: - Lyrics Selection
    
    /// Get display name for a lyrics option
    func displayName(for lyrics: Lyrics) -> String {
        let syncLabel = lyrics.isSynced ? "Synced" : "Plain"
        return "\(lyrics.source.rawValue) (\(syncLabel))"
    }
    
    /// Select lyrics by type preference
    func selectSyncedLyrics() {
        if let index = lyricsOptions.firstIndex(where: { $0.isSynced }) {
            selectedLyricsIndex = index
        }
    }
    
    func selectPlainLyrics() {
        if let index = lyricsOptions.firstIndex(where: { !$0.isSynced }) {
            selectedLyricsIndex = index
        }
    }
    
    // MARK: - Synced Lyrics

    private func updateCurrentLine(for position: TimeInterval) {
        playbackPosition = position

        guard let lyrics = lyrics, lyrics.isSynced else {
            currentLineIndex = nil
            return
        }

        let newIndex = lyrics.currentLineIndex(for: position)
        if newIndex != currentLineIndex {
            currentLineIndex = newIndex
            updateWidgetData()
        }
    }

    // MARK: - Widget Data

    private func updateWidgetData() {
        let currentLyric: String?
        if let index = currentLineIndex, let lyrics = lyrics, index < lyrics.lines.count {
            currentLyric = lyrics.lines[index].text
        } else {
            currentLyric = nil
        }
        WidgetDataManager.shared.updateNowPlaying(
            song: currentSong,
            currentLyric: currentLyric,
            isPlaying: isPlaying
        )
    }
    
    // MARK: - Manual Song Entry (for testing)

    func searchLyrics(title: String, artist: String, album: String? = nil) async {
        let song = Song(title: title, artist: artist, album: album)
        currentSong = song
        lastFetchedSong = song
        await fetchLyrics(for: song)
    }

    // MARK: - Report Wrong Lyrics

    /// Opens the lyrics source website so users can report/correct lyrics
    func reportWrongLyrics() {
        guard let song = currentSong else { return }

        // Build search URL for LRCLib
        let query = "\(song.title) \(song.artist)"
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://lrclib.net/search?q=\(encodedQuery)") else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}
