# Changelog

All notable changes to Lyrix will be documented in this file.

## [1.1.0] - 2026-02-25

### New Features
- **Menu Bar Lyrics** — Current lyric line displayed right in your macOS menu bar with popover controls
- **Library Page** — Browse and manage your cached lyrics collection
- **Quick Actions** — Copy lyrics to clipboard, share as styled image, or jump to your music player
- **Global Keyboard Shortcuts** — Control playback and overlay from anywhere (play/pause, next/prev, seek ±10s)
- **Custom Theme Builder** — Create fully personalized themes with custom colors, opacity, and blur
- **Now Playing Notifications** — Get notified when the song changes
- **Desktop Widget** — See current track info on your desktop via macOS widget

### Improvements
- **Softer Theme Presets** — New Subtle, Warm, and Cool themes with refined color palettes
- **Typography Presets** — S/M/L/XL font size buttons replacing the old slider
- **Home View Redesign** — Album art display, sync status badge, loading states, and song change animations
- **Customize Tab Redesign** — Cleaner flat layout with logical sections
- **Dynamic About Page** — Version now reads from bundle instead of hardcoded string

## [1.0.2] - 2026-01-27

### Fixes
- Increment project version and update marketing version for release
- Update DMG creation process to include staging folder and symlink for Applications

## [1.0.1] - 2026-01-27

### Fixes
- Update macOS deployment target to 15.0
- Simplify build process by removing matrix configuration
- Update installation instructions for clarity
- Add AppIcon for better compatibility

## [1.0.0] - 2026-01-27

### Initial Release
- Synchronized lyrics display from Spotify and Apple Music
- Floating lyrics overlay with customizable themes
- Multiple animation styles (Fade, Slide Up, Karaoke, Typewriter)
- LRCLib.net lyrics provider integration
- File-based lyrics caching with 7-day expiry
- Onboarding flow and settings UI
