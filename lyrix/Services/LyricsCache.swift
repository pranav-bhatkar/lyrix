//
//  LyricsCache.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import Foundation

/// Cached lyrics entry
struct CachedLyrics: Codable {
    let songKey: String
    let lyrics: [CachedLyricsOption]
    let cachedAt: Date
    
    /// Cache is valid for 7 days
    var isValid: Bool {
        Date().timeIntervalSince(cachedAt) < 7 * 24 * 60 * 60
    }
}

/// A single lyrics option from a provider
struct CachedLyricsOption: Codable, Identifiable, Equatable {
    var id: String { "\(source.rawValue)-\(isSynced ? "synced" : "plain")" }
    let source: LyricSource
    let isSynced: Bool
    let lines: [CachedLyricLine]
    
    func toLyrics() -> Lyrics {
        let lyricLines = lines.map { LyricLine(timestamp: $0.timestamp, text: $0.text) }
        return Lyrics(lines: lyricLines, source: source, isSynced: isSynced)
    }
    
    static func from(_ lyrics: Lyrics) -> CachedLyricsOption {
        CachedLyricsOption(
            source: lyrics.source,
            isSynced: lyrics.isSynced,
            lines: lyrics.lines.map { CachedLyricLine(timestamp: $0.timestamp, text: $0.text) }
        )
    }
}

struct CachedLyricLine: Codable, Equatable {
    let timestamp: TimeInterval?
    let text: String
}

/// File-based lyrics cache
@MainActor
class LyricsCache {
    static let shared = LyricsCache()
    
    private let cacheDirectory: URL
    private var memoryCache: [String: CachedLyrics] = [:]
    
    private init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("LyricsCache", isDirectory: true)
        
        // Create cache directory if needed
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// Generate cache key from song
    private func cacheKey(for song: Song) -> String {
        let normalized = "\(song.title.lowercased())|\(song.artist.lowercased())"
        return normalized.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? normalized
    }
    
    /// Get cached lyrics for a song
    func get(for song: Song) -> [CachedLyricsOption]? {
        let key = cacheKey(for: song)
        
        // Check memory cache first
        if let cached = memoryCache[key], cached.isValid {
            print("💾 Cache hit (memory): \(song.title)")
            return cached.lyrics
        }
        
        // Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let cached = try JSONDecoder().decode(CachedLyrics.self, from: data)
            
            if cached.isValid {
                // Store in memory cache
                memoryCache[key] = cached
                print("💾 Cache hit (disk): \(song.title)")
                return cached.lyrics
            } else {
                // Remove expired cache
                try? FileManager.default.removeItem(at: fileURL)
                return nil
            }
        } catch {
            print("⚠️ Cache read error: \(error)")
            return nil
        }
    }
    
    /// Save lyrics to cache
    func save(_ options: [CachedLyricsOption], for song: Song) {
        let key = cacheKey(for: song)
        let cached = CachedLyrics(songKey: key, lyrics: options, cachedAt: Date())
        
        // Save to memory
        memoryCache[key] = cached
        
        // Save to disk
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        do {
            let data = try JSONEncoder().encode(cached)
            try data.write(to: fileURL)
            print("💾 Cached \(options.count) lyrics options for: \(song.title)")
        } catch {
            print("⚠️ Cache write error: \(error)")
        }
    }
    
    /// Clear all cache
    func clearAll() {
        memoryCache.removeAll()
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        print("🗑️ Cache cleared")
    }
}

