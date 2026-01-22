# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Generate Xcode project from project.yml (requires xcodegen)
xcodegen generate

# Build with xcodebuild
xcodebuild -project xBrew.xcodeproj -scheme xBrew -configuration Debug build

# Run the built app
open ~/Library/Developer/Xcode/DerivedData/xBrew-*/Build/Products/Debug/xBrew.app

# Or open in Xcode and use Cmd+R
open xBrew.xcodeproj
```

## Requirements

- macOS 13.0+ (Ventura)
- Xcode 15.0+
- Swift 5.0+

## Architecture Overview

**xBrew** is a SwiftUI macOS app for managing Homebrew packages, casks, taps, and services.

### Singleton Services Pattern

All managers use singleton pattern with `shared` instances, injected via `@StateObject`:

```swift
@StateObject private var brew = HomebrewManager.shared
@StateObject private var settings = SettingsManager.shared
@StateObject private var services = HomebrewServicesManager.shared
```

### Core Services (in `Services/`)

| Service | Purpose |
|---------|---------|
| `HomebrewManager` | Core package/cask operations, caching, search |
| `HomebrewManager+Commands` | Brew command execution (runs on background thread) |
| `HomebrewManager+Packages` | Install, uninstall, upgrade operations |
| `HomebrewManager+Taps` | Tap management |
| `HomebrewServicesManager` | Background service start/stop |
| `SettingsManager` | Persistent settings via `@AppStorage` |
| `BrewfileManager` | Brewfile import/export, iCloud sync |
| `LocalizationManager` | i18n (Vietnamese, English) |
| `AppConfig` | Centralized configuration constants |

### Navigation

Uses `NavigationSplitView` with enum-based navigation (`NavigationItem` in `Models/NavigationState.swift`):
- overview, formulas, casks, services, taps, maintenance

### Design System

Centralized in `Views/Components/DesignSystem.swift`:
- Colors: `.ds.primary`, `.ds.success`, `.ds.warning`, etc.
- Typography: `DesignSystem.Typography.body`, `.title1`, etc.
- Spacing: `DesignSystem.Spacing.sm`, `.md`, `.lg`

### Menu Bar Extra

Two styles configured in `xBrewApp.swift`:
- Window style (rich panel UI) - `MenuBarPanelView`
- Menu style (simple dropdown) - `MenuBarMenuView`

## Key Patterns

### Async Command Execution

Brew commands must run on background thread to avoid UI freeze:

```swift
// In HomebrewManager+Commands.swift
func runBrewCommand(_ args: [String]) async -> String? {
    return await Task.detached(priority: .userInitiated) {
        // blocking operations here
    }.value
}
```

### ProgressView Fix

Always add `.frame()` to `ProgressView()` to avoid macOS layout warnings:

```swift
ProgressView().frame(width: 16, height: 16)
```

### SettingsLink Compatibility

`SettingsLink` requires macOS 14.0+, use availability check:

```swift
if #available(macOS 14.0, *) {
    SettingsLink { ... }
} else {
    Button { NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil) } label: { ... }
}
```

## Configuration

Key settings in `AppConfig.swift`:
- Brew paths: `/opt/homebrew/bin/brew` (Apple Silicon), `/usr/local/bin/brew` (Intel)
- Command timeout: 300 seconds
- iCloud container: `iCloud.asia.xdev.xBrew`

## Localization

Strings in `Resources/Localizations/`:
- `en.lproj/Localizable.strings`
- `vi.lproj/Localizable.strings`

Access via `LocalizationManager.shared.localizedString(for:)` or the `L()` helper.
