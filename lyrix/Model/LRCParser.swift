//
//  LRCParser.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import Foundation

/// Parser for LRC (Lyric) file format
/// Format: [mm:ss.xx] Lyric text
struct LRCParser {
    
    /// Parse LRC formatted string into array of LyricLines
    /// - Parameter lrcString: The LRC formatted lyrics string
    /// - Returns: Array of LyricLine with timestamps
    static func parse(_ lrcString: String) -> [LyricLine] {
        var lines: [LyricLine] = []
        
        // Regex pattern for [mm:ss.xx] or [mm:ss:xx] format
        let timestampPattern = #"\[(\d{2}):(\d{2})[.:](\d{2,3})\]"#
        let regex = try? NSRegularExpression(pattern: timestampPattern, options: [])
        
        for line in lrcString.components(separatedBy: .newlines) {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            guard !trimmedLine.isEmpty else { continue }
            
            // Skip metadata lines like [ar:Artist], [ti:Title], etc.
            if trimmedLine.hasPrefix("[") && !trimmedLine.contains(":") {
                continue
            }
            
            // Check if it's a metadata line (not a timestamp)
            let metadataPattern = #"^\[[a-zA-Z]+:"#
            if let metadataRegex = try? NSRegularExpression(pattern: metadataPattern),
               metadataRegex.firstMatch(in: trimmedLine, range: NSRange(trimmedLine.startIndex..., in: trimmedLine)) != nil {
                continue
            }
            
            // Find all timestamps in the line (some LRC files have multiple timestamps per line)
            guard let regex = regex else { continue }
            let matches = regex.matches(in: trimmedLine, range: NSRange(trimmedLine.startIndex..., in: trimmedLine))
            
            if matches.isEmpty {
                // No timestamp, add as plain text
                if !trimmedLine.isEmpty {
                    lines.append(LyricLine(timestamp: nil, text: trimmedLine))
                }
                continue
            }
            
            // Extract the text part (after all timestamps)
            var textStartIndex = trimmedLine.startIndex
            if let lastMatch = matches.last {
                let range = Range(lastMatch.range, in: trimmedLine)!
                textStartIndex = range.upperBound
            }
            let text = String(trimmedLine[textStartIndex...]).trimmingCharacters(in: .whitespaces)
            
            // Create a line for each timestamp
            for match in matches {
                if let minuteRange = Range(match.range(at: 1), in: trimmedLine),
                   let secondRange = Range(match.range(at: 2), in: trimmedLine),
                   let msRange = Range(match.range(at: 3), in: trimmedLine) {
                    
                    let minutes = Double(trimmedLine[minuteRange]) ?? 0
                    let seconds = Double(trimmedLine[secondRange]) ?? 0
                    let msString = String(trimmedLine[msRange])
                    
                    // Handle both .xx and .xxx formats
                    let milliseconds: Double
                    if msString.count == 2 {
                        milliseconds = (Double(msString) ?? 0) / 100.0
                    } else {
                        milliseconds = (Double(msString) ?? 0) / 1000.0
                    }
                    
                    let timestamp = minutes * 60 + seconds + milliseconds
                    
                    // Only add if there's actual text
                    if !text.isEmpty {
                        lines.append(LyricLine(timestamp: timestamp, text: text))
                    }
                }
            }
        }
        
        // Sort by timestamp
        lines.sort { (line1, line2) -> Bool in
            guard let t1 = line1.timestamp else { return false }
            guard let t2 = line2.timestamp else { return true }
            return t1 < t2
        }
        
        return lines
    }
    
    /// Parse plain text lyrics (no timestamps)
    static func parsePlainText(_ text: String) -> [LyricLine] {
        text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { LyricLine(timestamp: nil, text: $0) }
    }
}

