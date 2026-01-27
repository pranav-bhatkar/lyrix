//
//  NotificationManager.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 28/01/26.
//

import Foundation
import UserNotifications
import AppKit

@MainActor
class NotificationManager {
    static let shared = NotificationManager()

    private var lastNotifiedSongId: String = ""
    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {
        requestPermission()
    }

    // MARK: - Permission

    func requestPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            print("Notification permission granted: \(granted)")
        }
    }

    // MARK: - Send Notification

    func showNowPlayingNotification(for song: Song) {
        guard LyricsSettings.shared.showNowPlayingNotification else { return }

        // Avoid duplicate notifications for same song
        let songId = "\(song.title)-\(song.artist)"
        guard songId != lastNotifiedSongId else { return }
        lastNotifiedSongId = songId

        let content = UNMutableNotificationContent()
        content.title = song.title
        content.body = song.artist
        if let album = song.album {
            content.subtitle = album
        }
        content.sound = nil // Silent notification

        // Add album artwork if available
        if let artwork = song.artwork, let imageData = artwork.tiffRepresentation {
            do {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("now_playing_artwork.png")

                if let bitmap = NSBitmapImageRep(data: imageData),
                   let pngData = bitmap.representation(using: .png, properties: [:]) {
                    try pngData.write(to: tempURL)
                    let attachment = try UNNotificationAttachment(
                        identifier: "artwork",
                        url: tempURL,
                        options: nil
                    )
                    content.attachments = [attachment]
                }
            } catch {
                print("Failed to attach artwork: \(error)")
            }
        }

        // Create request with unique identifier
        let request = UNNotificationRequest(
            identifier: "now-playing-\(UUID().uuidString)",
            content: content,
            trigger: nil // Deliver immediately
        )

        // Remove previous now playing notifications
        notificationCenter.removeDeliveredNotifications(withIdentifiers: ["now-playing"])

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }

    // MARK: - Clear

    func clearNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }
}
