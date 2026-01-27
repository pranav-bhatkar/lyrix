//
//  FloatingLyricsView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI
import Combine

// MARK: - Animation Style

enum LyricsAnimationStyle: String, CaseIterable {
    case slideUp = "Slide Up"
    case slideLeft = "Slide Left"
    case slideRight = "Slide Right"
    case zoom = "Zoom"
    case blur = "Blur"
    case flip = "3D Flip"
    case fade = "Fade"
}

// MARK: - Main Floating View

struct FloatingLyricsView: View {
    @ObservedObject var viewModel: LyricsViewModel
    @ObservedObject var settings = LyricsSettings.shared
    
    var body: some View {
        ZStack {
            // Background
            backgroundView
            
            // Content
            VStack(spacing: 0) {
                // Music Player Header (Optional)
                if settings.showPlayerInFloating, let song = viewModel.currentSong {
                    playerHeader(song: song)
                        .padding(.bottom, 12)
                }
                
                // Lyrics Content
                VStack(spacing: 0) {
                    if let lyrics = viewModel.lyrics, lyrics.isSynced {
                        animatedContent(lyrics: lyrics)
                    } else if viewModel.currentSong != nil {
                        if viewModel.isLoading {
                            LoadingDotsView(color: settings.currentLineColor)
                        } else {
                            staticText("Lyrics not found", dimmed: true)
                        }
                    } else {
                        staticText("♪ Play a song ♪", dimmed: true)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, settings.horizontalPadding)
            .padding(.vertical, settings.verticalPadding)
        }
        .frame(width: settings.windowWidth)
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: settings.cornerRadius))
    }
    
    @ViewBuilder
    private func playerHeader(song: Song) -> some View {
        HStack(spacing: 12) {
            // Artwork
            ZStack {
                if let artwork = song.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.2))
                    
                    Image(systemName: "music.note")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Song Info
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(settings.currentLineColor)
                
                Text(song.artist)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(settings.dimmedColor)
            }
            
            Spacer()
            
