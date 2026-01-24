//
//  Lyrics.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import Foundation

/// Represents a single line of lyrics with optional timestamp
struct LyricLine: Identifiable, Equatable, Hashable {
    let id = UUID()
    let timestamp: TimeInterval?
    let text: String
    
    var isSynced: Bool {
        timestamp != nil
    }
    
    /// Format timestamp as [mm:ss.xx]
    var formattedTimestamp: String? {
        guard let ts = timestamp else { return nil }
        let minutes = Int(ts) / 60
        let seconds = ts.truncatingRemainder(dividingBy: 60)
        return String(format: "[%02d:%05.2f]", minutes, seconds)
    }
}

/// Represents complete lyrics for a song
struct Lyrics: Equatable {
    let lines: [LyricLine]
    let source: LyricSource
    let isSynced: Bool
    
    /// Plain text representation of lyrics
    var plainText: String {
        lines.map { $0.text }.joined(separator: "\n")
    }
    
    /// Get the current line index for a given playback time
    func currentLineIndex(for time: TimeInterval) -> Int? {
        guard isSynced else { return nil }
        
        var lastIndex: Int? = nil
        for (index, line) in lines.enumerated() {
            guard let timestamp = line.timestamp else { continue }
            if timestamp <= time {
                lastIndex = index
            } else {
                break
            }
        }
        return lastIndex
    }
    
    /// Get the current line for a given playback time
    func currentLine(for time: TimeInterval) -> LyricLine? {
        guard let index = currentLineIndex(for: time) else { return nil }
        return lines[index]
    }
}

/// Source of lyrics
enum LyricSource: String, Equatable, Codable {
    case lrclib = "LRCLib"
    case genius = "Genius"
    case musixmatch = "Musixmatch"
    case megalobiz = "Megalobiz"
    case unknown = "Unknown"
}

/// Result from a lyrics search
struct LyricsSearchResult: Equatable {
    let lyrics: Lyrics?
    let error: LyricsError?
    
    static func success(_ lyrics: Lyrics) -> LyricsSearchResult {
        LyricsSearchResult(lyrics: lyrics, error: nil)
    }
    
    static func failure(_ error: LyricsError) -> LyricsSearchResult {
        LyricsSearchResult(lyrics: nil, error: error)
    }
}

/// Errors that can occur during lyrics fetching
enum LyricsError: Error, Equatable, LocalizedError {
    case notFound
    case networkError(String)
    case parsingError(String)
    case invalidResponse
    case noProviderAvailable
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Lyrics not found"
        case .networkError(let message):
            return "Network error: \(message)"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .noProviderAvailable:
            return "No lyrics provider available"
        }
    }
}

