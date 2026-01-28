//
//  CustomizationView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI

struct CustomizationView: View {
    @ObservedObject var settings = LyricsSettings.shared
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Live Preview Card - always visible
            previewSection
                .padding(.top, 12)
                .padding(.bottom, 16)

            // Tab Picker
            Picker("", selection: $selectedTab) {
                Text("Quick Setup").tag(0)
                Text("Advanced").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Tab Content
            ScrollView {
                if selectedTab == 0 {
                    quickSetupContent
                } else {
                    advancedContent
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Quick Setup Tab

    private var quickSetupContent: some View {
        VStack(spacing: 20) {
            // Theme Selection
            CustomSection(title: "Theme", icon: "paintpalette") {
                themeGrid
            }

            // Typography
            CustomSection(title: "Typography", icon: "textformat") {
                VStack(spacing: 16) {
                    // Font Family Preview Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(FontOption.allCases, id: \.self) { font in
                            FontPreviewButton(
                                font: font,
                                isSelected: settings.fontName == font.id,
                                action: { settings.fontName = font.id }
                            )
                        }
                    }

                    Divider()

                    // Size Presets
                    HStack(spacing: 10) {
                        ForEach(FontSizePreset.allCases, id: \.self) { preset in
                            FontSizeButton(
                                preset: preset,
                                isSelected: Int(settings.fontSize) == preset.size,
                                action: { settings.fontSize = Double(preset.size) }
                            )
                        }
                    }
                }
            }

            // Window Size
            CustomSection(title: "Window Size", icon: "macwindow") {
                HStack(spacing: 12) {
                    ForEach(LyricsWindowSize.allCases, id: \.self) { size in
                        SizeButton(
                            size: size,
                            isSelected: settings.windowSize == size.rawValue,
                            action: { settings.windowSize = size.rawValue }
                        )
                    }
                }
            }

            // Animation Style
            CustomSection(title: "Animation", icon: "wand.and.stars") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(LyricsAnimationStyle.allCases, id: \.self) { style in
                            AnimationButton(
                                style: style,
                                isSelected: settings.animationStyle == style.rawValue,
                                action: { settings.animationStyle = style.rawValue }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Spacer(minLength: 32)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Advanced Tab

    private var advancedContent: some View {
        VStack(spacing: 20) {
            // Appearance Details
            CustomSection(title: "Appearance", icon: "paintpalette") {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Window Glow")
                                .font(.subheadline)
                            Text("Add a subtle glow around lyrics")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $settings.showGlow)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Corner Radius")
                            .font(.subheadline)
                        HStack(spacing: 12) {
                            Slider(value: $settings.customCornerRadius, in: 0...32, step: 2)
                            Text("\(Int(settings.customCornerRadius))px")
                                .font(.caption.monospacedDigit())
                                .foregroundColor(.secondary)
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                }
            }

            // Layout Options
            CustomSection(title: "Layout", icon: "macwindow") {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Music Player Overlay")
                                .font(.subheadline)
                            Text("Show playback controls and song info")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $settings.showPlayerInFloating)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                }
            }

            // Animation Details
            CustomSection(title: "Animation", icon: "wand.and.stars") {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Animation Speed")
                            .font(.subheadline)
                        Picker("Speed", selection: $settings.animationSpeed) {
                            Text("Slow").tag("Slow")
                            Text("Normal").tag("Normal")
                            Text("Fast").tag("Fast")
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                    }

                    if settings.animationStyle == "Slide Up" {
                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Visible Lines")
                                .font(.subheadline)
                            HStack(spacing: 24) {
                                Toggle("Show Previous", isOn: $settings.showPreviousLine)
                                Toggle("Show Next", isOn: $settings.showNextLine)
                            }
                            .toggleStyle(.checkbox)
                        }
                    }
                }
            }

            Spacer(minLength: 32)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Components
    
    private var themeGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 120))], spacing: 12) {
            ForEach(LyricsTheme.allCases, id: \.self) { theme in
                ThemeButton(
                    theme: theme,
                    isSelected: settings.theme == theme.rawValue,
                    action: { settings.theme = theme.rawValue }
                )
            }
        }
    }
    
    private var previewSection: some View {
        VStack(spacing: 12) {
            ZStack {
                // Desktop-like background
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)
                    .overlay(
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 100)
                            .blur(radius: 40)
                            .offset(x: 100, y: -40)
                    )
                
                // Floating Lyrics Window Mockup
                ZStack {
                    if !settings.isTransparent {
                        if settings.blurEnabled {
                            RoundedRectangle(cornerRadius: settings.cornerRadius)
                                .fill(.ultraThinMaterial)
                        }
                        
                        RoundedRectangle(cornerRadius: settings.cornerRadius)
                            .fill(settings.backgroundColor.opacity(settings.backgroundOpacity))
                    }
                    
                    VStack(spacing: settings.lineSpacing) {
                        previewLine("Previous lyrics line", isCurrent: false, opacity: 0.3)
                        previewLine("♪ Current lyrics line ♪", isCurrent: true, opacity: 1.0)
                        previewLine("Next lyrics line", isCurrent: false, opacity: 0.4)
                    }
                    .padding(.horizontal, settings.horizontalPadding * 0.6)
                    .padding(.vertical, settings.verticalPadding * 0.6)
                }
                .frame(width: 280)
                .fixedSize()
                .clipShape(RoundedRectangle(cornerRadius: settings.cornerRadius))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .scaleEffect(0.9)
            }
            .padding(.horizontal, 24)
            
            Text("Preview")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func previewLine(_ text: String, isCurrent: Bool, opacity: Double) -> some View {
        Text(text)
            .font(isCurrent ? settings.currentLineFont : settings.dimmedFont)
            .foregroundColor(isCurrent ? settings.currentLineColor : settings.dimmedColor)
            .opacity(isCurrent ? 1.0 : opacity)
            .shadow(
                color: isCurrent && settings.showGlow ? settings.glowColor.opacity(0.5) : .clear,
                radius: 10
            )
            .multilineTextAlignment(.center)
            .lineLimit(1)
    }
}