            // Controls
            HStack(spacing: 16) {
                Button(action: { viewModel.openActivePlayer() }) {
                    Image(systemName: "arrow.up.right.square")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .help("Open in \(viewModel.activePlayer ?? "App")")
                
                Button(action: { viewModel.playPause() }) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                
                Button(action: { viewModel.nextTrack() }) {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            .foregroundColor(settings.currentLineColor)
            .padding(.trailing, 4)
        }
        .padding(8)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func animatedContent(lyrics: Lyrics) -> some View {
        let style = LyricsAnimationStyle(rawValue: settings.animationStyle) ?? .slideUp
        
        switch style {
        case .slideUp:
            SlideUpView(lyrics: lyrics, currentIndex: viewModel.currentLineIndex, settings: settings)
        case .slideLeft, .slideRight:
            SlideHorizontalView(
                lyrics: lyrics,
                currentIndex: viewModel.currentLineIndex,
                settings: settings,
                fromLeft: style == .slideLeft
            )
        case .zoom:
            ZoomView(lyrics: lyrics, currentIndex: viewModel.currentLineIndex, settings: settings)
        case .blur:
            BlurFadeView(lyrics: lyrics, currentIndex: viewModel.currentLineIndex, settings: settings)
        case .flip:
            FlipView(lyrics: lyrics, currentIndex: viewModel.currentLineIndex, settings: settings)
        case .fade:
            FadeView(lyrics: lyrics, currentIndex: viewModel.currentLineIndex, settings: settings)
        }
    }
    
    private func staticText(_ text: String, dimmed: Bool) -> some View {
        Text(text)
            .font(dimmed ? settings.dimmedFont : settings.currentLineFont)
            .foregroundColor(dimmed ? settings.dimmedColor.opacity(0.6) : settings.currentLineColor)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if !settings.isTransparent {
            ZStack {
                if settings.blurEnabled {
                    VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                }
                settings.backgroundColor.opacity(settings.backgroundOpacity)
            }
        }
    }
}

// MARK: - Slide Up Animation

struct SlideUpView: View {
    let lyrics: Lyrics
    let currentIndex: Int?
    let settings: LyricsSettings

    // Calculate number of visible lines based on settings
    private var visibleLineCount: Int {
        var count = 1 // Current line is always visible
        if settings.showPreviousLine { count += 1 }
        if settings.showNextLine { count += 1 }
        return count
    }

    // Calculate the offset for centering based on which lines are visible
    private var centeringOffset: CGFloat {
        if settings.showPreviousLine && settings.showNextLine {
            return 1 // Center position (prev, CURRENT, next)
        } else if settings.showPreviousLine {
            return 1 // Show at bottom (prev, CURRENT)
        } else if settings.showNextLine {
            return 0 // Show at top (CURRENT, next)
        } else {
            return 0 // Only current line
        }
    }

    var body: some View {
        let currentIdx = currentIndex ?? -1
        let spacing = settings.lineSpacing
        let lineHeight = settings.lineHeight
        let totalLineHeight = lineHeight + spacing
        let frameHeight = totalLineHeight * CGFloat(visibleLineCount) - spacing

        GeometryReader { geo in
            VStack(spacing: spacing) {
                // Intro placeholder
                lineView(text: "♪ ♪ ♪", isCurrent: currentIdx == -1, isPast: false, height: lineHeight)
                    .frame(height: lineHeight)
                    .opacity(currentIdx == -1 || settings.showPreviousLine ? 1 : 0)

                ForEach(Array(lyrics.lines.enumerated()), id: \.element.id) { index, line in
                    let isCurrent = index == currentIdx
                    let isPast = index < currentIdx
                    let isVisible = isCurrent || (isPast && settings.showPreviousLine) || (!isPast && settings.showNextLine)

                    lineView(text: line.text, isCurrent: isCurrent, isPast: isPast, height: lineHeight)
                        .frame(height: lineHeight)
                        .opacity(isVisible ? 1 : 0)
                }
            }
            .frame(width: geo.size.width)
            .offset(y: -CGFloat(currentIdx + 1) * totalLineHeight + totalLineHeight * centeringOffset)
        }
        .frame(height: frameHeight)
        .clipped()
        .animation(.spring(response: settings.animationDuration, dampingFraction: 0.82), value: currentIndex)
    }

    private func lineView(text: String, isCurrent: Bool, isPast: Bool, height: CGFloat) -> some View {
        Text(text)
            .font(isCurrent ? settings.currentLineFont : settings.dimmedFont)
            .fontWeight(isCurrent ? .bold : .medium)
            .foregroundColor(isCurrent ? settings.currentLineColor : settings.dimmedColor)
            .opacity(isCurrent ? 1.0 : (isPast ? 0.4 : 0.5))
            .shadow(
                color: isCurrent && settings.showGlow ? settings.glowColor.opacity(0.5) : .clear,
                radius: 10
            )
            .scaleEffect(isCurrent ? 1.05 : 1.0)
            .lineLimit(nil)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(height: height)
            .animation(.spring(response: settings.animationDuration, dampingFraction: 0.8), value: isCurrent)
    }
}

// MARK: - Slide Horizontal Animation

struct SlideHorizontalView: View {
    let lyrics: Lyrics
    let currentIndex: Int?
    let settings: LyricsSettings
    let fromLeft: Bool
    
    private var currentText: String {
        guard let idx = currentIndex, idx < lyrics.lines.count else { return "♪ ♪ ♪" }
        return lyrics.lines[idx].text
    }
    
    var body: some View {
        ZStack {
            Text(currentText)
                .id(currentText)
                .font(settings.currentLineFont)
                .fontWeight(.bold)
                .foregroundColor(settings.currentLineColor)
                .shadow(
                    color: settings.showGlow ? settings.glowColor.opacity(0.5) : .clear,
                    radius: 12
                )
                .transition(horizontalTransition)
        }
        .lineLimit(nil)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .animation(.spring(response: settings.animationDuration, dampingFraction: 0.8), value: currentText)
    }
    
    private var horizontalTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: fromLeft ? .trailing : .leading)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.9)),
            removal: .move(edge: fromLeft ? .leading : .trailing)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 1.1))
        )
    }
}

// MARK: - Zoom Animation

struct ZoomView: View {
    let lyrics: Lyrics
    let currentIndex: Int?
    let settings: LyricsSettings
    
    private var currentText: String {
        guard let idx = currentIndex, idx < lyrics.lines.count else { return "♪ ♪ ♪" }
        return lyrics.lines[idx].text
    }
    
    var body: some View {
        ZStack {
            Text(currentText)
                .id(currentText)
                .font(settings.currentLineFont)
                .fontWeight(.bold)
                .foregroundColor(settings.currentLineColor)
                .shadow(
                    color: settings.showGlow ? settings.glowColor.opacity(0.5) : .clear,
                    radius: 12
                )
                .transition(.zoom)
        }
        .lineLimit(nil)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .animation(.spring(response: settings.animationDuration, dampingFraction: 0.75), value: currentText)
    }
}

extension AnyTransition {
    static var zoom: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.5).combined(with: .opacity),
            removal: .scale(scale: 1.5).combined(with: .opacity)
        )
    }
    
    static var blurFade: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .modifier(
                active: BlurModifier(radius: 10, scale: 0.9),
                identity: BlurModifier(radius: 0, scale: 1.0)
            )),
            removal: .opacity.combined(with: .modifier(
                active: BlurModifier(radius: 10, scale: 1.1),
                identity: BlurModifier(radius: 0, scale: 1.0)
            ))
        )
    }
    
    static var flip3D: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .modifier(
                active: Flip3DModifier(angle: 90),
                identity: Flip3DModifier(angle: 0)
            )),
            removal: .opacity.combined(with: .modifier(
                active: Flip3DModifier(angle: -90),
                identity: Flip3DModifier(angle: 0)
            ))
        )
    }
}

struct BlurModifier: ViewModifier {
    let radius: CGFloat
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .blur(radius: radius)
            .scaleEffect(scale)
    }
}

