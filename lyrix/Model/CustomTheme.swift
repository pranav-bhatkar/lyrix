//
//  CustomTheme.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 28/01/26.
//

import SwiftUI
import Combine

// MARK: - Custom Theme Model

struct CustomTheme: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var backgroundColor: CodableColor
    var backgroundOpacity: Double
    var currentLineColor: CodableColor
    var dimmedColor: CodableColor
    var glowColor: CodableColor
    var glowIntensity: Double
    var blurEnabled: Bool

    init(
        id: UUID = UUID(),
        name: String = "My Theme",
        backgroundColor: Color = Color(white: 0.1),
        backgroundOpacity: Double = 0.85,
        currentLineColor: Color = .white,
        dimmedColor: Color = Color(white: 0.55),
        glowColor: Color = .white,
        glowIntensity: Double = 0.5,
        blurEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.backgroundColor = CodableColor(backgroundColor)
        self.backgroundOpacity = backgroundOpacity
        self.currentLineColor = CodableColor(currentLineColor)
        self.dimmedColor = CodableColor(dimmedColor)
        self.glowColor = CodableColor(glowColor)
        self.glowIntensity = glowIntensity
        self.blurEnabled = blurEnabled
    }

    // Convenience accessors for SwiftUI Colors
    var bgColor: Color { backgroundColor.color }
    var textColor: Color { currentLineColor.color }
    var secondaryTextColor: Color { dimmedColor.color }
    var glow: Color { glowColor.color }
}

// MARK: - Codable Color Wrapper

struct CodableColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double

    init(_ color: Color) {
        let nsColor = NSColor(color).usingColorSpace(.deviceRGB) ?? NSColor.white
        self.red = Double(nsColor.redComponent)
        self.green = Double(nsColor.greenComponent)
        self.blue = Double(nsColor.blueComponent)
        self.opacity = Double(nsColor.alphaComponent)
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - Custom Theme Manager

@MainActor
class CustomThemeManager: ObservableObject {
    static let shared = CustomThemeManager()

    @Published var themes: [CustomTheme] = []
    @Published var activeCustomThemeId: UUID?

    private let savePath: URL

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let lyrixFolder = appSupport.appendingPathComponent("Lyrix", isDirectory: true)

        // Create directory if needed
        try? FileManager.default.createDirectory(at: lyrixFolder, withIntermediateDirectories: true)

        savePath = lyrixFolder.appendingPathComponent("custom_themes.json")
        loadThemes()

        // Load active theme ID from UserDefaults
        if let idString = UserDefaults.standard.string(forKey: "lyrics.customThemeId"),
           let uuid = UUID(uuidString: idString) {
            activeCustomThemeId = uuid
        }
    }

    // MARK: - Persistence

    func loadThemes() {
        guard FileManager.default.fileExists(atPath: savePath.path) else { return }

        do {
            let data = try Data(contentsOf: savePath)
            themes = try JSONDecoder().decode([CustomTheme].self, from: data)
        } catch {
            print("Failed to load custom themes: \(error)")
        }
    }

    func saveThemes() {
        do {
            let data = try JSONEncoder().encode(themes)
            try data.write(to: savePath)
        } catch {
            print("Failed to save custom themes: \(error)")
        }
    }

    // MARK: - Theme Management

    func addTheme(_ theme: CustomTheme) {
        themes.append(theme)
        saveThemes()
    }

    func updateTheme(_ theme: CustomTheme) {
        if let index = themes.firstIndex(where: { $0.id == theme.id }) {
            themes[index] = theme
            saveThemes()
        }
    }

    func deleteTheme(_ theme: CustomTheme) {
        themes.removeAll { $0.id == theme.id }
        if activeCustomThemeId == theme.id {
            activeCustomThemeId = nil
            LyricsSettings.shared.theme = "Dark"
        }
        saveThemes()
    }

    func setActiveTheme(_ theme: CustomTheme?) {
        activeCustomThemeId = theme?.id
        if let id = theme?.id {
            UserDefaults.standard.set(id.uuidString, forKey: "lyrics.customThemeId")
            LyricsSettings.shared.theme = "Custom"
        } else {
            UserDefaults.standard.removeObject(forKey: "lyrics.customThemeId")
        }
    }

    var activeTheme: CustomTheme? {
        guard let id = activeCustomThemeId else { return nil }
        return themes.first { $0.id == id }
    }
}
