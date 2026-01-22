import SwiftUI
import Combine
import ServiceManagement

/// Menu bar display style
enum MenuBarStyle: String, CaseIterable {
    case window = "window"
    case menu = "menu"

    var displayName: String {
        switch self {
        case .window: return "Panel (Rich UI)"
        case .menu: return "Menu (Simple)"
        }
    }

    var icon: String {
        switch self {
        case .window: return "macwindow"
        case .menu: return "list.bullet"
        }
    }
}

/// Update check interval options
enum UpdateCheckInterval: Double, CaseIterable {
    case fifteenMinutes = 900
    case thirtyMinutes = 1800
    case oneHour = 3600
    case threeHours = 10800
    case sixHours = 21600
    case daily = 86400

    var displayName: String {
        switch self {
        case .fifteenMinutes: return "15 minutes"
        case .thirtyMinutes: return "30 minutes"
        case .oneHour: return "1 hour"
        case .threeHours: return "3 hours"
        case .sixHours: return "6 hours"
        case .daily: return "Daily"
        }
    }
}

/// Centralized settings manager with persistent storage
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    // MARK: - General Settings

    /// Launch app at login
    @AppStorage("launchAtLogin") var launchAtLogin = false {
        didSet {
            updateLaunchAtLogin()
        }
    }

    /// Show menu bar icon
    @AppStorage("showMenuBarIcon") var showMenuBarIcon = true

    /// Menu bar display style (window or menu)
    @AppStorage("menuBarStyle") var menuBarStyleRaw = MenuBarStyle.window.rawValue

    var menuBarStyle: MenuBarStyle {
        get { MenuBarStyle(rawValue: menuBarStyleRaw) ?? .window }
        set { menuBarStyleRaw = newValue.rawValue }
    }

    /// Show badge on menu bar icon for outdated packages
    @AppStorage("showOutdatedBadge") var showOutdatedBadge = true

    // MARK: - Homebrew Settings

    /// Automatically check for updates
    @AppStorage("autoCheckUpdates") var autoCheckUpdates = true

    /// Update check interval in seconds
    @AppStorage("updateCheckInterval") var updateCheckIntervalRaw: Double = UpdateCheckInterval.oneHour.rawValue

    var updateCheckInterval: UpdateCheckInterval {
        get { UpdateCheckInterval(rawValue: updateCheckIntervalRaw) ?? .oneHour }
        set { updateCheckIntervalRaw = newValue.rawValue }
    }

    /// Auto cleanup after updates
    @AppStorage("autoCleanup") var autoCleanup = false

    /// Command timeout in seconds
    @AppStorage("commandTimeout") var commandTimeout: Double = 300

    /// Disable Homebrew auto-update during commands
    @AppStorage("disableBrewAutoUpdate") var disableBrewAutoUpdate = true

    /// Disable Homebrew analytics
    @AppStorage("disableBrewAnalytics") var disableBrewAnalytics = true

    // MARK: - Notification Settings

    /// Notify when packages are outdated
    @AppStorage("notifyOutdated") var notifyOutdated = true

    /// Notify when updates complete
    @AppStorage("notifyUpdateComplete") var notifyUpdateComplete = true

    /// Notify when services start/stop
    @AppStorage("notifyServiceChanges") var notifyServiceChanges = false

    /// Minimum outdated packages to trigger notification
    @AppStorage("outdatedThreshold") var outdatedThreshold = 1

    // MARK: - Appearance Settings

    /// Enable animations
    @AppStorage("enableAnimations") var enableAnimations = true

    /// Compact mode for package lists
    @AppStorage("compactMode") var compactMode = false

    // MARK: - Private

    private init() {}

    // MARK: - Methods

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }

    /// Reset all settings to defaults
    func resetToDefaults() {
        launchAtLogin = false
        showMenuBarIcon = true
        menuBarStyleRaw = MenuBarStyle.window.rawValue
        showOutdatedBadge = true

        autoCheckUpdates = true
        updateCheckIntervalRaw = UpdateCheckInterval.oneHour.rawValue
        autoCleanup = false
        commandTimeout = 300
        disableBrewAutoUpdate = true
        disableBrewAnalytics = true

        notifyOutdated = true
        notifyUpdateComplete = true
        notifyServiceChanges = false
        outdatedThreshold = 1

        enableAnimations = true
        compactMode = false
    }
}
