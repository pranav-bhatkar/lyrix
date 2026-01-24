# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build from command line
xcodebuild -project lyrix.xcodeproj -scheme lyrix -configuration Debug build

# Build release
xcodebuild -project lyrix.xcodeproj -scheme lyrix -configuration Release build
```

Typically built through Xcode: open `lyrix.xcodeproj`.

## Architecture

Lyrix is a macOS SwiftUI app displaying synchronized lyrics from Spotify/Apple Music in a floating window. MVVM architecture with service layer.

### Data Flow

```
NowPlayingService (AppleScript polling) → LyricsViewModel (Combine) → Views
                                              ↓
                                    LyricsManager → LyricProviders → LyricsCache
```

### Key Components

- **LyricsViewModel** (`Presentation/`): Central state. Observes NowPlayingService, coordinates fetching, exposes `@Published` properties.
- **NowPlayingService** (`Services/`): Polls Music.app/Spotify via `NSAppleScript` (2s for songs, 100ms for position).
- **LyricProvider protocol** (`Services/LyricProvider.swift`): Interface for lyrics sources. Implement to add providers.
- **LRCLibProvider**: Default provider, fetches from LRCLib.net API.
- **LyricsCache**: File-based JSON cache, 7-day expiry.
- **FloatingLyricsManager**: Manages floating NSWindow with animation styles.

### Settings

`@AppStorage` with `lyrics.*` keys. See `LyricsSettings.swift`.

## Entitlements

Required in `lyrix.entitlements`:
- Sandbox disabled (AppleScript access)
- Apple Events automation (playback control)
- Network client (API requests)

## Adding a Lyrics Provider

1. Conform to `LyricProvider` protocol
2. Register in `LyricsManager.init()` providers array
3. Add case to `LyricSource` enum
