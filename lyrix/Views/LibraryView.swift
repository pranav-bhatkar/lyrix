//
//  LibraryView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 25/02/26.
//

import SwiftUI

struct LibraryView: View {
    @State private var cachedSongs: [CachedLyrics] = []
    @State private var searchText = ""
    @State private var selectedEntry: CachedLyrics?

    var filteredSongs: [CachedLyrics] {
        if searchText.isEmpty { return cachedSongs }
        let query = searchText.lowercased()
        return cachedSongs.filter {
            $0.displayTitle.lowercased().contains(query) ||
            $0.displayArtist.lowercased().contains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Library")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(cachedSongs.count) cached songs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if !cachedSongs.isEmpty {
                    Button(role: .destructive, action: {
                        LyricsCache.shared.clearAll()
                        loadCache()
                    }) {
                        Label("Clear All", systemImage: "trash")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(24)

            // Search
            if !cachedSongs.isEmpty {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search cached lyrics...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .padding(.horizontal, 4)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }

            Divider()

            // Content
            if cachedSongs.isEmpty {
                emptyState
            } else if filteredSongs.isEmpty {
                noResultsState
            } else {
                songList
            }
        }
        .frame(minWidth: 450, minHeight: 550)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear { loadCache() }
    }

    // MARK: - Song List

    private var songList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredSongs) { entry in
                    SongRow(entry: entry, isSelected: selectedEntry?.id == entry.id) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedEntry = selectedEntry?.id == entry.id ? nil : entry
                        }
                    } onDelete: {
                        deleteEntry(entry)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Empty States

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.4))

            VStack(spacing: 6) {
                Text("No cached lyrics")
                    .font(.headline)
                Text("Lyrics will appear here after you play songs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noResultsState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.4))
            Text("No results for \"\(searchText)\"")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func loadCache() {
        cachedSongs = LyricsCache.shared.listAll()
    }

    private func deleteEntry(_ entry: CachedLyrics) {
        LyricsCache.shared.delete(songKey: entry.songKey)
        withAnimation { loadCache() }
        if selectedEntry?.id == entry.id { selectedEntry = nil }
    }
}

// MARK: - Song Row

struct SongRow: View {
    let entry: CachedLyrics
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 14) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: "music.note")
                            .font(.system(size: 16))
                            .foregroundColor(.accentColor)
                    }

                    // Song info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.displayTitle)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)

                        HStack(spacing: 8) {
                            Text(entry.displayArtist)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)

                            if let opt = entry.lyrics.first {
                                Text(opt.isSynced ? "Synced" : "Plain")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(opt.isSynced ? Color.green.opacity(0.15) : Color.secondary.opacity(0.1)))
                                    .foregroundColor(opt.isSynced ? .green : .secondary)
                            }
                        }
                    }

                    Spacer()

                    // Cached date
                    Text(entry.cachedAt.relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    // Delete
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(isSelected ? Color.accentColor.opacity(0.08) : Color.clear)
            }
            .buttonStyle(.plain)

            // Expanded lyrics preview
            if isSelected {
                lyricsPreview
            }
        }
    }

    private var lyricsPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            let lines = entry.lyrics.first?.lines.prefix(8) ?? []
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                HStack(spacing: 8) {
                    if let ts = line.timestamp {
                        Text(formatTimestamp(ts))
                            .font(.caption2.monospacedDigit())
                            .foregroundColor(.secondary.opacity(0.5))
                            .frame(width: 50, alignment: .trailing)
                    }
                    Text(line.text)
                        .font(.caption)
                        .foregroundColor(.primary.opacity(0.8))
                        .lineLimit(1)
                }
            }
            if (entry.lyrics.first?.lines.count ?? 0) > 8 {
                Text("...\((entry.lyrics.first?.lines.count ?? 0) - 8) more lines")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 78)
        .padding(.vertical, 10)
        .background(Color.secondary.opacity(0.03))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private func formatTimestamp(_ ts: TimeInterval) -> String {
        let m = Int(ts) / 60
        let s = ts.truncatingRemainder(dividingBy: 60)
        return String(format: "%d:%05.2f", m, s)
    }
}

// MARK: - Date Extension

private extension Date {
    var relative: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

#Preview {
    LibraryView()
        .frame(width: 550, height: 700)
}
