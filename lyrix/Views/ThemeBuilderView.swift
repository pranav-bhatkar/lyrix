//
//  ThemeBuilderView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 28/01/26.
//

import SwiftUI

struct ThemeBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var themeManager = CustomThemeManager.shared
    @ObservedObject var settings = LyricsSettings.shared

    @State private var editingTheme: CustomTheme
    @State private var isNewTheme: Bool

    init(theme: CustomTheme? = nil) {
        let themeToEdit = theme ?? CustomTheme()
        _editingTheme = State(initialValue: themeToEdit)
        _isNewTheme = State(initialValue: theme == nil)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(isNewTheme ? "New Theme" : "Edit Theme")
                        .font(.title3.bold())
                    Text("Customize colors and effects")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .padding(20)

            Divider()

            // Content
            HStack(spacing: 0) {
                // Left: Preview
                VStack(spacing: 16) {
                    Text("Preview")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ZStack {
                        // Simulated desktop
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        // Theme preview window
                        VStack(spacing: 6) {
                            Text("Previous line")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(editingTheme.secondaryTextColor)
                                .opacity(0.5)

                            Text("Current lyrics")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(editingTheme.textColor)
                                .shadow(
                                    color: settings.showGlow ? editingTheme.glow.opacity(editingTheme.glowIntensity) : .clear,
                                    radius: 8
                                )

                            Text("Next line")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(editingTheme.secondaryTextColor)
                                .opacity(0.5)
                        }
                        .padding(20)
                        .frame(width: 180)
                        .background(
                            ZStack {
                                if editingTheme.blurEnabled {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                }
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(editingTheme.bgColor.opacity(editingTheme.backgroundOpacity))
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Spacer()
                }
                .padding(20)
                .frame(width: 240)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))

                Divider()

                // Right: Controls
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            TextField("My Theme", text: $editingTheme.name)
                                .textFieldStyle(.roundedBorder)
                        }

                        Divider()

                        // Background
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Background")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)

                            colorRow("Color", color: Binding(
                                get: { editingTheme.bgColor },
                                set: { editingTheme.backgroundColor = CodableColor($0) }
                            ))

                            HStack {
                                Text("Opacity")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(Int(editingTheme.backgroundOpacity * 100))%")
                                    .font(.caption.monospacedDigit())
                                    .foregroundColor(.secondary)
                                    .frame(width: 36)
                            }
                            Slider(value: $editingTheme.backgroundOpacity, in: 0...1)

                            Toggle("Blur Effect", isOn: $editingTheme.blurEnabled)
                                .font(.subheadline)
                        }

                        Divider()

                        // Text Colors
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Text")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)

                            colorRow("Current Line", color: Binding(
                                get: { editingTheme.textColor },
                                set: { editingTheme.currentLineColor = CodableColor($0) }
                            ))

                            colorRow("Other Lines", color: Binding(
                                get: { editingTheme.secondaryTextColor },
                                set: { editingTheme.dimmedColor = CodableColor($0) }
                            ))
                        }

                        Divider()

                        // Glow
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Glow")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)

                            colorRow("Color", color: Binding(
                                get: { editingTheme.glow },
                                set: { editingTheme.glowColor = CodableColor($0) }
                            ))

                            HStack {
                                Text("Intensity")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(Int(editingTheme.glowIntensity * 100))%")
                                    .font(.caption.monospacedDigit())
                                    .foregroundColor(.secondary)
                                    .frame(width: 36)
                            }
                            Slider(value: $editingTheme.glowIntensity, in: 0...1)
                        }
                    }
                    .padding(20)
                }
                .frame(width: 260)
            }

            Divider()

            // Footer
            HStack {
                if !isNewTheme {
                    Button("Delete", role: .destructive) {
                        themeManager.deleteTheme(editingTheme)
                        dismiss()
                    }
                }

                Spacer()

                Button("Cancel") { dismiss() }

                Button(isNewTheme ? "Create" : "Save") {
                    if isNewTheme {
                        themeManager.addTheme(editingTheme)
                    } else {
                        themeManager.updateTheme(editingTheme)
                    }
                    themeManager.setActiveTheme(editingTheme)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(editingTheme.name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(16)
        }
        .frame(width: 520, height: 480)
    }

    private func colorRow(_ title: String, color: Binding<Color>) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            ColorPicker("", selection: color, supportsOpacity: false)
                .labelsHidden()
        }
    }
}

#Preview {
    ThemeBuilderView()
}
