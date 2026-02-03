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
                    Label("settings.general".localized, systemImage: "gear")
                }

            HomebrewSettingsTab()
                .tabItem {
                    Label("settings.homebrew".localized, systemImage: "terminal")
                }

            NotificationSettingsTab()
                .tabItem {
                    Label("settings.notifications".localized, systemImage: "bell")
                }

            AboutTab()
                .tabItem {
                    Label("settings.about".localized, systemImage: "info.circle")
                }
        }
        .frame(width: 500, height: 400)
        .id(localization.currentLanguage) // Force refresh when language changes
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
                Picker("settings.language".localized, selection: $localization.currentLanguage) {
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
                Toggle("settings.launch_at_login".localized, isOn: $settings.launchAtLogin)
                    .help("settings.launch_at_login_help".localized)
            } header: {
                Label("settings.app_settings".localized, systemImage: "app.badge")
            }

            Section {
                // Show Menu Bar Icon
                Toggle("settings.show_menu_bar_icon".localized, isOn: $settings.showMenuBarIcon)
                    .help("settings.show_menu_bar_icon_help".localized)

                // Menu Bar Style
                Picker("settings.menu_bar_style".localized, selection: Binding(
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
                Toggle("settings.show_outdated_badge".localized, isOn: $settings.showOutdatedBadge)
                    .help("settings.show_outdated_badge_help".localized)
                    .disabled(!settings.showMenuBarIcon)
            } header: {
                Label("settings.menu_bar".localized, systemImage: "menubar.rectangle")
            }

            Section {
                // Enable Animations
                Toggle("settings.enable_animations".localized, isOn: $settings.enableAnimations)

                // Compact Mode
                Toggle("settings.compact_mode".localized, isOn: $settings.compactMode)
                    .help("settings.compact_mode_help".localized)
            } header: {
                Label("settings.appearance".localized, systemImage: "paintbrush")
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
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        Form {
            Section {
                // Auto Check Updates
                Toggle("settings.auto_check_updates".localized, isOn: $settings.autoCheckUpdates)
                    .help("settings.auto_check_updates_help".localized)

                // Update Interval
                Picker("settings.check_interval".localized, selection: Binding(
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
                Toggle("settings.auto_cleanup".localized, isOn: $settings.autoCleanup)
                    .help("settings.auto_cleanup_help".localized)
            } header: {
                Label("settings.updates".localized, systemImage: "arrow.clockwise")
            }

            Section {
                // Command Timeout
                HStack {
                    Text("settings.command_timeout".localized)
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
                Toggle("settings.disable_auto_update".localized, isOn: $settings.disableBrewAutoUpdate)
                    .help("settings.disable_auto_update_help".localized)

                // Disable Analytics
                Toggle("settings.disable_analytics".localized, isOn: $settings.disableBrewAnalytics)
                    .help("settings.disable_analytics_help".localized)
            } header: {
                Label("settings.performance".localized, systemImage: "speedometer")
            }

            Section {
                // Homebrew Version
                LabeledContent("settings.homebrew_version".localized, value: brew.brewVersion)

                // Homebrew Path
                if let path = getBrewPath() {
                    LabeledContent("settings.installation_path".localized, value: path)
                }
            } header: {
                Label("settings.information".localized, systemImage: "info.circle")
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
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        Form {
            Section {
                // Notify Outdated
                Toggle("settings.outdated_packages".localized, isOn: $settings.notifyOutdated)
                    .help("settings.outdated_packages_help".localized)

                // Outdated Threshold
                if settings.notifyOutdated {
                    Stepper(value: $settings.outdatedThreshold, in: 1...20) {
                        HStack {
                            Text("settings.minimum_to_notify".localized)
                            Spacer()
                            Text("\(settings.outdatedThreshold) package\(settings.outdatedThreshold > 1 ? "s" : "")")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Notify Update Complete
                Toggle("settings.update_complete".localized, isOn: $settings.notifyUpdateComplete)
                    .help("settings.update_complete_help".localized)

                // Notify Service Changes
                Toggle("settings.service_changes".localized, isOn: $settings.notifyServiceChanges)
                    .help("settings.service_changes_help".localized)
            } header: {
                Label("settings.notifications".localized, systemImage: "bell.badge")
            }

            Section {
                Button("settings.open_system_notifications".localized) {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.link)
            } header: {
                Label("settings.system_settings".localized, systemImage: "gearshape.2")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - About Tab

struct AboutTab: View {
    @StateObject private var brew = HomebrewManager.shared
    @StateObject private var localization = LocalizationManager.shared

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
            Text("\("settings.version".localized) \(appVersion)")
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
            Text("settings.copyright".localized)
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            // Reset Button
            Button("settings.reset_all".localized) {
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
