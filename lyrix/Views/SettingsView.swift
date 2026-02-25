//
//  SettingsView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var viewModel = SharedViewModel.shared.lyricsViewModel
    @StateObject private var floatingManager = FloatingLyricsManager.shared
    @State private var manualTitle = ""
    @State private var manualArtist = ""
    @State private var showManualSearch = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Now Playing Header
            nowPlayingHeader
            
            Divider()
            
            // Main content
            if viewModel.isLoading && viewModel.lyrics == nil {
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
                // Artwork
                ZStack {
                    if let artwork = viewModel.currentSong?.artwork {
                        Image(nsImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.secondary.opacity(0.1))
                        
                        Image(systemName: "music.note")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Song info & Controls
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        if let song = viewModel.currentSong {
                            Text(song.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .lineLimit(1)
                            
                            Text(song.artist)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
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
    }
    
    // MARK: - Lyrics Content View
    
    private var lyricsContentView: some View {
        VStack(spacing: 0) {
            // Lyrics source picker at top of lyrics area
            if viewModel.lyricsOptions.count > 1 {
                HStack {
                    ForEach(Array(viewModel.lyricsOptions.enumerated()), id: \.offset) { index, lyrics in
                        Button(action: { viewModel.selectedLyricsIndex = index }) {
                            HStack(spacing: 6) {
                                Image(systemName: lyrics.isSynced ? "waveform" : "text.alignleft")
                                    .font(.caption)
                                Text(lyrics.isSynced ? "Synced" : "Plain")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
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

                    Button(action: { viewModel.reportWrongLyrics() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "flag")
                                .font(.caption)
                            Text("Report")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .help("Report wrong lyrics on LRCLib")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.secondary.opacity(0.05))
            }
            
            // Lyrics scroll view
            if let lyrics = viewModel.lyrics {
                lyricsView(lyrics)
            }
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

// MARK: - Preview

#Preview {
    SettingsView()
        .frame(width: 550, height: 700)
}
