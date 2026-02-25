# Lyrix - Feature Ideas & Improvements

## Appearance & Typography

### 1. Simplify the Preset System

- [x] Add softer presets: "Subtle", "Warm", "Cool" with muted colors _(branch: `feature/softer-themes`)_
- [x] Remove Neon theme (replaced with softer alternatives) _(branch: `feature/softer-themes`)_
- [x] Add a "Custom" option for user-defined colors (text, background, glow) _(branch: `feature/custom-theme-builder`)_

### 2. Typography Simplification

- [x] Replace slider with size presets: S / M / L / XL buttons (16pt, 20pt, 24pt, 28pt) _(branch: `feature/typography-presets`)_
- [ ] ~~Or keep slider but add "Quick Sizes" buttons for common sizes~~ (chose presets approach)
- [x] Group font + size together with visual preview grid _(branch: `feature/menubar-lyrics`)_

### 3. Glow Control Improvements

- [x] Add glow intensity slider (subtle → strong) _(branch: `feature/custom-theme-builder`)_
- [x] Separate glow color from text color _(branch: `feature/custom-theme-builder`)_

---

## New Features / Pages

### 4. Custom Theme Builder (New Page)

- [x] Dedicated "Create Theme" sheet/modal _(branch: `feature/custom-theme-builder`)_
- [x] Color picker for background _(branch: `feature/custom-theme-builder`)_
- [x] Color picker for text (current line, dimmed lines) _(branch: `feature/custom-theme-builder`)_
- [x] Color picker for glow + intensity control _(branch: `feature/custom-theme-builder`)_
- [x] Save custom presets with names _(branch: `feature/custom-theme-builder`)_
- [x] Manage/delete custom themes _(branch: `feature/custom-theme-builder`)_

### 5. Lyrics Search / Library Page

- [x] Dedicated "Library" tab in sidebar _(branch: `feature/menubar-lyrics`)_
- [x] Show recently played songs with cached lyrics _(branch: `feature/menubar-lyrics`)_
- [x] Browse/manage cached lyrics _(branch: `feature/menubar-lyrics`)_
- [ ] Favorite lyrics for songs

### 6. Keyboard Shortcuts Settings

- [x] Global hotkey to show/hide floating window _(branch: `feature/keyboard-shortcuts`)_
- [x] Hotkey to skip to next/previous song _(branch: `feature/keyboard-shortcuts`)_
- [x] Hotkey to toggle play/pause _(branch: `feature/keyboard-shortcuts`)_
- [x] Hotkey to seek +10s/-10s _(branch: `feature/keyboard-shortcuts`)_

### 7. Display Modes

- [x] Menu bar lyrics: Show current line in macOS menu bar _(branch: `feature/menubar-lyrics`)_
- [x] Menu bar popover with album art, song info, and playback controls _(branch: `feature/menubar-lyrics`)_
- [x] Desktop widget using WidgetKit for macOS _(branch: `feature/now-playing-notification`)_
- [x] Now Playing notification when song changes _(branch: `feature/now-playing-notification`)_

### 8. Simplify the Customize Tab

- [x] Collapsible Advanced section for glow, corner radius, show lines _(branch: `feature/menubar-lyrics`)_
- [x] Visual-first design: Big live preview at top, minimal controls below _(existing)_
- [x] Hide advanced options by default (e.g., "Show Previous/Next Line" toggles) _(branch: `feature/menubar-lyrics`)_

---

## Home Page Improvements

### 9. Cleaner Layout

- [x] Make album art bigger (110×110 with shadow) _(branch: `feature/home-improvements`)_
- [x] Add subtle animation when song changes _(branch: `feature/home-improvements`)_
- [x] Show lyrics sync status (synced vs plain) more prominently _(branch: `feature/home-improvements`)_
- [x] Show loading state when fetching new lyrics (spinner badge + loading view) _(branch: `feature/home-improvements`)_

### 10. Quick Actions Bar

- [x] Copy current lyrics to clipboard _(branch: `feature/quick-actions`)_
- [x] Share lyrics as image _(branch: `feature/quick-actions`)_
- [x] Open song in Music/Spotify _(branch: `feature/quick-actions`)_
- [x] Report wrong lyrics _(branch: `feature/menubar-lyrics`)_

---

## Priority (Top 3) - COMPLETED

1. **Custom Theme Builder** - ✅ Done _(branch: `feature/custom-theme-builder`)_
2. **Typography Presets (S/M/L/XL)** - ✅ Done _(branch: `feature/typography-presets`)_
3. **Menu Bar Lyrics Display** - ✅ Done _(branch: `feature/menubar-lyrics`)_

---

## Feature Branches

| Branch                         | Status   | Description                             |
| ------------------------------ | -------- | --------------------------------------- |
| `feature/menubar-lyrics`       | ✅ Ready | Menu bar lyrics with popover controls   |
| `feature/typography-presets`   | ✅ Ready | S/M/L/XL font size buttons              |
| `feature/custom-theme-builder` | ✅ Ready | Custom theme creator with color pickers |
| `feature/keyboard-shortcuts`   | ✅ Ready | Global hotkeys + seek ±10s              |
| `feature/quick-actions`        | ✅ Ready | Copy lyrics, share image, open player   |
| `feature/home-improvements`    | ✅ Ready | Album art, sync badge, loading state, song animation |
| `feature/now-playing-notification` | ✅ Ready | Notification + WidgetKit desktop widget |

---

## Visual Observations (from Screenshots)

### Home Page

- Lyrics list with timestamps looks clean
- Orange accent color is consistent and nice
- Album art (80×80) could be larger for better visual impact

### Customize Page

- Theme buttons are small - hard to preview what you'll get
- Neon preview shows cyan on dark purple - very bold/gamer aesthetic
- ~~Font size slider is subtle - preset buttons would be more intuitive~~ ✅ Fixed with S/M/L/XL presets
- Live preview is helpful but could be bigger

### Floating Window (Neon Theme)

- Dark purple/blue background with cyan controls
- White lyrics text is readable
- Overall "gamer aesthetic" - softer themes needed for users who want minimal
- Rounded corners and glow look good

### About Page

- Clean and simple - no changes needed

---

## Notes

- Current themes: Dark, Light, Neon, Minimal, Transparent, **Custom**
- Current animations: Slide Up, Slide Left, Slide Right, Zoom, Blur, 3D Flip, Fade
- Font families: Sans (Default), Serif, Rounded, Monospaced
- ~~Font size range: 14-32pt~~ → Font sizes: S (16pt), M (20pt), L (24pt), XL (28pt)
