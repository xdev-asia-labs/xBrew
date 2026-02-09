import SwiftUI

struct ContentView: View {
    @StateObject private var brew = HomebrewManager.shared
    @StateObject private var servicesManager = HomebrewServicesManager.shared
    @StateObject private var brewfileManager = BrewfileManager.shared
    @StateObject private var navigationState = NavigationState()
    @StateObject private var installer = HomebrewInstaller()
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var localization = LocalizationManager.shared

    @State private var showingInstallSheet = false
    @State private var showingBrewfileImport = false
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        Group {
            if !brew.isBrewInstalled {
                brewNotInstalledView
            } else {
                NavigationSplitView(columnVisibility: $columnVisibility) {
                    // Sidebar
                    sidebarContent
                } detail: {
                    // Main Content
                    mainContent
                        .id(localization.currentLanguage) // Force refresh when language changes
                        .toolbar {
                            ToolbarItemGroup(placement: .automatic) {
                                toolbarButtons
                            }
                        }
                }
                .navigationSplitViewStyle(.balanced)
                .sheet(isPresented: $showingInstallSheet) {
                    InstallPackageSheet()
                }
                .fileImporter(
                    isPresented: $showingBrewfileImport,
                    allowedContentTypes: [.plainText]
                ) { result in
                    handleBrewfileImport(result)
                }
            }
        }
        .onAppear {
            // Services refresh on appear
            Task {
                await servicesManager.refreshServices()
            }
        }
    }
    
    // MARK: - Sidebar
    
    private var sidebarContent: some View {
        List(NavigationItem.allCases, selection: $navigationState.selectedItem) { item in
            NavigationLink(value: item) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: item.icon)
                        .font(.system(size: 16))
                        .foregroundColor(navigationState.selectedItem == item ? .ds.primary : .secondary)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.label)
                            .font(.system(size: DesignSystem.Typography.body, weight: .medium))
                        
                        Text(item.description)
                            .font(.system(size: DesignSystem.Typography.caption2))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Badge for counts
                    if let badge = badgeText(for: item) {
                        Text(badge)
                            .font(.system(size: DesignSystem.Typography.caption2, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(badgeColor(for: item))
                            .cornerRadius(10)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("xBrew")
        .navigationSubtitle(brew.brewVersion)
        .frame(minWidth: DesignSystem.Layout.sidebarWidth)
        .background(DesignSystem.Colors.sidebarBackground)
        .id(localization.currentLanguage) // Force refresh when language changes
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private var mainContent: some View {
        Group {
            switch navigationState.selectedItem {
            case .overview:
                DashboardView()
                
            case .formulas:
                ModernPackagesView()
                
            case .casks:
                ModernCasksView()
                
            case .services:
                ModernServicesView()
                
            case .taps:
                ModernTapsView()
                
            case .security:
                SecurityView()
                
            case .maintenance:
                MaintenanceView()
                
            case .community:
                CommunityView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Toolbar
    
    private var toolbarButtons: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            // Language Picker
            LanguagePicker()
            
            // Loading Indicator
            if brew.isLoading || brew.isUpdating {
                ProgressView().frame(width: 16, height: 16)
                    .controlSize(.small)
                    .frame(width: 16, height: 16)
            }
            
            // Brewfile Menu
            Menu {
                // Export options
                Button {
                    Task {
                        if let url = await brewfileManager.quickExport() {
                            print("Exported to: \(url.path)")
                        }
                    }
                } label: {
                    Label("Export to Downloads", systemImage: "square.and.arrow.down.on.square")
                }
                .help("Save Brewfile to Downloads folder")

                Button {
                    Task {
                        let success = await brewfileManager.exportToiCloud()
                        if success {
                            print("Synced to iCloud")
                        }
                    }
                } label: {
                    Label("Export to iCloud", systemImage: "icloud.and.arrow.up")
                }
                .disabled(brewfileManager.isExporting || brewfileManager.isSyncing)
                .help("Sync Brewfile to iCloud Drive")

                Divider()

                // Import options
                Button {
                    showingBrewfileImport = true
                } label: {
                    Label("Import from File", systemImage: "square.and.arrow.up.on.square")
                }
                .help("Import Brewfile from local file")

                Button {
                    Task {
                        let result = await brewfileManager.importFromiCloud()
                        print(result.message)
                    }
                } label: {
                    Label("Import from iCloud", systemImage: "icloud.and.arrow.down")
                }
                .disabled(!brewfileManager.hasiCloudBrewfile() || brewfileManager.isImporting || brewfileManager.isSyncing)
                .help("Import Brewfile from iCloud Drive")

                Divider()

                // Status
                if let lastSync = brewfileManager.lastSyncDate {
                    Text("Last sync: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } label: {
                Label("Brewfile", systemImage: "doc.text")
            }
            .help("Brewfile operations - Export and import your package list")
            
            // Install Button
            Button {
                showingInstallSheet = true
            } label: {
                Label("Install", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .help("Install new package")
            
            // Refresh Button
            Button {
                Task { await brew.refreshAll(forceRefresh: true) }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .help("Refresh all packages, casks, and services")
            .disabled(brew.isLoading || brew.isUpdating)
        }
    }
    // MARK: - Brew Not Installed
    
    private var brewNotInstalledView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                Spacer(minLength: 40)
                
                // Header
                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "mug.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.ds.primary)
                    
                    Text("Homebrew Not Installed")
                        .font(.system(size: DesignSystem.Typography.title1, weight: .bold))
                    
                    Text("Follow these simple steps to install Homebrew and start managing your packages")
                        .font(.system(size: DesignSystem.Typography.body))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 500)
                }
                
                // Installation Steps
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    ForEach(HomebrewInstaller.installationSteps.indices, id: \.self) { index in
                        let step = HomebrewInstaller.installationSteps[index]
                        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                            Image(systemName: step.icon)
                                .font(.system(size: 24))
                                .foregroundColor(.ds.primary)
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(step.title)
                                    .font(.system(size: DesignSystem.Typography.headline, weight: .semibold))
                                Text(step.description)
                                    .font(.system(size: DesignSystem.Typography.callout))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 550, alignment: .leading)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
                
                // Command Box
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Installation Command:")
                        .font(.system(size: DesignSystem.Typography.caption1, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(HomebrewInstaller.installCommand)
                            .font(.system(size: 11, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .textSelection(.enabled)
                        
                        Spacer()
                        
                        Button {
                            installer.copyInstallCommand()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: installer.commandCopied ? "checkmark" : "doc.on.doc")
                                Text(installer.commandCopied ? "Copied!" : "Copy")
                            }
                            .font(.system(size: DesignSystem.Typography.caption1, weight: .medium))
                        }
                        .buttonStyle(.bordered)
                        .tint(installer.commandCopied ? .green : .ds.primary)
                    }
                    .padding(12)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
                .frame(maxWidth: 550)
                
                // Action Buttons
                HStack(spacing: DesignSystem.Spacing.md) {
                    Button {
                        installer.copyInstallCommand()
                    } label: {
                        Label(installer.commandCopied ? "Command Copied!" : "Copy Install Command", 
                              systemImage: installer.commandCopied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                            .font(.system(size: DesignSystem.Typography.body, weight: .medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(installer.commandCopied ? .green : .ds.primary)
                    .controlSize(.large)
                    
                    Button {
                        installer.openTerminal()
                    } label: {
                        if installer.terminalOpenFailed {
                            Label("Failed to Open Terminal", systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: DesignSystem.Typography.body, weight: .medium))
                        } else if installer.terminalOpened {
                            Label("Terminal Opened!", systemImage: "checkmark.circle.fill")
                                .font(.system(size: DesignSystem.Typography.body, weight: .medium))
                        } else {
                            Label("Open Terminal", systemImage: "terminal.fill")
                                .font(.system(size: DesignSystem.Typography.body, weight: .medium))
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(installer.terminalOpenFailed ? .red : (installer.terminalOpened ? .green : nil))
                    .controlSize(.large)
                }
                
                // Help Links
                HStack(spacing: DesignSystem.Spacing.lg) {
                    Button {
                        installer.openHomebrewWebsite()
                    } label: {
                        Label("Visit brew.sh", systemImage: "safari")
                            .font(.system(size: DesignSystem.Typography.caption1))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.ds.primary)
                    
                    Button {
                        brew.checkBrewStatus()
                    } label: {
                        Label("Check Again", systemImage: "arrow.clockwise")
                            .font(.system(size: DesignSystem.Typography.caption1))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
    // MARK: - Helpers
    
    private func badgeText(for item: NavigationItem) -> String? {
        switch item {
        case .overview:
            return nil
        case .formulas:
            let count = brew.packages.count
            return count > 0 ? "\(count)" : nil
        case .casks:
            let count = brew.casks.count
            return count > 0 ? "\(count)" : nil
        case .services:
            let count = servicesManager.runningServicesCount
            return count > 0 ? "\(count)" : nil
        case .taps:
            return nil
        case .security:
            return nil
        case .maintenance:
            let count = brew.totalOutdated
            return count > 0 ? "\(count)" : nil
        case .community:
            return nil
        }
    }
    
    private func badgeColor(for item: NavigationItem) -> Color {
        switch item {
        case .services:
            return servicesManager.runningServicesCount > 0 ? .ds.success : .ds.gray400
        case .maintenance:
            return brew.totalOutdated > 0 ? .ds.warning : .ds.gray400
        default:
            return .ds.primary
        }
    }
    
    private func handleBrewfileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            Task {
                _ = await brewfileManager.importBrewfile(from: url)
            }
        case .failure:
            break
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 1100, height: 700)
}
