//
//  LyricsCache.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import Foundation

/// Cached lyrics entry
struct CachedLyrics: Codable, Identifiable {
    var id: String { songKey }
    let songKey: String
    let songTitle: String?
    let songArtist: String?
    let lyrics: [CachedLyricsOption]
    let cachedAt: Date

    /// Cache is valid for 7 days
    var isValid: Bool {
        Date().timeIntervalSince(cachedAt) < 7 * 24 * 60 * 60
    }

    /// Display title derived from songKey or stored title
    var displayTitle: String {
        if let title = songTitle, !title.isEmpty { return title }
        // Fallback: decode from songKey (format: "title|artist" percent-encoded)
        let decoded = songKey.removingPercentEncoding ?? songKey
        let parts = decoded.split(separator: "|", maxSplits: 1)
        return parts.first.map(String.init) ?? songKey
    }

    var displayArtist: String {
        if let artist = songArtist, !artist.isEmpty { return artist }
        let decoded = songKey.removingPercentEncoding ?? songKey
        let parts = decoded.split(separator: "|", maxSplits: 1)
        return parts.count > 1 ? String(parts[1]) : ""
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
        let cached = CachedLyrics(songKey: key, songTitle: song.title, songArtist: song.artist, lyrics: options, cachedAt: Date())
        
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

    /// List all cached entries sorted by most recent
    func listAll() -> [CachedLyrics] {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return []
        }

        var entries: [CachedLyrics] = []
        for file in files where file.pathExtension == "json" {
            if let data = try? Data(contentsOf: file),
               let cached = try? JSONDecoder().decode(CachedLyrics.self, from: data),
               cached.isValid {
                entries.append(cached)
            }
        }
        return entries.sorted { $0.cachedAt > $1.cachedAt }
    }

    /// Delete a single cached entry by song key
    func delete(songKey: String) {
        memoryCache.removeValue(forKey: songKey)
        let fileURL = cacheDirectory.appendingPathComponent("\(songKey).json")
        try? FileManager.default.removeItem(at: fileURL)
    }
}

