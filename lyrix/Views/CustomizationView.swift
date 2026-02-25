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
            VStack(spacing: 24) {
                // Live Preview Card
                previewSection
                    .padding(.top, 8)
                
                VStack(spacing: 20) {
                    // Theme
                    CustomSection(title: "Theme", icon: "paintpalette") {
                        themeGrid
                    }
                    
                    // Typography
                    CustomSection(title: "Typography", icon: "textformat") {
                        VStack(spacing: 14) {
                            // Font Family
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Font")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack(spacing: 8) {
                                    FontPreviewButton(label: "Sans", tag: "Default", design: .default, selectedFont: $settings.fontName)
                                    FontPreviewButton(label: "Serif", tag: "Serif", design: .serif, selectedFont: $settings.fontName)
                                    FontPreviewButton(label: "Rounded", tag: "Rounded", design: .rounded, selectedFont: $settings.fontName)
                                    FontPreviewButton(label: "Mono", tag: "Monospaced", design: .monospaced, selectedFont: $settings.fontName)
                                }
                            }

                            Divider()

                            // Size Presets
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Size")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(settings.fontSize))pt")
                                        .font(.caption.monospacedDigit())
                                        .foregroundColor(.secondary)
                                }
                                HStack(spacing: 8) {
                                    SizePresetButton(label: "S", subtitle: "16", size: 16, selectedSize: $settings.fontSize)
                                    SizePresetButton(label: "M", subtitle: "20", size: 20, selectedSize: $settings.fontSize)
                                    SizePresetButton(label: "L", subtitle: "24", size: 24, selectedSize: $settings.fontSize)
                                    SizePresetButton(label: "XL", subtitle: "28", size: 28, selectedSize: $settings.fontSize)
                                }
                            }
                        }
                    }
                    
                    // Layout & Size
                    CustomSection(title: "Window Layout", icon: "macwindow") {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                ForEach(LyricsWindowSize.allCases, id: \.self) { size in
                                    SizeButton(
                                        size: size,
                                        isSelected: settings.windowSize == size.rawValue,
                                        action: { settings.windowSize = size.rawValue }
                                    )
                                }
                            }
                            
                            Toggle(isOn: $settings.showPlayerInFloating) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Music Player Overlay")
                                        .font(.subheadline)
                                    Text("Show playback controls and song info")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .toggleStyle(.switch)
                        }
                    }
                    
                    // Menu Bar
                    CustomSection(title: "Menu Bar", icon: "menubar.rectangle") {
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle(isOn: $settings.menuBarEnabled) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Show lyrics in menu bar")
                                        .font(.subheadline)
                                    Text("Display current lyric line in the menu bar")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .toggleStyle(.switch)
                            .onChange(of: settings.menuBarEnabled) { _, enabled in
                                if enabled {
                                    MenuBarManager.shared.enable()
                                } else {
                                    MenuBarManager.shared.disable()
                                }
                            }

                            HStack {
                                Text("Max characters")
                                    .font(.subheadline)

                                Spacer()

                                Picker("Max characters", selection: $settings.menuBarMaxLength) {
                                    Text("No limit").tag(0)
                                    Text("50").tag(50)
                                    Text("80").tag(80)
                                    Text("100").tag(100)
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .frame(width: 120)
                            }
                            .opacity(settings.menuBarEnabled ? 1 : 0.4)
                            .disabled(!settings.menuBarEnabled)
                        }
                    }

                    // Motion
                    CustomSection(title: "Motion", icon: "wand.and.stars") {
                        VStack(spacing: 14) {
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

                            HStack {
                                Text("Speed")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Picker("Speed", selection: $settings.animationSpeed) {
                                    Text("Slow").tag("Slow")
                                    Text("Normal").tag("Normal")
                                    Text("Fast").tag("Fast")
                                }
                                .pickerStyle(.segmented)
                                .labelsHidden()
                                .frame(width: 200)
                            }
                        }
                    }

                    // Advanced (collapsed by default)
                    DisclosureGroup(isExpanded: $showAdvanced) {
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Glow Effect")
                                        .font(.subheadline)
                                    Text("Subtle glow behind current lyric line")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: $settings.showGlow)
                                    .toggleStyle(.switch)
                                    .labelsHidden()
                            }

                            Divider()

                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Corner Radius")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(Int(settings.customCornerRadius))px")
                                        .font(.caption.monospacedDigit())
                                        .foregroundColor(.secondary)
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
                                        Toggle("Previous", isOn: $settings.showPreviousLine)
                                        Toggle("Next", isOn: $settings.showNextLine)
                                    }
                                    .toggleStyle(.checkbox)
                                }
                            }
                        }
                        .padding(.top, 12)
                    } label: {
                        Label("Advanced", systemImage: "gearshape")
                            .font(.subheadline.bold())
                            .foregroundColor(.primary.opacity(0.8))
                    }
                    .padding(16)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 32)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
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
        case .light: return [Color(white: 0.95), Color(white: 0.9)]
        case .neon: return [Color(red: 0.1, green: 0.05, blue: 0.2), Color(red: 0, green: 0.3, blue: 0.3)]
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

// MARK: - Font Preview Button

struct FontPreviewButton: View {
    let label: String
    let tag: String
    let design: Font.Design
    @Binding var selectedFont: String

    var isSelected: Bool { selectedFont == tag }

    var body: some View {
        Button { selectedFont = tag } label: {
            VStack(spacing: 4) {
                Text("Lyrics")
                    .font(.system(size: 14, weight: .semibold, design: design))
                    .frame(height: 36)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.15), lineWidth: isSelected ? 1.5 : 1)
                    )
                    .foregroundColor(isSelected ? .accentColor : .primary)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Size Preset Button

struct SizePresetButton: View {
    let label: String
    let subtitle: String
    let size: Int
    @Binding var selectedSize: Double

    var isSelected: Bool { Int(selectedSize) == size }

    var body: some View {
        Button { selectedSize = Double(size) } label: {
            VStack(spacing: 1) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                Text("\(subtitle)pt")
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.08))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CustomizationView()
        .frame(width: 450, height: 750)
}
