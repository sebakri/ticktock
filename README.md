# TickTock

TickTock is a modern, lightweight time-tracking application built specifically for macOS. Designed with a "Zero Gravity" aesthetic, it focuses on extreme efficiency through a powerful dual-shortcut system and a clean, minimalist interface.

![App Icon](assets/app_icon_128.png)

## Key Features

- **Zero Gravity UI:** A refined, modern interface that stays out of your way.
- **Global Hotkeys:** Control the app from anywhere in macOS.
- **Dual-Shortcut System:** Lightning-fast interaction for both your daily activity and your task library.
- **Smart Timeline:** Visualize your day with an interactive timeline and activity log.
- **Local-First:** All data is stored locally on your machine using SQLite.
- **Theme Sync:** Seamlessly switches between Light and Dark modes based on your system settings.
- **Window Persistence:** Remembers its position and size, and stays active in the background for continuous tracking.

## Keyboard Shortcuts

TickTock is built for power users. Master these shortcuts to track your time without touching your mouse.

### Global (Work Anywhere)
- `⌥ + Space`: Toggle Hide/Show App
- `⌥ + S`: Toggle Tracking

### App-Wide
- `⌘ + N`: New Task
- `⌘ + F`: Search Tasks
- `⌘ + S`: Toggle Tracking
- `⌘ + T`: Go to Today
- `⌘ + D`: Jump to Date
- `⌘ + 1-9`: Start tracking an activity task
- `⌘ + A-Z`: Open a library task for editing
- `Esc`: Clear search or unfocus
- `?`: Show help dialog

### Inside Task Modal
- `⌘ + S`: Start Tracking
- `⌘ + ⌫`: Delete Task
- `⌘ + ↵`: Save Changes

## Development

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Xcode (for macOS compilation)

### Running the App
```bash
flutter pub get
flutter run -d macos
```

## Releasing

TickTock uses GitHub Actions for automated releases. To create a new release:

1. Update the version in `pubspec.yaml`.
2. Create and push a new git tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. GitHub Actions will automatically build the macOS application, package it into a DMG, and create a new Release on GitHub.

---
Created with ❤️ by [sebakri](https://github.com/sebakri)