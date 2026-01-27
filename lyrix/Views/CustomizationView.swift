//
//  CustomizationView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI

struct CustomizationView: View {
    @ObservedObject var settings = LyricsSettings.shared
    @ObservedObject var themeManager = CustomThemeManager.shared
    @State private var showThemeBuilder = false
    @State private var editingTheme: CustomTheme?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Live Preview Card
                previewSection
                    .padding(.top, 8)
                
                VStack(spacing: 20) {
                    // Appearance & Theme
                    CustomSection(title: "Appearance", icon: "paintpalette") {
                        VStack(spacing: 20) {
                            themeGrid
                            
                            Divider()
                            
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Window Glow")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Toggle("Enable Glow", isOn: $settings.showGlow)
                                        .toggleStyle(.switch)
                                        .labelsHidden()
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Corner Radius")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 12) {
                                        Slider(value: $settings.customCornerRadius, in: 0...32, step: 2)
                                            .frame(width: 120)
                                        Text("\(Int(settings.customCornerRadius))px")
                                            .font(.caption.monospacedDigit())
                                            .foregroundColor(.primary.opacity(0.8))
                                            .frame(width: 35, alignment: .trailing)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Typography
                    CustomSection(title: "Typography", icon: "textformat") {
                        VStack(spacing: 16) {
                            // Font Family
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Font Family")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Picker("Font Family", selection: $settings.fontName) {
                                    Text("Sans").tag("Default")
                                    Text("Serif").tag("Serif")
                                    Text("Rounded").tag("Rounded")
                                    Text("Mono").tag("Monospaced")
                                }
                                .pickerStyle(.segmented)
                                .labelsHidden()
                            }

                            Divider()

                            // Font Size Presets
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Text Size")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 10) {
                                    ForEach(FontSizePreset.allCases, id: \.self) { preset in
                                        FontSizeButton(
                                            preset: preset,
                                            isSelected: settings.fontSizePreset == preset.rawValue,
                                            action: {
                                                settings.fontSizePreset = preset.rawValue
                                                settings.fontSize = preset.size
                                            }
                                        )
                                    }
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
                    
                    // Motion
                    CustomSection(title: "Motion", icon: "wand.and.stars") {
                        VStack(spacing: 16) {
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

                            VStack(spacing: 12) {
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Animation Speed")
                                            .font(.caption)
                                            .foregroundColor(.secondary)

                                        Picker("Speed", selection: $settings.animationSpeed) {
                                            Text("Slow").tag("Slow")
                                            Text("Normal").tag("Normal")
                                            Text("Fast").tag("Fast")
                                        }
                                        .pickerStyle(.segmented)
                                        .labelsHidden()
                                        .frame(width: 180)
                                    }

                                    Spacer()

                                    if settings.animationStyle == "Slide Up" {
                                        VStack(alignment: .trailing, spacing: 6) {
                                            Text("Show Lines")
                                                .font(.caption)
                                                .foregroundColor(.secondary)

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
                    }

                    // Keyboard Shortcuts
                    CustomSection(title: "Keyboard Shortcuts", icon: "keyboard") {
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle(isOn: Binding(
                                get: { KeyboardShortcutManager.shared.shortcutsEnabled },
                                set: { enabled in
                                    KeyboardShortcutManager.shared.shortcutsEnabled = enabled
                                    if enabled {
                                        KeyboardShortcutManager.shared.startMonitoring()
                                    } else {
                                        KeyboardShortcutManager.shared.stopMonitoring()
                                    }
                                }
                            )) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Enable Global Shortcuts")
                                        .font(.subheadline)
                                    Text("Control Lyrix from anywhere")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .toggleStyle(.switch)

                            if KeyboardShortcutManager.shared.shortcutsEnabled {
                                Divider()

                                VStack(alignment: .leading, spacing: 12) {
                                    shortcutRow("Toggle Overlay", shortcut: "⌥⌘L")
                                    shortcutRow("Play / Pause", shortcut: "⌥⌘P")
                                    shortcutRow("Next Track", shortcut: "⌥⌘→")
                                    shortcutRow("Previous Track", shortcut: "⌥⌘←")
                                    shortcutRow("Skip +10s", shortcut: "⌥⌘.")
                                    shortcutRow("Skip -10s", shortcut: "⌥⌘,")
                                }
                            }
                        }
                    }

                    // Notifications
                    CustomSection(title: "Notifications", icon: "bell") {
                        HStack {
                            Toggle(isOn: $settings.showNowPlayingNotification) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Now Playing Notification")
                                        .font(.subheadline)
                                    Text("Show a notification when the song changes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .toggleStyle(.switch)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 32)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func shortcutRow(_ action: String, shortcut: String) -> some View {
        HStack {
            Text(action)
                .font(.subheadline)
            Spacer()
            Text(shortcut)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(6)
        }
    }

    // MARK: - Components
    
    private var themeGrid: some View {
        VStack(spacing: 16) {
            // Built-in themes (excluding Custom)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 120))], spacing: 12) {
                ForEach(LyricsTheme.allCases.filter { $0 != .custom }, id: \.self) { theme in
                    ThemeButton(
                        theme: theme,
                        isSelected: settings.theme == theme.rawValue && settings.theme != "Custom",
                        action: {
                            settings.theme = theme.rawValue
                            themeManager.setActiveTheme(nil)
                        }
                    )
                }
            }

            // Custom themes section
            if !themeManager.themes.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Custom Themes")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 120))], spacing: 12) {
                        ForEach(themeManager.themes) { theme in
                            CustomThemeButton(
                                theme: theme,
                                isSelected: settings.theme == "Custom" && themeManager.activeCustomThemeId == theme.id,
                                onSelect: {
                                    themeManager.setActiveTheme(theme)
                                },
                                onEdit: {
                                    editingTheme = theme
                                    showThemeBuilder = true
                                }
                            )
                        }
                    }
                }
            }

            // Create new theme button
            Button(action: {
                editingTheme = nil
                showThemeBuilder = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Custom Theme")
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .sheet(isPresented: $showThemeBuilder) {
            ThemeBuilderView(theme: editingTheme)
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
        case .custom: return [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]
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

// MARK: - Custom Theme Button

struct CustomThemeButton: View {
    let theme: CustomTheme
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [theme.bgColor, theme.bgColor.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 44)

                    Text("Aa")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textColor)
                        .shadow(color: theme.glow.opacity(0.5), radius: 4)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                )
                .overlay(alignment: .topTrailing) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    }
                    .buttonStyle(.plain)
                    .offset(x: 4, y: -4)
                }

                Text(theme.name)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .lineLimit(1)
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

// MARK: - Font Size Preset

enum FontSizePreset: String, CaseIterable {
    case small = "S"
    case medium = "M"
    case large = "L"
    case extraLarge = "XL"

    var size: Double {
        switch self {
        case .small: return 16
        case .medium: return 20
        case .large: return 24
        case .extraLarge: return 28
        }
    }

    var displayName: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        case .extraLarge: return "Extra Large"
        }
    }
}

// MARK: - Font Size Button

struct FontSizeButton: View {
    let preset: FontSizePreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.08))
                        .frame(height: 52)

                    Text("Aa")
                        .font(.system(size: textSize, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? .white : .primary.opacity(0.7))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.15), lineWidth: 1)
                )

                VStack(spacing: 1) {
                    Text(preset.rawValue)
                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .accentColor : .secondary)

                    Text("\(Int(preset.size))pt")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private var textSize: CGFloat {
        switch preset {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        case .extraLarge: return 20
        }
    }
}

#Preview {
    CustomizationView()
        .frame(width: 450, height: 750)
}
