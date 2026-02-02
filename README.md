# TickTock

TickTock is a modern, lightweight time-tracking application built specifically for macOS.

## Key Features

- **Global Hotkeys:** Control the app from anywhere in macOS.
- **Dual-Shortcut System:** Lightning-fast interaction for both your daily activity and your task library.
- **Smart Timeline:** Visualize your day with an interactive timeline and activity log.
- **Local-First:** All data is stored locally on your machine using SQLite.
- **Theme Sync:** Seamlessly switches between Light and Dark modes based on your system settings.

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

TickTock uses **Conventional Commits** and **Release Please** for automated versioning and releases.

1.  Commit your changes using conventional commit messages (e.g., `feat: add new feature`, `fix: resolve bug`).
2.  When you push to `main`, a "Release PR" will be automatically created or updated.
3.  Merging the Release PR will:
    *   Bump the version in `pubspec.yaml`.
    *   Generate a `CHANGELOG.md` entry.
    *   Create a GitHub Release and a git tag.
    *   Trigger a build and upload the macOS DMG.

---

Created with ❤️ by [sebakri](https://github.com/sebakri)
