//
//  MenuBarPopoverView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 27/01/26.
//

import SwiftUI

/// Popover view shown when clicking the menu bar item
struct MenuBarPopoverView: View {
    @ObservedObject var viewModel: LyricsViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header with album art and song info
            headerSection

            // Current lyric with gradient background
            lyricSection

            // Bottom controls
            controlsSection
        }
        .frame(width: 300)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(spacing: 14) {
            // Album Artwork
            ZStack {
                if let song = viewModel.currentSong, let artwork = song.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    LinearGradient(
                        colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: "music.note")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

            // Song Details
            VStack(alignment: .leading, spacing: 3) {
                if let song = viewModel.currentSong {
                    Text(song.title)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)

                    Text(song.artist)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    // Status pill
                    HStack(spacing: 4) {
                        Circle()
                            .fill(viewModel.isPlaying ? Color.green : Color.orange)
                            .frame(width: 6, height: 6)
                        Text(viewModel.isPlaying ? "Playing" : "Paused")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                } else {
                    Text("No song playing")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)

                    Text("Play music to see lyrics")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }

    // MARK: - Lyric Section

    private var lyricSection: some View {
        VStack(spacing: 8) {
            if let lyrics = viewModel.lyrics,
               lyrics.isSynced,
               let index = viewModel.currentLineIndex,
               index < lyrics.lines.count {

                // Previous line (if exists)
                if index > 0 {
                    Text(lyrics.lines[index - 1].text)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.5))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                }

                // Current line
                Text(lyrics.lines[index].text)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)

                // Next line (if exists)
                if index < lyrics.lines.count - 1 {
                    Text(lyrics.lines[index + 1].text)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.5))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                }

            } else if viewModel.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text("Finding lyrics...")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            } else if viewModel.currentSong != nil {
                VStack(spacing: 4) {
                    Image(systemName: "text.badge.xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No synced lyrics")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "waveform")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("Waiting for music...")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(minHeight: 80)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Controls Section

    private var controlsSection: some View {
        VStack(spacing: 12) {
            // Playback controls
            HStack(spacing: 0) {
                Button(action: { viewModel.previousTrack() }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 16))
                        .frame(width: 44, height: 36)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())

                Spacer()

                Button(action: { viewModel.playPause() }) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 44, height: 44)

                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .offset(x: viewModel.isPlaying ? 0 : 1)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: { viewModel.nextTrack() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16))
                        .frame(width: 44, height: 36)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 24)

            Divider()
                .padding(.horizontal, 16)

            // Open Lyrix button
            Button(action: openMainWindow) {
                HStack(spacing: 6) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 12))
                    Text("Open Lyrix")
                        .font(.system(size: 12, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.accentColor.opacity(0.1))
                .foregroundColor(.accentColor)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
    }

    private func openMainWindow() {
        for window in NSApplication.shared.windows {
            if !(window is NSPanel) {
                window.makeKeyAndOrderFront(nil)
                NSApplication.shared.activate(ignoringOtherApps: true)
                return
            }
        }
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}

// MARK: - Preview

#Preview {
    MenuBarPopoverView(viewModel: LyricsViewModel())
        .frame(width: 300)
}