// MARK: - Helpers

struct CustomSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.subheadline.bold())
                .foregroundColor(.primary.opacity(0.8))
            
            VStack {
                content
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

// MARK: - Theme Button

struct ThemeButton: View {
    let theme: LyricsTheme
    let isSelected: Bool
    let action: () -> Void
    
    private var colors: [Color] {
        switch theme {
        case .dark: return [Color(white: 0.15), Color(white: 0.1)]
        case .light: return [Color(white: 0.96), Color(white: 0.92)]
        case .subtle: return [Color(red: 0.14, green: 0.14, blue: 0.16), Color(red: 0.1, green: 0.1, blue: 0.12)]
        case .warm: return [Color(red: 0.18, green: 0.12, blue: 0.1), Color(red: 0.12, green: 0.08, blue: 0.06)]
        case .cool: return [Color(red: 0.1, green: 0.12, blue: 0.18), Color(red: 0.06, green: 0.08, blue: 0.14)]
        case .minimal: return [Color.black.opacity(0.8), Color.black.opacity(0.6)]
        case .transparent: return [Color.clear, Color.clear]
        }
    }
    
    private var isTransparentTheme: Bool {
        theme == .transparent
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isTransparentTheme {
                        // Checkerboard pattern for transparent
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                .linearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 44)
                        
                        Text("Aa")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
                            .frame(height: 44)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                )
                
                Text(theme.rawValue)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Size Button

struct SizeButton: View {
    let size: LyricsWindowSize
    let isSelected: Bool
    let action: () -> Void
    
    private var widthFraction: CGFloat {
        switch size {
        case .small: return 0.5
        case .medium: return 0.7
        case .large: return 0.9
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.05))
                        .frame(height: 48)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 60 * widthFraction, height: 24)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
                )
                
                Text(size.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Animation Button

struct AnimationButton: View {
    let style: LyricsAnimationStyle
    let isSelected: Bool
    let action: () -> Void
    
    private var icon: String {
        switch style {
        case .slideUp: return "arrow.up.and.down.text.horizontal"
        case .slideLeft: return "arrow.left.to.line"
        case .slideRight: return "arrow.right.to.line"
        case .fade: return "circle.dotted"
        case .zoom: return "plus.magnifyingglass"
        case .blur: return "sparkles"
        case .flip: return "cube.transparent"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
                        .frame(width: 80, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary.opacity(0.8))
                }
                
                Text(style.rawValue.replacingOccurrences(of: "Slide ", with: ""))
                    .font(.caption2)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .accentColor : .primary.opacity(0.7))
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Font Options

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

    var font: Font {
        switch self {
        case .sans: return .system(size: 14, weight: .semibold, design: .default)
        case .serif: return .system(size: 14, weight: .semibold, design: .serif)
        case .rounded: return .system(size: 14, weight: .semibold, design: .rounded)
        case .mono: return .system(size: 14, weight: .semibold, design: .monospaced)
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

    var label: String {
        "\(size)pt"
    }
}

// MARK: - Font Preview Button

struct FontPreviewButton: View {
    let font: FontOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.05))
                        .frame(height: 44)

                    Text("Lyrics")
                        .font(font.font)
                        .foregroundColor(isSelected ? .accentColor : .primary.opacity(0.8))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.15), lineWidth: isSelected ? 2 : 1)
                )

                Text(font.rawValue)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Font Size Button

struct FontSizeButton: View {
    let preset: FontSizePreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(preset.rawValue)
                    .font(.headline)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : .primary.opacity(0.8))
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.15), lineWidth: 1)
                    )

                Text(preset.label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CustomizationView()
        .frame(width: 450, height: 750)
}
