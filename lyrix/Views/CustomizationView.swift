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
            VStack(spacing: 28) {
                // Preview
                VStack(spacing: 8) {
                    Text("Preview")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    lyricsPreview
                }
                .padding(.top, 8)

                // All Settings
                VStack(spacing: 24) {
                    themeSection
                    Divider()
                    fontSection
                    Divider()
                    sizeSection
                    Divider()
                    animationSection
                    Divider()
                    optionsSection
                    Divider()
                    keyboardShortcutsSection
                    Divider()
                    menuBarSection
                    Divider()
                    notificationsSection
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
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: settings.cornerRadius))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
        .padding(.horizontal, 20)
    }

    // MARK: - Theme

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme")
                .font(.headline)

            // Built-in themes (excluding Custom)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                ForEach(LyricsTheme.allCases.filter { $0 != .custom }, id: \.self) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: settings.theme == theme.rawValue && settings.theme != "Custom"
                    ) {
                        settings.theme = theme.rawValue
                        themeManager.setActiveTheme(nil)
                    }
                }
            }

            // Custom themes section
            if !themeManager.themes.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Custom Themes")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
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

    // MARK: - Font

    private var fontSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Font")
                .font(.headline)

            HStack(spacing: 10) {
                ForEach(FontOption.allCases, id: \.self) { font in
                    Button {
                        settings.fontName = font.id
                    } label: {
                        VStack(spacing: 4) {
                            Text("Lyrics")
                                .font(.system(size: 15, weight: .semibold, design: font.design))
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(settings.fontName == font.id ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                                )
                                .foregroundColor(settings.fontName == font.id ? .white : .primary)

                            Text(font.rawValue)
                                .font(.caption)
                                .foregroundColor(settings.fontName == font.id ? .accentColor : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Size

    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Font Size")
                    .font(.headline)
                Spacer()
                Text("\(Int(settings.fontSize))pt")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            HStack(spacing: 10) {
                ForEach(FontSizePreset.allCases, id: \.self) { preset in
                    Button {
                        settings.fontSizePreset = preset.rawValue
                        settings.fontSize = preset.size
                    } label: {
                        VStack(spacing: 2) {
                            Text(preset.rawValue)
                                .font(.headline)
                            Text("\(Int(preset.size))pt")
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(settings.fontSizePreset == preset.rawValue ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                        )
                        .foregroundColor(settings.fontSizePreset == preset.rawValue ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Animation

    private var animationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Animation Style")
                .font(.headline)

            // Style picker
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(LyricsAnimationStyle.allCases, id: \.self) { style in
                    Button {
                        settings.animationStyle = style.rawValue
                    } label: {
                        Text(style.shortName)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(settings.animationStyle == style.rawValue ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                            )
                            .foregroundColor(settings.animationStyle == style.rawValue ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Speed
            HStack {
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
            .padding(.top, 4)
        }
    }

    // MARK: - Options

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Options")
                .font(.headline)

            // Window Size
            VStack(alignment: .leading, spacing: 8) {
                Text("Window Width")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 10) {
                    ForEach(LyricsWindowSize.allCases, id: \.self) { size in
                        Button {
                            settings.windowSize = size.rawValue
                        } label: {
                            Text(size.rawValue)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(settings.windowSize == size.rawValue ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                                )
                                .foregroundColor(settings.windowSize == size.rawValue ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Corner Radius
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Corner Radius")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(settings.customCornerRadius))px")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
                Slider(value: $settings.customCornerRadius, in: 0...32, step: 2)
            }

            // Toggles
            VStack(spacing: 12) {
                Toggle(isOn: $settings.showGlow) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Glow Effect")
                            .font(.subheadline)
                        Text("Adds subtle glow behind current line")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Toggle(isOn: $settings.showPlayerInFloating) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Player Controls")
                            .font(.subheadline)
                        Text("Show playback controls on floating window")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if settings.animationStyle == "Slide Up" {
                    Divider()

                    HStack {
                        Text("Show Lines")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Toggle("Previous", isOn: $settings.showPreviousLine)
                        Toggle("Next", isOn: $settings.showNextLine)
                    }
                    .toggleStyle(.checkbox)
                }
            }
        }
    }

    // MARK: - Keyboard Shortcuts

    private var keyboardShortcutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Keyboard Shortcuts")
                .font(.headline)

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

    // MARK: - Menu Bar

    private var menuBarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Menu Bar")
                .font(.headline)

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

    // MARK: - Notifications

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notifications")
                .font(.headline)

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
        }
    }

    // MARK: - Helpers

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
}

// MARK: - Theme Card

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
        case .custom: return Color.purple.opacity(0.3)
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
            VStack(spacing: 4) {
                ZStack {
                    if theme == .transparent {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [3]))
                            .frame(height: 44)
                            .overlay(
                                Text("Aa")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(bgColor)
                            .frame(height: 44)
                            .overlay(
                                Text("Aa")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(textColor)
                            )
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                )

                Text(theme.rawValue)
                    .font(.caption2)
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

// MARK: - Animation Style Extension

extension LyricsAnimationStyle {
    var shortName: String {
        switch self {
        case .slideUp: return "Up"
        case .slideLeft: return "Left"
        case .slideRight: return "Right"
        case .fade: return "Fade"
        case .zoom: return "Zoom"
        case .blur: return "Blur"
        case .flip: return "Flip"
        }
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
        .frame(width: 420, height: 800)
}
