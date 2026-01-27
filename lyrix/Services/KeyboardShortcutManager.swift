//
//  KeyboardShortcutManager.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 28/01/26.
//

import SwiftUI
import Carbon.HIToolbox

@MainActor
class KeyboardShortcutManager {
    static let shared = KeyboardShortcutManager()

    var shortcutsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "shortcuts.enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "shortcuts.enabled") }
    }

    private var eventMonitor: Any?
    private var localMonitor: Any?

    private init() {
        // Register default value
        UserDefaults.standard.register(defaults: ["shortcuts.enabled": true])
    }

    func setup() {
        if shortcutsEnabled {
            startMonitoring()
        }
    }

    func startMonitoring() {
        stopMonitoring()

        // Global monitor for when app is not focused
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            Task { @MainActor in
                self?.handleKeyEvent(event)
            }
        }

        // Local monitor for when app is focused
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            Task { @MainActor in
                self?.handleKeyEvent(event)
            }
            return event
        }
    }

    func stopMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    private func handleKeyEvent(_ event: NSEvent) {
        guard shortcutsEnabled else { return }

        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let keyCode = event.keyCode

        // Check for Option + Command modifier
        let optCmd: NSEvent.ModifierFlags = [.option, .command]

        guard modifiers.contains(optCmd) else { return }

        switch keyCode {
        case 37: // L key
            toggleFloatingWindow()
        case 35: // P key
            playPause()
        case 124: // Right arrow
            nextTrack()
        case 123: // Left arrow
            previousTrack()
        case 47: // Period (.) key - seek forward
            seekForward()
        case 43: // Comma (,) key - seek backward
            seekBackward()
        default:
            break
        }
    }

    private func toggleFloatingWindow() {
        FloatingLyricsManager.shared.toggle()
    }

    private func playPause() {
        NowPlayingService.shared.playPause()
    }

    private func nextTrack() {
        NowPlayingService.shared.nextTrack()
    }

    private func previousTrack() {
        NowPlayingService.shared.previousTrack()
    }

    private func seekForward() {
        NowPlayingService.shared.seekForward(seconds: 10)
    }

    private func seekBackward() {
        NowPlayingService.shared.seekBackward(seconds: 10)
    }
}
