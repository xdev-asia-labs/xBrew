import SwiftUI

struct ContentView: View {
    @StateObject private var brew = HomebrewManager.shared
    @StateObject private var servicesManager = HomebrewServicesManager.shared
    @StateObject private var brewfileManager = BrewfileManager.shared
    @StateObject private var navigationState = NavigationState()
    @StateObject private var installer = HomebrewInstaller()
    @StateObject private var settings = SettingsManager.shared

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
                        .toolbar {
                            ToolbarItemGroup(placement: .automatic) {
                                toolbarButtons
                            }
                        }
                }
                .navigationSplitViewStyle(.balanced)
                .sheet(isPresented: $showingInstallSheet) {
                    // TODO: Create InstallSheet component
                    Text("Install Package")
                        .padding()
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
            // Initialize on first launch
            brew.checkBrewStatus()
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
                
            case .maintenance:
                MaintenanceView()
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
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            
            Image(systemName: "mug.fill")
                .font(.system(size: 80))
                .foregroundColor(.ds.primary)
            
            Text("Homebrew Not Installed")
                .font(.system(size: DesignSystem.Typography.title1, weight: .bold))
            
            Text("Install Homebrew to manage packages and applications")
                .font(.system(size: DesignSystem.Typography.body))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            
            if installer.isInstalling {
                VStack(spacing: DesignSystem.Spacing.md) {
                    HStack {
                        ProgressView().frame(width: 16, height: 16)
                            .scaleEffect(0.8)
                        Text("Installing Homebrew...")
                            .font(.system(size: DesignSystem.Typography.callout, weight: .medium))
                    }
                    
                    // Terminal-like output view
                    ScrollViewReader { proxy in
                        ScrollView {
                            Text(installer.installOutput)
                                .font(.system(size: 12, design: .monospaced))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .id("bottom")
                        }
                        .frame(width: 700, height: 400)
                        .background(Color.black.opacity(0.9))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                        .onChange(of: installer.installOutput) { _ in
                            withAnimation {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                    
                    Text("⚠️ You may need to enter your password during installation")
                        .font(.system(size: DesignSystem.Typography.caption1))
                        .foregroundColor(.secondary)
                }
            } else if installer.showInstructions {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Manual Installation")
                        .font(.system(size: DesignSystem.Typography.headline, weight: .semibold))
                    
                    Text("Copy and paste this command in Terminal:")
                        .font(.system(size: DesignSystem.Typography.callout))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")
                            .font(.system(size: 12, design: .monospaced))
                            .padding(8)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(6)
                            .textSelection(.enabled)
                        
                        Button {
                            installer.copyInstallCommand()
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .help("Copy to clipboard")
                    }
                    
                    Button {
                        installer.showInstructions = false
                    } label: {
                        Text("Back")
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: 600)
                .padding()
                .background(Color.ds.info.opacity(0.1))
                .cornerRadius(12)
            } else {
                Button {
                    Task {
                        let success = await installer.installHomebrew()
                        if success {
                            // Wait a bit then refresh
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            brew.checkBrewStatus()
                        }
                    }
                } label: {
                    Label("Install Homebrew", systemImage: "arrow.down.circle.fill")
                        .font(.system(size: DesignSystem.Typography.body, weight: .medium))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button {
                    installer.showInstructions = true
                } label: {
                    Text("Show Manual Instructions")
                        .font(.system(size: DesignSystem.Typography.callout))
                }
                .buttonStyle(.plain)
                
                Button {
                    installer.installWithAppleScript()
                } label: {
                    Text("Install in Terminal App")
                        .font(.system(size: DesignSystem.Typography.caption1))
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
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
        case .maintenance:
            let count = brew.totalOutdated
            return count > 0 ? "\(count)" : nil
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
