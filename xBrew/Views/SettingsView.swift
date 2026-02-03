import SwiftUI

/// Main Settings View with tabs
struct SettingsView: View {
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var brew = HomebrewManager.shared

    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            HomebrewSettingsTab()
                .tabItem {
                    Label("Homebrew", systemImage: "terminal")
                }

            NotificationSettingsTab()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }

            AboutTab()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - General Settings Tab

struct GeneralSettingsTab: View {
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        Form {
            Section {
                // Language
                Picker("Language", selection: $localization.currentLanguage) {
                    ForEach(LocalizationManager.Language.allCases, id: \.self) { lang in
                        HStack {
                            Text(lang.flag)
                            Text(lang.displayName)
                        }
                        .tag(lang)
                    }
                }
                .pickerStyle(.menu)

                // Launch at Login
                Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                    .help("Automatically start xBrew when you log in")
            } header: {
                Label("App Settings", systemImage: "app.badge")
            }

            Section {
                // Show Menu Bar Icon
                Toggle("Show Menu Bar Icon", isOn: $settings.showMenuBarIcon)
                    .help("Show xBrew icon in the menu bar")

                // Menu Bar Style
                Picker("Menu Bar Style", selection: Binding(
                    get: { settings.menuBarStyle },
                    set: { settings.menuBarStyle = $0 }
                )) {
                    ForEach(MenuBarStyle.allCases, id: \.self) { style in
                        HStack {
                            Image(systemName: style.icon)
                            Text(style.displayName)
                        }
                        .tag(style)
                    }
                }
                .pickerStyle(.menu)
                .disabled(!settings.showMenuBarIcon)

                // Show Badge
                Toggle("Show Outdated Badge", isOn: $settings.showOutdatedBadge)
                    .help("Show number of outdated packages on menu bar icon")
                    .disabled(!settings.showMenuBarIcon)
            } header: {
                Label("Menu Bar", systemImage: "menubar.rectangle")
            }

            Section {
                // Enable Animations
                Toggle("Enable Animations", isOn: $settings.enableAnimations)

                // Compact Mode
                Toggle("Compact Mode", isOn: $settings.compactMode)
                    .help("Use compact layout for package lists")
            } header: {
                Label("Appearance", systemImage: "paintbrush")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Homebrew Settings Tab

struct HomebrewSettingsTab: View {
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var brew = HomebrewManager.shared

    var body: some View {
        Form {
            Section {
                // Auto Check Updates
                Toggle("Auto Check for Updates", isOn: $settings.autoCheckUpdates)
                    .help("Periodically check for outdated packages")

                // Update Interval
                Picker("Check Interval", selection: Binding(
                    get: { settings.updateCheckInterval },
                    set: { settings.updateCheckInterval = $0 }
                )) {
                    ForEach(UpdateCheckInterval.allCases, id: \.self) { interval in
                        Text(interval.displayName).tag(interval)
                    }
                }
                .pickerStyle(.menu)
                .disabled(!settings.autoCheckUpdates)

                // Auto Cleanup
                Toggle("Auto Cleanup After Updates", isOn: $settings.autoCleanup)
                    .help("Automatically run cleanup after updating packages")
            } header: {
                Label("Updates", systemImage: "arrow.clockwise")
            }

            Section {
                // Command Timeout
                HStack {
                    Text("Command Timeout")
                    Spacer()
                    Picker("", selection: $settings.commandTimeout) {
                        Text("1 minute").tag(60.0)
                        Text("2 minutes").tag(120.0)
                        Text("5 minutes").tag(300.0)
                        Text("10 minutes").tag(600.0)
                        Text("15 minutes").tag(900.0)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                }

                // Disable Auto Update
                Toggle("Disable Homebrew Auto-Update", isOn: $settings.disableBrewAutoUpdate)
                    .help("Prevent Homebrew from auto-updating before commands")

                // Disable Analytics
                Toggle("Disable Homebrew Analytics", isOn: $settings.disableBrewAnalytics)
                    .help("Opt out of Homebrew's anonymous analytics")
            } header: {
                Label("Performance", systemImage: "speedometer")
            }

            Section {
                // Homebrew Version
                LabeledContent("Homebrew Version", value: brew.brewVersion)

                // Homebrew Path
                if let path = getBrewPath() {
                    LabeledContent("Installation Path", value: path)
                }
            } header: {
                Label("Information", systemImage: "info.circle")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func getBrewPath() -> String? {
        for path in AppConfig.brewPaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        return nil
    }
}

// MARK: - Notification Settings Tab

struct NotificationSettingsTab: View {
    @StateObject private var settings = SettingsManager.shared

    var body: some View {
        Form {
            Section {
                // Notify Outdated
                Toggle("Outdated Packages", isOn: $settings.notifyOutdated)
                    .help("Notify when packages have updates available")

                // Outdated Threshold
                if settings.notifyOutdated {
                    Stepper(value: $settings.outdatedThreshold, in: 1...20) {
                        HStack {
                            Text("Minimum to notify")
                            Spacer()
                            Text("\(settings.outdatedThreshold) package\(settings.outdatedThreshold > 1 ? "s" : "")")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Notify Update Complete
                Toggle("Update Complete", isOn: $settings.notifyUpdateComplete)
                    .help("Notify when package updates finish")

                // Notify Service Changes
                Toggle("Service Changes", isOn: $settings.notifyServiceChanges)
                    .help("Notify when services start or stop")
            } header: {
                Label("Notifications", systemImage: "bell.badge")
            }

            Section {
                Button("Open System Notifications Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.link)
            } header: {
                Label("System Settings", systemImage: "gearshape.2")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - About Tab

struct AboutTab: View {
    @StateObject private var brew = HomebrewManager.shared

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()

            // App Icon
            Image(systemName: "mug.fill")
                .font(.system(size: 64))
                .foregroundColor(.ds.primary)

            // App Name
            Text("xBrew")
                .font(.system(size: 28, weight: .bold))

            // Version
            Text("Version \(appVersion)")
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            // Homebrew Version
            Text("Homebrew \(brew.brewVersion)")
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Spacer()

            // Links
            HStack(spacing: DesignSystem.Spacing.lg) {
                Link(destination: URL(string: "https://buymeacoffee.com/tdduydev")!) {
                    Label("Buy Me a Coffee", systemImage: "heart.fill")
                }
                .foregroundColor(.pink)

                Link(destination: URL(string: "https://github.com/xdev-asia/xBrew")!) {
                    Label("GitHub", systemImage: "link")
                }

                Link(destination: URL(string: "https://brew.sh")!) {
                    Label("Homebrew", systemImage: "globe")
                }

                Link(destination: URL(string: "https://xdev.asia")!) {
                    Label("xDev.asia", systemImage: "building.2")
                }
            }
            .font(.system(size: 12))

            Spacer()

            // Copyright
            Text("© 2024 xDev.asia. All rights reserved.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            // Reset Button
            Button("Reset All Settings") {
                SettingsManager.shared.resetToDefaults()
            }
            .buttonStyle(.link)
            .foregroundColor(.red)
            .font(.system(size: 11))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

#Preview {
    SettingsView()
}
