//
//  LyricProvider.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import Foundation

/// Protocol for lyrics providers
/// Implement this protocol to add new lyrics sources
@MainActor
protocol LyricProvider {
    /// The name of the provider
    var name: String { get }
    
    /// The source identifier
    var source: LyricSource { get }
    
    /// Priority (lower = higher priority, tried first)
    var priority: Int { get }
    
    /// Whether this provider supports synced lyrics
    var supportsSyncedLyrics: Bool { get }
    
    /// Fetch lyrics for a given song
    /// - Parameter song: The song to fetch lyrics for
    /// - Returns: LyricsSearchResult containing lyrics or error
    func fetchLyrics(for song: Song) async -> LyricsSearchResult
    
    /// Fetch all available lyrics (both synced and plain if available)
    func fetchAllLyrics(for song: Song) async -> [Lyrics]
}

/// Default implementation for fetchAllLyrics
extension LyricProvider {
    func fetchAllLyrics(for song: Song) async -> [Lyrics] {
        let result = await fetchLyrics(for: song)
        if let lyrics = result.lyrics {
            return [lyrics]
        }
        return []
    }
}

/// Result containing all available lyrics options
struct LyricsOptions {
    let options: [Lyrics]
    let defaultIndex: Int
    
    var isEmpty: Bool { options.isEmpty }
    var defaultLyrics: Lyrics? { options.indices.contains(defaultIndex) ? options[defaultIndex] : options.first }
}

/// Manager that coordinates multiple lyrics providers
@MainActor
class LyricsManager {
    static let shared = LyricsManager()
    
    private var providers: [LyricProvider] = []
    private let cache = LyricsCache.shared
    
    private init() {
        // Register default providers (sorted by priority)
        providers = [
            LRCLibProvider()
            // Add more providers here as needed
        ].sorted { $0.priority < $1.priority }
    }
    
    /// Register a new lyrics provider
    func registerProvider(_ provider: LyricProvider) {
        providers.append(provider)
        providers.sort { $0.priority < $1.priority }
    }
    
    /// Fetch lyrics from all providers, returning the first successful result
    /// Prioritizes synced lyrics over plain lyrics
    /// - Parameter song: The song to fetch lyrics for
    /// - Returns: LyricsSearchResult with the best available lyrics
    func fetchLyrics(for song: Song) async -> LyricsSearchResult {
        let options = await fetchAllLyrics(for: song)
        if let defaultLyrics = options.defaultLyrics {
            return .success(defaultLyrics)
        }
        return .failure(.notFound)
    }
    
    /// Fetch ALL available lyrics from all providers
    /// Returns cached results if available, otherwise fetches fresh
    func fetchAllLyrics(for song: Song) async -> LyricsOptions {
        // Check cache first
        if let cached = cache.get(for: song) {
            let lyrics = cached.map { $0.toLyrics() }
            let defaultIndex = findBestIndex(in: lyrics)
            print("💾 Using cached lyrics: \(lyrics.count) options")
            return LyricsOptions(options: lyrics, defaultIndex: defaultIndex)
        }
        
        // Fetch from all providers
        var allLyrics: [Lyrics] = []
        
        for provider in providers {
            let results = await provider.fetchAllLyrics(for: song)
            for lyrics in results {
                // Avoid duplicates
                if !allLyrics.contains(where: { $0.source == lyrics.source && $0.isSynced == lyrics.isSynced }) {
                    allLyrics.append(lyrics)
                }
            }
        }
        
        // Cache results
        if !allLyrics.isEmpty {
            let cached = allLyrics.map { CachedLyricsOption.from($0) }
            cache.save(cached, for: song)
        }
        
        let defaultIndex = findBestIndex(in: allLyrics)
        print("🎵 Fetched \(allLyrics.count) lyrics options")
        return LyricsOptions(options: allLyrics, defaultIndex: defaultIndex)
    }
    
    /// Find best lyrics index (prefer synced)
    private func findBestIndex(in lyrics: [Lyrics]) -> Int {
        // Prefer synced lyrics
        if let index = lyrics.firstIndex(where: { $0.isSynced }) {
            return index
        }
        return 0
    }
    
    /// Clear cache
    func clearCache() async {
        cache.clearAll()
    }
}

