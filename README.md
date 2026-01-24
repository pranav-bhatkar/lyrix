# Lyrix

A macOS app that displays synchronized lyrics from Spotify and Apple Music in a beautiful floating overlay.

## Features

- **Real-time lyrics sync** - Lyrics scroll automatically with your music
- **Floating overlay** - A sleek, always-on-top window that stays visible while you work
- **Multiple animation styles** - Slide, zoom, blur, flip, fade, and more
- **Customizable appearance** - Themes, fonts, sizes, and glow effects
- **Multi-player support** - Works with both Spotify and Apple Music
- **Lyrics caching** - Fast loading with local cache

## How It Works

1. **Music Detection** - Lyrix uses AppleScript to poll Spotify and Apple Music every 2 seconds to detect what song is currently playing.

2. **Lyrics Fetching** - When a song is detected, Lyrix queries the LRCLib API to find matching lyrics. It supports both time-synced (LRC format) and plain lyrics.

3. **Synchronization** - For synced lyrics, Lyrix updates the playback position every 100ms and highlights the current line based on timestamps.

4. **Floating Display** - Lyrics are shown in a floating window that stays on top of other apps, with smooth animations as lines change.

## Requirements

- macOS 13.0 or later
- Spotify or Apple Music

## Building

Open `lyrix.xcodeproj` in Xcode and build the project (Cmd+B), or from the terminal:

```bash
xcodebuild -project lyrix.xcodeproj -scheme lyrix -configuration Release build
```

## License

This project is **open source** and **free to use** by anyone.

## Credits

Built by [Pranav Bhatkar](https://github.com/pranav-bhatkar) with Claude Code.
