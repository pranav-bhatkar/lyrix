//
//  CustomizationView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI

struct CustomizationView: View {
    @ObservedObject var settings = LyricsSettings.shared
    @State private var showAdvanced = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Large Preview
                lyricsPreview
                    .padding(.top, 8)

                // Main Controls
                VStack(spacing: 24) {
                    themeSection
                    typographySection
                    windowSection
                    animationSection

                    // Advanced Toggle
                    DisclosureGroup(isExpanded: $showAdvanced) {
                        advancedSection
                            .padding(.top, 16)
                    } label: {
                        Text("Advanced")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(16)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 40)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Preview

    private var lyricsPreview: some View {
        ZStack {
            // Theme-aware background
            RoundedRectangle(cornerRadius: settings.cornerRadius)
                .fill(settings.isTransparent ? Color.secondary.opacity(0.1) : settings.backgroundColor)
                .overlay(
                    Group {
                        if settings.blurEnabled && !settings.isTransparent {
                            RoundedRectangle(cornerRadius: settings.cornerRadius)
                                .fill(.ultraThinMaterial)
                                .opacity(0.5)
                        }
                    }
                )

            VStack(spacing: settings.lineSpacing + 4) {
                if settings.showPreviousLine {
                    Text("And I know you're not afraid")
                        .font(settings.dimmedFont)
                        .foregroundColor(settings.dimmedColor)
                }

                Text("To look into my eyes")
                    .font(settings.currentLineFont)
                    .foregroundColor(settings.currentLineColor)
                    .shadow(
                        color: settings.showGlow ? settings.glowColor.opacity(0.6) : .clear,
                        radius: 12
                    )

                if settings.showNextLine {
                    Text("We were dancing all night")
                        .font(settings.dimmedFont)
                        .foregroundColor(settings.dimmedColor)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: settings.cornerRadius))
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
        .padding(.horizontal, 20)
    }

    // MARK: - Theme

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(LyricsTheme.allCases, id: \.self) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: settings.theme == theme.rawValue
                    ) {
                        settings.theme = theme.rawValue
                    }
                }
            }
        }
    }

    // MARK: - Typography

    private var typographySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Typography")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(FontOption.allCases, id: \.self) { font in
                    FontCard(
                        font: font,
                        isSelected: settings.fontName == font.id
                    ) {
                        settings.fontName = font.id
                    }
                }
            }

            HStack(spacing: 8) {
                ForEach(FontSizePreset.allCases, id: \.self) { size in
                    SizeChip(
                        size: size,
                        isSelected: Int(settings.fontSize) == size.size
                    ) {
                        settings.fontSize = Double(size.size)
                    }
                }
            }
        }
    }

    // MARK: - Window

    private var windowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Window")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(LyricsWindowSize.allCases, id: \.self) { size in
                    WindowSizeCard(
                        size: size,
                        isSelected: settings.windowSize == size.rawValue
                    ) {
                        settings.windowSize = size.rawValue
                    }
                }
            }
        }
    }

    // MARK: - Animation

    private var animationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Animation")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(LyricsAnimationStyle.allCases, id: \.self) { style in
                        AnimationChip(
                            style: style,
                            isSelected: settings.animationStyle == style.rawValue
                        ) {
                            settings.animationStyle = style.rawValue
                        }
                    }
                }
            }

            // Speed
            HStack(spacing: 8) {
                Text("Speed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Picker("", selection: $settings.animationSpeed) {
                    Text("Slow").tag("Slow")
                    Text("Normal").tag("Normal")
                    Text("Fast").tag("Fast")
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
        }
    }

    // MARK: - Advanced

    private var advancedSection: some View {
        VStack(spacing: 16) {
            SettingRow(title: "Window Glow", subtitle: "Subtle glow behind lyrics") {
                Toggle("", isOn: $settings.showGlow)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }

            Divider()

            SettingRow(title: "Player Overlay", subtitle: "Show controls on floating window") {
                Toggle("", isOn: $settings.showPlayerInFloating)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Corner Radius")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(settings.customCornerRadius))px")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
                Slider(value: $settings.customCornerRadius, in: 0...32, step: 2)
            }

            if settings.animationStyle == "Slide Up" {
                Divider()

                HStack {
                    Text("Show Lines")
                        .font(.subheadline)
                    Spacer()
                    HStack(spacing: 16) {
                        Toggle("Prev", isOn: $settings.showPreviousLine)
                        Toggle("Next", isOn: $settings.showNextLine)
                    }
                    .toggleStyle(.checkbox)
                }
            }
        }
    }
}

// MARK: - Components

struct SettingRow<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            content
        }
    }
}

struct ThemeCard: View {
    let theme: LyricsTheme
    let isSelected: Bool
    let action: () -> Void

    private var bgColor: Color {
        switch theme {
        case .dark: return Color(white: 0.12)
        case .light: return Color(white: 0.95)
        case .subtle: return Color(red: 0.13, green: 0.13, blue: 0.15)
        case .warm: return Color(red: 0.16, green: 0.11, blue: 0.09)
        case .cool: return Color(red: 0.09, green: 0.11, blue: 0.16)
        case .minimal: return Color.black
        case .transparent: return Color.clear
        }
    }

    private var textColor: Color {
        switch theme {
        case .light: return .black
        case .warm: return Color(red: 1.0, green: 0.85, blue: 0.7)
        case .cool: return Color(red: 0.75, green: 0.9, blue: 1.0)
        default: return .white
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if theme == .transparent {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .frame(height: 48)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(bgColor)
                            .frame(height: 48)
                    }

                    Text("Aa")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(theme == .transparent ? .secondary : textColor)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                )

                Text(theme.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct FontCard: View {
    let font: FontOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text("Aa")
                    .font(.system(size: 18, weight: .semibold, design: font.design))
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                    )
                    .foregroundColor(isSelected ? .white : .primary)

                Text(font.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct SizeChip: View {
    let size: FontSizePreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(size.rawValue)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct WindowSizeCard: View {
    let size: LyricsWindowSize
    let isSelected: Bool
    let action: () -> Void

    private var barWidth: CGFloat {
        switch size {
        case .small: return 40
        case .medium: return 60
        case .large: return 80
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: barWidth, height: 24)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )

                Text(size.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct AnimationChip: View {
    let style: LyricsAnimationStyle
    let isSelected: Bool
    let action: () -> Void

    private var displayName: String {
        style.rawValue.replacingOccurrences(of: "Slide ", with: "")
    }

    var body: some View {
        Button(action: action) {
            Text(displayName)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Enums

enum FontOption: String, CaseIterable {
    case sans = "Sans"
    case serif = "Serif"
    case rounded = "Rounded"
    case mono = "Mono"

    var id: String {
        switch self {
        case .sans: return "Default"
        case .serif: return "Serif"
        case .rounded: return "Rounded"
        case .mono: return "Monospaced"
        }
    }

    var design: Font.Design {
        switch self {
        case .sans: return .default
        case .serif: return .serif
        case .rounded: return .rounded
        case .mono: return .monospaced
        }
    }
}

enum FontSizePreset: String, CaseIterable {
    case small = "S"
    case medium = "M"
    case large = "L"
    case extraLarge = "XL"

    var size: Int {
        switch self {
        case .small: return 16
        case .medium: return 20
        case .large: return 24
        case .extraLarge: return 28
        }
    }
}

#Preview {
    CustomizationView()
        .frame(width: 420, height: 700)
}
