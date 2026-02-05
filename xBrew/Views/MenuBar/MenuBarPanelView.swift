import SwiftUI

/// Rich menu bar panel view (window style)
struct MenuBarPanelView: View {
    @StateObject private var brew = HomebrewManager.shared
    @StateObject private var services = HomebrewServicesManager.shared
    @StateObject private var settings = SettingsManager.shared
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // Header
            MenuBarHeader()

            Divider()

            // Stats
            MenuBarStats()

            Divider()

            // Outdated Section (if any)
            if brew.totalOutdated > 0 {
                MenuBarOutdatedSection()
                Divider()
            }

            // Quick Actions
            MenuBarQuickActions()

            Divider()

            // Footer
            MenuBarFooter()
        }
        .frame(width: 320)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// MARK: - Header

struct MenuBarHeader: View {
    @StateObject private var brew = HomebrewManager.shared

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "mug.fill")
                .font(.system(size: 20))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("xBrew")
                    .font(.system(size: 14, weight: .semibold))

                Text(brew.brewVersion)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Status Indicator
            if brew.isLoading || brew.isUpdating {
                ProgressView().frame(width: 16, height: 16)
                    .scaleEffect(0.7)
            } else {
                HStack(spacing: 4) {
                    Circle()
                        .fill(brew.isBrewInstalled ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(brew.isBrewInstalled ? "Ready" : "Not Installed")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Stats

struct MenuBarStats: View {
    @StateObject private var brew = HomebrewManager.shared
    @StateObject private var services = HomebrewServicesManager.shared

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            MenuBarStatItem(
                icon: "terminal.fill",
                label: "Formulas",
                value: "\(brew.packages.count)",
                color: .ds.primary
            )

            MenuBarStatItem(
                icon: "app.fill",
                label: "Casks",
                value: "\(brew.casks.count)",
                color: .ds.info
            )

            MenuBarStatItem(
                icon: "gearshape.2.fill",
                label: "Services",
                value: "\(services.runningServicesCount)",
                color: .ds.success
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

struct MenuBarStatItem: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 16, weight: .bold))

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Outdated Section

struct MenuBarOutdatedSection: View {
    @StateObject private var brew = HomebrewManager.shared
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)

                    Text("\(brew.totalOutdated) Updates Available")
                        .font(.system(size: 12, weight: .medium))

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            // Package List (expandable)
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(brew.outdatedPackages.prefix(5), id: \.self) { pkg in
                        HStack(spacing: 6) {
                            Image(systemName: "terminal.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(pkg)
                                .font(.system(size: 11))
                            Spacer()
                        }
                    }

                    ForEach(brew.outdatedCasks.prefix(5), id: \.self) { cask in
                        HStack(spacing: 6) {
                            Image(systemName: "app.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(cask)
                                .font(.system(size: 11))
                            Spacer()
                        }
                    }

                    if brew.totalOutdated > 10 {
                        Text("+ \(brew.totalOutdated - 10) more...")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding(.leading, DesignSystem.Spacing.md)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Quick Actions

struct MenuBarQuickActions: View {
    @StateObject private var brew = HomebrewManager.shared

    var body: some View {
        VStack(spacing: 2) {
            MenuBarActionButton(
                title: "Update All",
                icon: "arrow.clockwise.circle.fill",
                shortcut: "⌘U",
                isLoading: brew.isUpdating
            ) {
                Task { await brew.updateBrew() }
            }

            MenuBarActionButton(
                title: "Cleanup",
                icon: "trash.circle.fill",
                shortcut: nil,
                isLoading: brew.isUpdating
            ) {
                Task { await brew.cleanup() }
            }

            MenuBarActionButton(
                title: "Health Check",
                icon: "heart.circle.fill",
                shortcut: nil,
                isLoading: brew.isUpdating
            ) {
                Task { await brew.doctor() }
            }

            MenuBarActionButton(
                title: "Refresh",
                icon: "arrow.triangle.2.circlepath",
                shortcut: "⌘R",
                isLoading: brew.isLoading
            ) {
                Task { await brew.refreshAll(forceRefresh: true) }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

struct MenuBarActionButton: View {
    let title: String
    let icon: String
    let shortcut: String?
    let isLoading: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.ds.primary)
                    .frame(width: 20)

                Text(title)
                    .font(.system(size: 12))

                Spacer()

                if isLoading {
                    ProgressView().frame(width: 16, height: 16)
                        .scaleEffect(0.6)
                } else if let shortcut = shortcut {
                    Text(shortcut)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(isHovered ? Color.gray.opacity(0.15) : Color.clear)
            .cornerRadius(DesignSystem.Radius.sm)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Footer

struct MenuBarFooter: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 2) {
            MenuBarFooterButton(title: "Open xBrew", icon: "macwindow", shortcut: "⌘O") {
                // Check if main window already exists
                if let existingWindow = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "main" || $0.title.contains("xBrew") }) {
                    existingWindow.makeKeyAndOrderFront(nil)
                } else {
                    openWindow(id: "main")
                }
                NSApplication.shared.activate(ignoringOtherApps: true)
            }

            if #available(macOS 14.0, *) {
                SettingsLink {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "gear")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(width: 16)

                        Text("Settings...")
                            .font(.system(size: DesignSystem.Typography.callout))

                        Spacer()

                        Text("⌘,")
                            .font(.system(size: DesignSystem.Typography.caption2))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, 6)
                    .background(Color.clear)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            } else {
                MenuBarFooterButton(title: "Settings...", icon: "gear", shortcut: "⌘,") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
            }

            Divider()
                .padding(.vertical, 4)

            MenuBarFooterButton(title: "Quit xBrew", icon: "power", shortcut: "⌘Q") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

struct MenuBarFooterButton: View {
    let title: String
    let icon: String
    let shortcut: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 16)

                Text(title)
                    .font(.system(size: 12))

                Spacer()

                Text(shortcut)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(isHovered ? Color.gray.opacity(0.15) : Color.clear)
            .cornerRadius(DesignSystem.Radius.sm)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

#Preview {
    MenuBarPanelView()
}
