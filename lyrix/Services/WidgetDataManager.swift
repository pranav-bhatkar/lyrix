//
//  WidgetDataManager.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 28/01/26.
//

import Foundation
import WidgetKit

/// Manages data sharing between the main app and widget extension
@MainActor
class WidgetDataManager {
    static let shared = WidgetDataManager()

    private let defaults: UserDefaults
    private let appGroupIdentifier = "group.me.pranavbhatkar.lyrix"

    private init() {
        // Try App Group first, fall back to standard UserDefaults
        defaults = UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }

    // MARK: - Update Widget Data

    func updateNowPlaying(song: Song?, currentLyric: String?, isPlaying: Bool) {

        if let song = song {
            defaults.set(song.title, forKey: "widget.songTitle")
            defaults.set(song.artist, forKey: "widget.artist")
        } else {
            defaults.set("No song playing", forKey: "widget.songTitle")
            defaults.set("Play something to get started", forKey: "widget.artist")
        }

        defaults.set(currentLyric ?? "", forKey: "widget.currentLyric")
        defaults.set(isPlaying, forKey: "widget.isPlaying")

        // Trigger widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "LyrixWidget")
    }

    func clearData() {
        defaults.removeObject(forKey: "widget.songTitle")
        defaults.removeObject(forKey: "widget.artist")
        defaults.removeObject(forKey: "widget.currentLyric")
        defaults.removeObject(forKey: "widget.isPlaying")

        WidgetCenter.shared.reloadTimelines(ofKind: "LyrixWidget")
    }
}
