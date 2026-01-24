//
//  LRCLibProvider.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import Foundation

/// LRCLib lyrics provider
/// API documentation: https://lrclib.net/docs
@MainActor
struct LRCLibProvider: LyricProvider {
    let name = "LRCLib"
    let source = LyricSource.lrclib
    let priority = 1 // Highest priority for synced lyrics
    let supportsSyncedLyrics = true
    
    private let baseURL = "https://lrclib.net/api"
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }
    
    func fetchLyrics(for song: Song) async -> LyricsSearchResult {
        let allLyrics = await fetchAllLyrics(for: song)
        // Prefer synced
        if let synced = allLyrics.first(where: { $0.isSynced }) {
            return .success(synced)
        }
        if let first = allLyrics.first {
            return .success(first)
        }
        return .failure(.notFound)
    }
    
    func fetchAllLyrics(for song: Song) async -> [Lyrics] {
        // First try the direct get endpoint for exact match
        if let response = await fetchDirectResponse(song: song) {
            return createAllLyrics(from: response)
        }
        
        // Fall back to search endpoint
        return await fetchViaSearchAll(song: song)
    }
    
    /// Try to get lyrics via direct GET endpoint (requires exact match)
    private func fetchDirectResponse(song: Song) async -> LRCLibResponse? {
        var components = URLComponents(string: "\(baseURL)/get")
        
        var queryItems = [
            URLQueryItem(name: "track_name", value: song.title),
            URLQueryItem(name: "artist_name", value: song.artist)
        ]
        
        if let album = song.album {
            queryItems.append(URLQueryItem(name: "album_name", value: album))
        }
        
        if let duration = song.duration {
            queryItems.append(URLQueryItem(name: "duration", value: String(Int(duration))))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else { return nil }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("lyrix-app/1.0", forHTTPHeaderField: "User-Agent")
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            
            return try JSONDecoder().decode(LRCLibResponse.self, from: data)
        } catch {
            print("⚠️ LRCLib direct fetch error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Search for lyrics using the search endpoint - returns all matches
    private func fetchViaSearchAll(song: Song) async -> [Lyrics] {
        var components = URLComponents(string: "\(baseURL)/search")
        
        let query = "\(song.title) \(song.artist)"
        components?.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]
        
        guard let url = components?.url else { return [] }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("lyrix-app/1.0", forHTTPHeaderField: "User-Agent")
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return []
            }
            
            let results = try JSONDecoder().decode([LRCLibResponse].self, from: data)
            
            // Find best match
            let bestMatch = results
                .filter { $0.syncedLyrics != nil || $0.plainLyrics != nil }
                .sorted { result1, result2 in
                    let score1 = matchScore(result1, song: song)
                    let score2 = matchScore(result2, song: song)
                    return score1 > score2
                }
                .first
            
            if let match = bestMatch {
                return createAllLyrics(from: match)
            }
            return []
        } catch {
            return []
        }
    }
    
    /// Calculate match score between result and song
    private func matchScore(_ result: LRCLibResponse, song: Song) -> Int {
        var score = 0
        
        if result.trackName.lowercased() == song.title.lowercased() {
            score += 10
        } else if result.trackName.lowercased().contains(song.title.lowercased()) {
            score += 5
        }
        
        if result.artistName.lowercased() == song.artist.lowercased() {
            score += 10
        } else if result.artistName.lowercased().contains(song.artist.lowercased()) {
            score += 5
        }
        
        if let album = song.album, let resultAlbum = result.albumName {
            if resultAlbum.lowercased() == album.lowercased() {
                score += 5
            }
        }
        
        return score
    }
    
    /// Create ALL available Lyrics from API response (both synced and plain)
    private func createAllLyrics(from response: LRCLibResponse) -> [Lyrics] {
        var results: [Lyrics] = []
        
        // Add synced lyrics if available
        if let syncedLyrics = response.syncedLyrics, !syncedLyrics.isEmpty {
            let lines = LRCParser.parse(syncedLyrics)
            if !lines.isEmpty {
                results.append(Lyrics(lines: lines, source: source, isSynced: true))
            }
        }
        
        // Add plain lyrics if available
        if let plainLyrics = response.plainLyrics, !plainLyrics.isEmpty {
            let lines = LRCParser.parsePlainText(plainLyrics)
            if !lines.isEmpty {
                results.append(Lyrics(lines: lines, source: source, isSynced: false))
            }
        }
        
        return results
    }
}

// MARK: - LRCLib API Response Models

struct LRCLibResponse: Codable {
    let id: Int
    let trackName: String
    let artistName: String
    let albumName: String?
    let duration: Double?
    let instrumental: Bool
    let plainLyrics: String?
    let syncedLyrics: String?
}