struct Flip3DModifier: ViewModifier {
    let angle: Double
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(angle), axis: (x: 1, y: 0, z: 0))
    }
}

// MARK: - Blur Animation

struct BlurFadeView: View {
    let lyrics: Lyrics
    let currentIndex: Int?
    let settings: LyricsSettings
    
    private var currentText: String {
        guard let idx = currentIndex, idx < lyrics.lines.count else { return "♪ ♪ ♪" }
        return lyrics.lines[idx].text
    }
    
    var body: some View {
        ZStack {
            Text(currentText)
                .id(currentText)
                .font(settings.currentLineFont)
                .fontWeight(.bold)
                .foregroundColor(settings.currentLineColor)
                .shadow(
                    color: settings.showGlow ? settings.glowColor.opacity(0.5) : .clear,
                    radius: 12
                )
                .transition(.blurFade)
        }
        .lineLimit(nil)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: settings.animationDuration), value: currentText)
    }
}

// MARK: - Flip Animation

struct FlipView: View {
    let lyrics: Lyrics
    let currentIndex: Int?
    let settings: LyricsSettings
    
    private var currentText: String {
        guard let idx = currentIndex, idx < lyrics.lines.count else { return "♪ ♪ ♪" }
        return lyrics.lines[idx].text
    }
    
    var body: some View {
        ZStack {
            Text(currentText)
                .id(currentText)
                .font(settings.currentLineFont)
                .fontWeight(.bold)
                .foregroundColor(settings.currentLineColor)
                .shadow(
                    color: settings.showGlow ? settings.glowColor.opacity(0.5) : .clear,
                    radius: 12
                )
                .transition(.flip3D)
        }
        .lineLimit(nil)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .animation(.spring(response: settings.animationDuration, dampingFraction: 0.7), value: currentText)
    }
}

// MARK: - Fade Animation

struct FadeView: View {
    let lyrics: Lyrics
    let currentIndex: Int?
    let settings: LyricsSettings
    
    private var currentText: String {
        guard let idx = currentIndex, idx < lyrics.lines.count else { return "♪ ♪ ♪" }
        return lyrics.lines[idx].text
    }
    
    var body: some View {
        ZStack {
            Text(currentText)
                .id(currentText)
                .font(settings.currentLineFont)
                .fontWeight(.bold)
                .foregroundColor(settings.currentLineColor)
                .shadow(
                    color: settings.showGlow ? settings.glowColor.opacity(0.5) : .clear,
                    radius: 12
                )
                .transition(.opacity)
        }
        .lineLimit(nil)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .animation(.linear(duration: settings.animationDuration), value: currentText)
    }
}

// MARK: - Loading Dots

struct LoadingDotsView: View {
    let color: Color
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .offset(y: animating ? -8 : 0)
                    .animation(
                        .easeInOut(duration: 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.12),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

// MARK: - Visual Effect Blur

struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

// MARK: - Window Controller

class FloatingLyricsWindowController: NSWindowController {
    private var viewModel: LyricsViewModel?
    
    convenience init(viewModel: LyricsViewModel) {
        let window = FloatingLyricsWindow()
        self.init(window: window)
        self.viewModel = viewModel
        
        let hostingView = NSHostingView(rootView: FloatingLyricsView(viewModel: viewModel))
        window.contentView = hostingView
        
        // Center at bottom of screen
        if let screen = NSScreen.main {
            let frame = screen.visibleFrame
            let x = frame.midX - LyricsSettings.shared.windowWidth / 2
            window.setFrameOrigin(NSPoint(x: x, y: frame.origin.y + 60))
        }
    }
    
    func show() {
        window?.alphaValue = 0
        window?.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.25
            window?.animator().alphaValue = 1
        }
    }
    
    func hide() {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.2
            window?.animator().alphaValue = 0
        }, completionHandler: {
            self.window?.orderOut(nil)
        })
    }
    
    func toggle() {
        window?.isVisible == true ? hide() : show()
    }
}

// MARK: - Floating Window

class FloatingLyricsWindow: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 150),
            styleMask: [.borderless, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isMovableByWindowBackground = true

        // Prevent this panel from activating the app
        hidesOnDeactivate = false
        becomesKeyOnlyIfNeeded = true
    }

    // Allow the panel to receive key events for buttons without activating the app
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

// MARK: - Manager

@MainActor
class FloatingLyricsManager: ObservableObject {
    static let shared = FloatingLyricsManager()
    
    @Published var isVisible = false
    private var windowController: FloatingLyricsWindowController?
    
    private init() {}
    
    func setup(viewModel: LyricsViewModel) {
        // Only create window controller once - avoid creating duplicate windows
        guard windowController == nil else { return }
        windowController = FloatingLyricsWindowController(viewModel: viewModel)
    }
    
    func show() {
        windowController?.show()
        isVisible = true
        LyricsSettings.shared.floatingEnabled = true
    }
    
    func hide() {
        windowController?.hide()
        isVisible = false
        LyricsSettings.shared.floatingEnabled = false
    }
    
    func toggle() {
        isVisible ? hide() : show()
    }
}
