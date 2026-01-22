import SwiftUI

@main
struct xBrewApp: App {
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var brew = HomebrewManager.shared
    @StateObject private var services = HomebrewServicesManager.shared

    var body: some Scene {
        // Main Window
        WindowGroup {
            ContentView()
                .environmentObject(localization)
                .environmentObject(settings)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1100, height: 700)
        .commands {
            CommandGroup(replacing: .newItem) {}

            // Custom Commands
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    Task { await brew.refreshOutdated() }
                }
                .keyboardShortcut("u", modifiers: [.command, .shift])
            }

            CommandMenu("Homebrew") {
                Button("Update Homebrew") {
                    Task { await brew.updateBrew() }
                }
                .keyboardShortcut("u", modifiers: .command)
                .disabled(brew.isUpdating)

                Button("Upgrade All Packages") {
                    Task { await brew.upgradeAll() }
                }
                .disabled(brew.isUpdating || brew.totalOutdated == 0)

                Divider()

                Button("Cleanup") {
                    Task { await brew.cleanup() }
                }
                .disabled(brew.isUpdating)

                Button("Health Check") {
                    Task { await brew.doctor() }
                }
                .disabled(brew.isUpdating)

                Divider()

                Button("Refresh All") {
                    Task { await brew.refreshAll(forceRefresh: true) }
                }
                .keyboardShortcut("r", modifiers: .command)
                .disabled(brew.isLoading)
            }
        }

        // Settings Window
        Settings {
            SettingsView()
                .environmentObject(localization)
                .environmentObject(settings)
        }

        // Menu Bar Extra - Window Style
        MenuBarExtra(isInserted: .constant(settings.showMenuBarIcon && settings.menuBarStyle == .window)) {
            MenuBarPanelView()
                .environmentObject(brew)
                .environmentObject(services)
                .environmentObject(settings)
        } label: {
            MenuBarIconLabel(outdatedCount: settings.showOutdatedBadge ? brew.totalOutdated : 0)
        }
        .menuBarExtraStyle(.window)

        // Menu Bar Extra - Menu Style
        MenuBarExtra(isInserted: .constant(settings.showMenuBarIcon && settings.menuBarStyle != .window)) {
            MenuBarMenuView()
                .environmentObject(brew)
                .environmentObject(services)
        } label: {
            MenuBarIconLabel(outdatedCount: settings.showOutdatedBadge ? brew.totalOutdated : 0)
        }
        .menuBarExtraStyle(.menu)
    }
}

// MARK: - Menu Bar Icon Label

struct MenuBarIconLabel: View {
    let outdatedCount: Int

    var body: some View {
        if outdatedCount > 0 {
            Label {
                Text("xBrew")
            } icon: {
                Image(systemName: "mug.fill")
                    .symbolRenderingMode(.hierarchical)
            }
            .badge(outdatedCount)
        } else {
            Label("xBrew", systemImage: "mug.fill")
        }
    }
}
