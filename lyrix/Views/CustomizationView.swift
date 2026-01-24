//
//  CustomizationView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI

struct CustomizationView: View {
    @ObservedObject var settings = LyricsSettings.shared
    
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
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 4) {
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
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Size")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    HStack {
                                        Slider(value: $settings.fontSize, in: 14...32, step: 1)
                                        Text("\(Int(settings.fontSize))pt")
                                            .font(.caption.monospacedDigit())
                                            .frame(width: 35)
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

#Preview {
    CustomizationView()
        .frame(width: 450, height: 750)
}
