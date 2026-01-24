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
    case neon = "Neon"
    case minimal = "Minimal"
    case transparent = "Transparent"
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
    @AppStorage("lyrics.fontSize") var fontSize: Double = 22
    
    // MARK: - Floating Window State
    @AppStorage("lyrics.floatingEnabled") var floatingEnabled: Bool = false
    
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
    
    var backgroundColor: Color {
        switch theme {
        case "Light": return Color(white: 0.95)
        case "Neon": return Color(red: 0.05, green: 0.02, blue: 0.15)
        case "Minimal": return Color.black
        case "Transparent": return .clear
        default: return Color(white: 0.1)
        }
    }
    
    var backgroundOpacity: Double {
        switch theme {
        case "Minimal": return 0.6
        case "Transparent": return 0
        default: return 0.85
        }
    }
    
    var currentLineColor: Color {
        switch theme {
        case "Light": return .black
        case "Neon": return Color(red: 0, green: 1, blue: 0.8)
        case "Minimal", "Transparent": return .white
        default: return .white
        }
    }
    
    var dimmedColor: Color {
        switch theme {
        case "Light": return Color(white: 0.4)
        case "Neon": return Color(red: 0.4, green: 0.5, blue: 0.6)
        case "Minimal", "Transparent": return Color(white: 0.5)
        default: return Color(white: 0.55)
        }
    }
    
    var glowColor: Color {
        switch theme {
        case "Neon": return Color(red: 0, green: 1, blue: 0.8)
        case "Light": return .clear
        case "Transparent": return .clear
        default: return currentLineColor
        }
    }
    
    var blurEnabled: Bool {
        theme != "Minimal" && theme != "Transparent"
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
