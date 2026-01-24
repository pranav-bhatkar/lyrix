//
//  Song.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import AppKit

struct Song: Equatable, Hashable {
    let title: String
    let artist: String
    let album: String?
    let duration: TimeInterval?
    let artwork: NSImage?
    
    init(title: String, artist: String, album: String? = nil, duration: TimeInterval? = nil, artwork: NSImage? = nil) {
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.artwork = artwork
    }
    
    var displayName: String {
        "\(title) - \(artist)"
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.title == rhs.title &&
               lhs.artist == rhs.artist &&
               lhs.album == rhs.album
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(artist)
        hasher.combine(album)
    }
}

