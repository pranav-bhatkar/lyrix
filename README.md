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

## Installation

### Download

1. Go to [Releases](../../releases) and download:
   - **`lyrix.dmg`** (recommended) - Disk image, drag to Applications
   - **`lyrix.zip`** - Direct .app download
2. If using DMG: Open it and drag **Lyrix** to your **Applications** folder
3. If using ZIP: Extract and move **Lyrix.app** to **Applications**

### First Launch (Important)

Since Lyrix is distributed **unsigned** (no Apple Developer certificate), macOS will block it on first launch. Here's how to open it:

1. **Try to open Lyrix** - You'll see "Lyrix cannot be opened because it is from an unidentified developer"
2. Open **System Settings** → **Privacy & Security**
3. Scroll down to find **"Lyrix was blocked from use because it is not from an identified developer"**
4. Click **"Open Anyway"**
5. Click **"Open"** in the confirmation dialog

You only need to do this **once**. After that, Lyrix will open normally.

### First Run Permissions

On first launch, Lyrix will ask for **Automation permissions** to control Spotify/Apple Music. Click "OK" to allow - this is required for lyrics sync to work.

## Requirements

- macOS 13.0 (Ventura) or later
- Spotify or Apple Music

## Building from Source

Open `lyrix.xcodeproj` in Xcode and build the project (Cmd+B), or from the terminal:

```bash
xcodebuild -project lyrix.xcodeproj -scheme lyrix -configuration Release build
```

## License

This project is **open source** and **free to use** by anyone.

## Credits

Built by [Pranav Bhatkar](https://github.com/pranav-bhatkar) with Claude Code.
