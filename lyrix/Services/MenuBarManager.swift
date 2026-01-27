//
//  MenuBarManager.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 27/01/26.
//

import SwiftUI
import Combine
import AppKit

/// Manages the menu bar status item that displays current lyrics
@MainActor
class MenuBarManager: ObservableObject {
    static let shared = MenuBarManager()

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private weak var viewModel: LyricsViewModel?
    private var cancellables = Set<AnyCancellable>()

    @AppStorage("lyrics.menuBarEnabled") var isEnabled = true
    @AppStorage("lyrics.menuBarMaxLength") var maxLength = 0  // 0 = unlimited

    private init() {}

    // MARK: - Setup

    func setup(viewModel: LyricsViewModel) {
        self.viewModel = viewModel

        if isEnabled {
            enable()
        }

        setupBindings()
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        // Observe current line changes
        viewModel.$currentLineIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenuBarText()
            }
            .store(in: &cancellables)

        // Observe lyrics changes
        viewModel.$lyrics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenuBarText()
            }
            .store(in: &cancellables)

        // Observe playing state changes
        viewModel.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenuBarText()
            }
            .store(in: &cancellables)

        // Observe song changes
        viewModel.$currentSong
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenuBarText()
            }
            .store(in: &cancellables)
    }

    // MARK: - Enable/Disable

    func enable() {
        guard statusItem == nil else { return }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.title = "\u{266A}"  // Music note
            button.action = #selector(togglePopover)
            button.target = self
        }

        setupPopover()
        updateMenuBarText()
    }

    func disable() {
        if let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
        }
        statusItem = nil
        popover?.close()
        popover = nil
    }

    // MARK: - Popover

    private func setupPopover() {
        guard let viewModel = viewModel else { return }

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 280)
        popover?.behavior = .transient
        popover?.animates = true
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarPopoverView(viewModel: viewModel)
        )
    }

    @objc private func togglePopover() {
        guard let popover = popover, let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

            // Ensure popover closes when clicking outside
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - Update Menu Bar Text

    private func updateMenuBarText() {
        guard let button = statusItem?.button else { return }
        guard let viewModel = viewModel else {
            button.title = "\u{266A}"
            return
        }

        let text: String

        if viewModel.currentSong == nil {
            // No song playing
            text = "\u{266A}"
        } else if !viewModel.isPlaying {
            // Paused
            text = "\u{266A} Paused"
        } else if let lyrics = viewModel.lyrics,
                  lyrics.isSynced,
                  let index = viewModel.currentLineIndex,
                  index < lyrics.lines.count {
            // Playing with synced lyrics
            let lyricText = lyrics.lines[index].text
            text = truncateText(lyricText)
        } else if viewModel.lyrics == nil && viewModel.currentSong != nil {
            // Playing but no lyrics
            text = "\u{266A} No lyrics"
        } else {
            // Playing but no synced lyrics or waiting
            text = "\u{266A}"
        }

        button.title = text
    }

    private func truncateText(_ text: String) -> String {
        guard maxLength > 0, text.count > maxLength else {
            return text
        }

        let truncated = String(text.prefix(maxLength - 1))
        return truncated + "\u{2026}"  // Ellipsis
    }
}
