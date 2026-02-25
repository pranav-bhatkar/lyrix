//
//  SettingsView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = LyricsViewModel()
    @StateObject private var floatingManager = FloatingLyricsManager.shared
    @State private var manualTitle = ""
    @State private var manualArtist = ""
    @State private var showManualSearch = false
    @State private var songChangeAnimation = false
    @State private var lastSongId: String = ""
    @State private var showCopiedToast = false

    var body: some View {
        VStack(spacing: 0) {
            // Now Playing Header
            nowPlayingHeader

            Divider()

            // Main content
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error, viewModel.lyrics == nil {
                errorView(error)
            } else if viewModel.lyrics != nil {
                lyricsContentView
            } else if viewModel.currentSong != nil {
                noLyricsView
            } else {
                emptyStateView
            }
        }
        .frame(minWidth: 450, minHeight: 550)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            floatingManager.setup(viewModel: viewModel)
            // Automatically show floating lyrics on start
            if !floatingManager.isVisible {
                floatingManager.show()
            }
        }
    }

    // MARK: - Now Playing Header

    private var nowPlayingHeader: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                // Artwork with sync badge
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        if let artwork = viewModel.currentSong?.artwork {
                            Image(nsImage: artwork)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.accentColor.opacity(0.2), Color.purple.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            Image(systemName: "music.note")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 110, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    .scaleEffect(songChangeAnimation ? 0.92 : 1.0)
                    .opacity(songChangeAnimation ? 0.7 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: songChangeAnimation)

                    // Sync status badge
                    if viewModel.lyrics != nil || viewModel.isLoading {
                        syncBadge
                            .offset(x: 6, y: 6)
                    }
                }

                // Song info & Controls
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        if let song = viewModel.currentSong {
                            Text(song.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .lineLimit(2)
                                .opacity(songChangeAnimation ? 0.5 : 1.0)
                                .offset(y: songChangeAnimation ? -4 : 0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: songChangeAnimation)

                            Text(song.artist)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .opacity(songChangeAnimation ? 0.5 : 1.0)
                                .offset(y: songChangeAnimation ? -2 : 0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.05), value: songChangeAnimation)
                        } else {
                            Text("No song playing")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Play something to get started")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Controls
                    HStack(spacing: 24) {
                        Button(action: { viewModel.previousTrack() }) {
                            Image(systemName: "backward.fill")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)

                        Button(action: { viewModel.playPause() }) {
                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 32))
                        }
                        .buttonStyle(.plain)

                        Button(action: { viewModel.nextTrack() }) {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                    }
                    .foregroundColor(.primary)
                }

                Spacer()

                // App Button
                if viewModel.activePlayer != nil {
                    Button(action: { viewModel.openActivePlayer() }) {
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.title2)
                            Text("Open App")
                                .font(.caption2)
                        }
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Progress bar
            if let duration = viewModel.currentSong?.duration, duration > 0 {
                VStack(spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.secondary.opacity(0.1))

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.accentColor)
                                .frame(width: geo.size.width * min(viewModel.playbackPosition / duration, 1.0))
                        }
                    }
                    .frame(height: 4)

                    HStack {
                        Text(formatTime(viewModel.playbackPosition))
                        Spacer()
                        Text(formatTime(duration))
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                }
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: { floatingManager.toggle() }) {
                    Label(
                        floatingManager.isVisible ? "Hide Overlay" : "Show Overlay",
                        systemImage: floatingManager.isVisible ? "pip.exit" : "pip.enter"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(floatingManager.isVisible ? .orange : .accentColor)

                Button(action: { viewModel.refreshNowPlaying() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)

                Button(action: { showManualSearch.toggle() }) {
                    Image(systemName: "magnifyingglass")
                }
                .buttonStyle(.bordered)

                if viewModel.currentSong != nil {
                    Button(action: {
                        Task { await viewModel.refreshLyrics() }
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(24)
        .onChange(of: viewModel.currentSong?.title) { oldTitle, newTitle in
            let newSongId = "\(newTitle ?? "")-\(viewModel.currentSong?.artist ?? "")"
            if newTitle != nil && newSongId != lastSongId && !lastSongId.isEmpty {
                // Trigger animation
                songChangeAnimation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    songChangeAnimation = false
                }
            }
            lastSongId = newSongId
        }
    }

    // MARK: - Lyrics Content View

    private var lyricsContentView: some View {
        VStack(spacing: 0) {
            // Lyrics toolbar
            HStack(spacing: 12) {
                // Source picker
                if viewModel.lyricsOptions.count > 1 {
                    ForEach(Array(viewModel.lyricsOptions.enumerated()), id: \.offset) { index, lyrics in
                        Button(action: { viewModel.selectedLyricsIndex = index }) {
                            HStack(spacing: 4) {
                                Image(systemName: lyrics.isSynced ? "waveform" : "text.alignleft")
                                    .font(.caption2)
                                Text(lyrics.isSynced ? "Synced" : "Plain")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedLyricsIndex == index
                                          ? Color.accentColor
                                          : Color.secondary.opacity(0.15))
                            )
                            .foregroundColor(viewModel.selectedLyricsIndex == index ? .white : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()

                // Sync indicator
                if let lyrics = viewModel.lyrics {
                    HStack(spacing: 4) {
                        Image(systemName: lyrics.isSynced ? "checkmark.circle.fill" : "circle")
                            .font(.caption)
                        Text(lyrics.source.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }

                // Quick actions
                if viewModel.lyrics != nil {
                    HStack(spacing: 8) {
                        quickActionButton("Copy", icon: "doc.on.doc") {
                            copyLyricsToClipboard()
                        }

                        quickActionButton("Share", icon: "square.and.arrow.up") {
                            shareLyricsAsImage()
                        }

                        if viewModel.activePlayer != nil {
                            quickActionButton("Open", icon: "arrow.up.right") {
                                viewModel.openActivePlayer()
                            }
                        }
                    }
                }

                // Report wrong lyrics button
                Button(action: { viewModel.reportWrongLyrics() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "flag")
                            .font(.caption)
                        Text("Report")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Report wrong lyrics on LRCLib")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.secondary.opacity(0.05))

            // Lyrics scroll view
            if let lyrics = viewModel.lyrics {
                lyricsView(lyrics)
            }
        }
        .overlay(alignment: .bottom) {
            if showCopiedToast {
                Text("Copied to clipboard")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.primary.opacity(0.9))
                    .foregroundColor(Color(nsColor: .windowBackgroundColor))
                    .cornerRadius(20)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func quickActionButton(_ label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .foregroundColor(.secondary)
    }

    private func copyLyricsToClipboard() {
        guard let lyrics = viewModel.lyrics else { return }

        var text = ""
        if let song = viewModel.currentSong {
            text = "\(song.title) - \(song.artist)\n\n"
        }
        text += lyrics.lines.map { $0.text }.joined(separator: "\n")

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        withAnimation(.easeInOut(duration: 0.2)) {
            showCopiedToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showCopiedToast = false
            }
        }
    }

    @MainActor
    private func shareLyricsAsImage() {
        guard let lyrics = viewModel.lyrics else { return }

        let imageView = LyricsShareView(
            song: viewModel.currentSong,
            lyrics: lyrics,
            currentLineIndex: viewModel.currentLineIndex
        )

        let renderer = ImageRenderer(content: imageView)
        renderer.scale = 2.0

        guard let nsImage = renderer.nsImage else { return }

        let picker = NSSharingServicePicker(items: [nsImage])
        if let window = NSApp.keyWindow, let contentView = window.contentView {
            picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Finding lyrics...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error View

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Couldn't load lyrics")
                .font(.headline)

            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: {
                Task { await viewModel.refreshLyrics() }
            }) {
                Label("Try Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - No Lyrics View

    private var noLyricsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.badge.xmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))

            Text("No lyrics available")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "music.note.list")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
            }

            VStack(spacing: 8) {
                Text("Ready for lyrics")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Play a song in Music, Spotify, or any media app\nand lyrics will appear automatically")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Lyrics View

    private func lyricsView(_ lyrics: Lyrics) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(lyrics.lines.enumerated()), id: \.element.id) { index, line in
                        LyricLineView(
                            line: line,
                            isCurrentLine: index == viewModel.currentLineIndex,
                            isSynced: lyrics.isSynced
                        )
                        .id(line.id)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .onChange(of: viewModel.currentLineIndex) { _, newIndex in
                if let index = newIndex, index < lyrics.lines.count {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lyrics.lines[index].id, anchor: .center)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    @ViewBuilder
    private var syncBadge: some View {
        if viewModel.isLoading {
            HStack(spacing: 3) {
                ProgressView()
                    .scaleEffect(0.5)
                    .frame(width: 10, height: 10)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.secondary)
            .foregroundColor(.white)
            .cornerRadius(6)
        } else {
            let isSynced = viewModel.lyrics?.isSynced ?? false
            HStack(spacing: 3) {
                Image(systemName: isSynced ? "waveform" : "text.alignleft")
                    .font(.system(size: 8, weight: .bold))
                Text(isSynced ? "SYNC" : "TEXT")
                    .font(.system(size: 8, weight: .bold))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(isSynced ? Color.green : Color.orange)
            .foregroundColor(.white)
            .cornerRadius(6)
        }
    }
}

// MARK: - Lyric Line View

struct LyricLineView: View {
    let line: LyricLine
    let isCurrentLine: Bool
    let isSynced: Bool

    var body: some View {
        HStack(spacing: 12) {
            if isSynced, let timestamp = line.formattedTimestamp {
                Text(timestamp)
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.4))
                    .frame(width: 65, alignment: .trailing)
                    .monospacedDigit()
            }

            Text(line.text)
                .font(isCurrentLine ? .title3 : .body)
                .fontWeight(isCurrentLine ? .bold : .regular)
                .foregroundColor(isCurrentLine ? .primary : .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isCurrentLine ? Color.accentColor.opacity(0.12) : Color.clear)
        )
        .animation(.easeInOut(duration: 0.2), value: isCurrentLine)
    }
}

// MARK: - Lyrics Share View

struct LyricsShareView: View {
    let song: Song?
    let lyrics: Lyrics
    let currentLineIndex: Int?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                if let song = song {
                    Text(song.title)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text(song.artist)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 24)

            // Lyrics
            VStack(spacing: 12) {
                let linesToShow = getLyricsLines()
                ForEach(Array(linesToShow.enumerated()), id: \.offset) { index, line in
                    Text(line.text)
                        .font(.system(size: 18, weight: line.isCurrent ? .bold : .regular))
                        .foregroundColor(line.isCurrent ? .white : .white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)

            // Footer
            HStack {
                Spacer()
                Text("lyrix")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(width: 400)
        .background(
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.05, green: 0.05, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func getLyricsLines() -> [(text: String, isCurrent: Bool)] {
        guard let index = currentLineIndex else {
            // No current line, show first few lines
            return lyrics.lines.prefix(5).map { ($0.text, false) }
        }

        // Show 2 lines before, current, and 2 after
        let start = max(0, index - 2)
        let end = min(lyrics.lines.count, index + 3)

        return (start..<end).map { i in
            (lyrics.lines[i].text, i == index)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .frame(width: 550, height: 700)
}
