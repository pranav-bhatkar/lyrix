//
//  LyricsSettings.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI
import Combine

// MARK: - Width Size Options

enum LyricsWindowSize: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"

    var width: CGFloat {
        switch self {
        case .small: return 400
        case .medium: return 550
        case .large: return 700
        }
    }
}

// MARK: - Theme Presets

enum LyricsTheme: String, CaseIterable {
    case dark = "Dark"
    case light = "Light"
    case subtle = "Subtle"
    case warm = "Warm"
    case cool = "Cool"
    case minimal = "Minimal"
    case transparent = "Transparent"
    case custom = "Custom"
}

/// User preferences for floating lyrics appearance
class LyricsSettings: ObservableObject {
    static let shared = LyricsSettings()

    // MARK: - Simple Settings

    @AppStorage("lyrics.windowSize") var windowSize: String = "Medium"
    @AppStorage("lyrics.theme") var theme: String = "Dark"
    @AppStorage("lyrics.animationStyle") var animationStyle: String = "Slide Up"
    @AppStorage("lyrics.animationSpeed") var animationSpeed: String = "Normal"
    @AppStorage("lyrics.showGlow") var showGlow: Bool = true
    @AppStorage("lyrics.cornerRadius") var customCornerRadius: Double = 16
    @AppStorage("lyrics.showPlayerInFloating") var showPlayerInFloating: Bool = false

    // MARK: - Slide Up Options
    @AppStorage("lyrics.showPreviousLine") var showPreviousLine: Bool = true
    @AppStorage("lyrics.showNextLine") var showNextLine: Bool = true

    // MARK: - Typography
    @AppStorage("lyrics.fontName") var fontName: String = "Default"
    @AppStorage("lyrics.fontSize") var fontSize: Double = 24
    @AppStorage("lyrics.fontSizePreset") var fontSizePreset: String = "L"

    // MARK: - Floating Window State
    @AppStorage("lyrics.floatingEnabled") var floatingEnabled: Bool = false

    // MARK: - Notifications
    @AppStorage("lyrics.showNowPlayingNotification") var showNowPlayingNotification: Bool = true

    // MARK: - Window Position (runtime only)
    @Published var windowX: CGFloat = 100
    @Published var windowY: CGFloat = 100

    private init() {}

    // MARK: - Computed Properties

    var windowWidth: CGFloat {
        (LyricsWindowSize(rawValue: windowSize) ?? .medium).width
    }

    var animationDuration: Double {
        switch animationSpeed {
        case "Slow": return 0.6
        case "Fast": return 0.25
        default: return 0.4
        }
    }

    // MARK: - Theme Colors

    private var customTheme: CustomTheme? {
        guard theme == "Custom" else { return nil }
        return CustomThemeManager.shared.activeTheme
    }

    var backgroundColor: Color {
        if let custom = customTheme { return custom.bgColor }
        switch theme {
        case "Light": return Color(white: 0.96)
        case "Subtle": return Color(red: 0.12, green: 0.12, blue: 0.14)
        case "Warm": return Color(red: 0.15, green: 0.1, blue: 0.08)
        case "Cool": return Color(red: 0.08, green: 0.1, blue: 0.15)
        case "Minimal": return Color.black
        case "Transparent": return .clear
        default: return Color(white: 0.1)
        }
    }

    var backgroundOpacity: Double {
        if let custom = customTheme { return custom.backgroundOpacity }
        switch theme {
        case "Minimal": return 0.6
        case "Transparent": return 0
        case "Subtle", "Warm", "Cool": return 0.92
        default: return 0.85
        }
    }

    var currentLineColor: Color {
        if let custom = customTheme { return custom.textColor }
        switch theme {
        case "Light": return .black
        case "Subtle": return Color(white: 0.95)
        case "Warm": return Color(red: 1.0, green: 0.85, blue: 0.7)
        case "Cool": return Color(red: 0.75, green: 0.9, blue: 1.0)
        case "Minimal", "Transparent": return .white
        default: return .white
        }
    }

    var dimmedColor: Color {
        if let custom = customTheme { return custom.secondaryTextColor }
        switch theme {
        case "Light": return Color(white: 0.45)
        case "Subtle": return Color(white: 0.45)
        case "Warm": return Color(red: 0.6, green: 0.5, blue: 0.4)
        case "Cool": return Color(red: 0.4, green: 0.5, blue: 0.6)
        case "Minimal", "Transparent": return Color(white: 0.5)
        default: return Color(white: 0.55)
        }
    }

    var glowColor: Color {
        if let custom = customTheme { return custom.glow }
        switch theme {
        case "Subtle": return Color(white: 0.6)
        case "Warm": return Color(red: 1.0, green: 0.6, blue: 0.3)
        case "Cool": return Color(red: 0.4, green: 0.7, blue: 1.0)
        case "Light", "Transparent": return .clear
        default: return currentLineColor
        }
    }

    var glowIntensity: Double {
        if let custom = customTheme { return custom.glowIntensity }
        return 0.5
    }

    var blurEnabled: Bool {
        if let custom = customTheme { return custom.blurEnabled }
        return theme != "Minimal" && theme != "Transparent"
    }

    var cornerRadius: CGFloat {
        CGFloat(customCornerRadius)
    }

    var isTransparent: Bool {
        theme == "Transparent"
    }

    var textShadowRadius: CGFloat {
        0  // No harsh shadow
    }

    // MARK: - Fonts

    var currentLineFont: Font {
        let size = CGFloat(fontSize)
        return getFont(size: size, weight: .bold)
    }

    var dimmedFont: Font {
        let size = CGFloat(fontSize * 0.82)
        return getFont(size: size, weight: .medium)
    }

    private func getFont(size: CGFloat, weight: Font.Weight) -> Font {
        switch fontName {
        case "Serif":
            return .system(size: size, weight: weight, design: .serif)
        case "Monospaced":
            return .system(size: size, weight: weight, design: .monospaced)
        case "Rounded":
            return .system(size: size, weight: weight, design: .rounded)
        default:
            return .system(size: size, weight: weight, design: .default)
        }
    }

    var lineSpacing: CGFloat {
        max(4, CGFloat(fontSize) * 0.3)
    }

    var lineHeight: CGFloat {
        CGFloat(fontSize) * 1.5
    }

    var horizontalPadding: CGFloat { 24 }
    var verticalPadding: CGFloat { 16 }
}
