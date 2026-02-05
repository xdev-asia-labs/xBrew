import SwiftUI

/// Simple menu bar dropdown view (menu style)
struct MenuBarMenuView: View {
    @StateObject private var brew = HomebrewManager.shared
    @StateObject private var services = HomebrewServicesManager.shared
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Group {
            // Status Section
            Section {
                Label("Formulas: \(brew.packages.count)", systemImage: "terminal.fill")
                Label("Casks: \(brew.casks.count)", systemImage: "app.fill")
                Label("Services: \(services.runningServicesCount) running", systemImage: "gearshape.2.fill")

                if brew.totalOutdated > 0 {
                    Divider()
                    Label("\(brew.totalOutdated) Updates Available", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }
            }

            Divider()

            // Quick Actions
            Section {
                Button {
                    Task { await brew.updateBrew() }
                } label: {
                    Label("Update Homebrew", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("u", modifiers: .command)
                .disabled(brew.isUpdating)

                if brew.totalOutdated > 0 {
                    Button {
                        Task { await brew.upgradeAll() }
                    } label: {
                        Label("Upgrade All Packages", systemImage: "arrow.up.circle")
                    }
                    .disabled(brew.isUpdating)
                }

                Button {
                    Task { await brew.cleanup() }
                } label: {
                    Label("Cleanup", systemImage: "trash")
                }
                .disabled(brew.isUpdating)

                Button {
                    Task { await brew.doctor() }
                } label: {
                    Label("Health Check", systemImage: "heart")
                }
                .disabled(brew.isUpdating)

                Divider()

                Button {
                    Task { await brew.refreshAll(forceRefresh: true) }
                } label: {
                    if brew.isLoading {
                        Label("Refreshing...", systemImage: "arrow.triangle.2.circlepath")
                    } else {
                        Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                    }
                }
                .keyboardShortcut("r", modifiers: .command)
                .disabled(brew.isLoading)
            }

            Divider()

            // App Controls
            Section {
                Button {
                    // Check if main window already exists
                    if let existingWindow = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "main" || $0.title.contains("xBrew") }) {
                        existingWindow.makeKeyAndOrderFront(nil)
                    } else {
                        openWindow(id: "main")
                    }
                    NSApplication.shared.activate(ignoringOtherApps: true)
                } label: {
                    Label("Open xBrew", systemImage: "macwindow")
                }
                .keyboardShortcut("o", modifiers: .command)

                if #available(macOS 14.0, *) {
                    SettingsLink {
                        Label("Settings...", systemImage: "gear")
                    }
                    .keyboardShortcut(",", modifiers: .command)
                } else {
                    Button {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    } label: {
                        Label("Settings...", systemImage: "gear")
                    }
                    .keyboardShortcut(",", modifiers: .command)
                }

                Divider()

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label("Quit xBrew", systemImage: "power")
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}

#Preview {
    MenuBarMenuView()
}
