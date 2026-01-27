//
//  lyrixApp.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            KeyboardShortcutManager.shared.setup()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // When clicking dock icon or reactivating app, ensure main window is visible
        if !flag {
            // No visible windows - create a new one
            for window in sender.windows {
                // Find the main window (not the floating panel)
                if !(window is NSPanel) {
                    window.makeKeyAndOrderFront(nil)
                    return false
                }
            }
            // If no main window exists, the WindowGroup will create one
        }
        return true
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // When app becomes active (e.g., Command+Tab), show the main window if it exists
        let app = NSApplication.shared
        let hasVisibleMainWindow = app.windows.contains { window in
            !(window is NSPanel) && window.isVisible
        }

        if !hasVisibleMainWindow {
            for window in app.windows {
                if !(window is NSPanel) {
                    window.makeKeyAndOrderFront(nil)
                    break
                }
            }
        }
    }
}

@main
struct lyrixApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 850, height: 600)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Show Window") {
                    openMainWindow()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }

    private func openMainWindow() {
        for window in NSApplication.shared.windows {
            if !(window is NSPanel) {
                window.makeKeyAndOrderFront(nil)
                NSApplication.shared.activate(ignoringOtherApps: true)
                return
            }
        }
    }
}
