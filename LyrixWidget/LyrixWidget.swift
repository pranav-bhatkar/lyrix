//
//  LyrixWidget.swift
//  LyrixWidget
//
//  Created by Pranav Bhatkar on 28/01/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct LyrixEntry: TimelineEntry {
    let date: Date
    let songTitle: String
    let artist: String
    let currentLyric: String
    let isPlaying: Bool
}

// MARK: - Timeline Provider

struct LyrixTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LyrixEntry {
        LyrixEntry(
            date: Date(),
            songTitle: "Blinding Lights",
            artist: "The Weeknd",
            currentLyric: "I've been tryna call...",
            isPlaying: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (LyrixEntry) -> Void) {
        let entry = loadCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LyrixEntry>) -> Void) {
        let entry = loadCurrentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .second, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadCurrentEntry() -> LyrixEntry {
        let defaults = UserDefaults(suiteName: "group.me.pranavbhatkar.lyrix") ?? UserDefaults.standard

        let songTitle = defaults.string(forKey: "widget.songTitle") ?? "No song playing"
        let artist = defaults.string(forKey: "widget.artist") ?? "Play something to get started"
        let currentLyric = defaults.string(forKey: "widget.currentLyric") ?? ""
        let isPlaying = defaults.bool(forKey: "widget.isPlaying")

        return LyrixEntry(
            date: Date(),
            songTitle: songTitle,
            artist: artist,
            currentLyric: currentLyric,
            isPlaying: isPlaying
        )
    }
}

// MARK: - Widget View

struct LyrixWidgetEntryView: View {
    var entry: LyrixEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    private var bgColor: Color {
        colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.96)
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    private var accentColor: Color {
        Color.orange
    }

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            mediumWidget
        }
    }

    // MARK: - Small Widget

    private var smallWidget: some View {
        ZStack {
            bgColor

            VStack(alignment: .leading, spacing: 0) {
                // Status pill
                HStack(spacing: 5) {
                    Circle()
                        .fill(entry.isPlaying ? Color.green : Color.gray)
                        .frame(width: 6, height: 6)

                    Text(entry.isPlaying ? "Playing" : "Paused")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(entry.isPlaying ? .green : .gray)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(entry.isPlaying ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                )

                Spacer()

                // Song info
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.songTitle)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                        .lineLimit(2)

                    Text(entry.artist)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(textColor.opacity(0.5))
                        .lineLimit(1)
                }

                // Music bars at bottom
                if entry.isPlaying {
                    HStack(spacing: 3) {
                        ForEach(0..<5, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(accentColor)
                                .frame(width: 4, height: CGFloat([12, 20, 8, 16, 10][i]))
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        ZStack {
            bgColor

            HStack(spacing: 14) {
                // Album art
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(accentColor)
                        .frame(width: 85, height: 85)

                    if entry.isPlaying {
                        // Animated waveform look
                        HStack(spacing: 4) {
                            ForEach(0..<4, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white)
                                    .frame(width: 5, height: CGFloat([24, 35, 18, 28][i]))
                            }
                        }
                    } else {
                        Image(systemName: "music.note")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                    }
                }

                // Song info
                VStack(alignment: .leading, spacing: 4) {
                    // Status
                    HStack(spacing: 5) {
                        Circle()
                            .fill(entry.isPlaying ? Color.green : Color.gray)
                            .frame(width: 6, height: 6)

                        Text(entry.isPlaying ? "Now Playing" : "Paused")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(entry.isPlaying ? .green : .gray)
                    }

                    // Title
                    Text(entry.songTitle)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                        .lineLimit(1)

                    // Artist
                    Text(entry.artist)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textColor.opacity(0.5))
                        .lineLimit(1)

                    // Lyric
                    if !entry.currentLyric.isEmpty {
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(accentColor)
                                .frame(width: 3, height: 24)
                                .cornerRadius(2)

                            Text(entry.currentLyric)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(accentColor)
                                .lineLimit(2)
                        }
                        .padding(.top, 6)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(14)
        }
    }
}

// MARK: - Widget Configuration

struct LyrixWidget: Widget {
    let kind: String = "LyrixWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LyrixTimelineProvider()) { entry in
            LyrixWidgetEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Lyrix")
        .description("See what's currently playing with lyrics.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    LyrixWidget()
} timeline: {
    LyrixEntry(date: Date(), songTitle: "Blinding Lights", artist: "The Weeknd", currentLyric: "", isPlaying: true)
    LyrixEntry(date: Date(), songTitle: "No song playing", artist: "Play something", currentLyric: "", isPlaying: false)
}

#Preview(as: .systemMedium) {
    LyrixWidget()
} timeline: {
    LyrixEntry(date: Date(), songTitle: "Blinding Lights", artist: "The Weeknd", currentLyric: "I've been tryna call, I've been on my own for long enough", isPlaying: true)
    LyrixEntry(date: Date(), songTitle: "Paused", artist: "The Weeknd", currentLyric: "", isPlaying: false)
}
