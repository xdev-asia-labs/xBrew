import SwiftUI

/// Modern packages (formulas) view with grid layout and search
struct ModernPackagesView: View {
    @StateObject private var brew = HomebrewManager.shared
    @StateObject private var navigationState = NavigationState()
    
    @State private var searchText = ""
    @State private var showOutdatedOnly = false
    @State private var selectedPackage: BrewPackage?
    @State private var showingTerminalLog = false
    @State private var terminalLogOutput = ""
    @State private var terminalLogTitle = ""
    
    var filteredPackages: [BrewPackage] {
        let filtered = brew.packages.filter { package in
            let matchesSearch = searchText.isEmpty || package.name.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = !showOutdatedOnly || package.isOutdated
            return matchesSearch && matchesFilter
        }
        return filtered.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Formulas")
                            .font(.system(size: DesignSystem.Typography.largeTitle, weight: .bold))
                        
                        Text("\(filteredPackages.count) of \(brew.packages.count) packages")
                            .font(.system(size: DesignSystem.Typography.body))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Upgrade All Button
                    if brew.outdatedPackages.count > 0 {
                        Button {
                            Task { _ = await brew.upgradeAllPackages() }
                        } label: {
                            Label("Upgrade All (\(brew.outdatedPackages.count))", systemImage: "arrow.up.circle.fill")
                                .font(.system(size: DesignSystem.Typography.body, weight: .medium))
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(brew.isUpdating)
                    }
                }
                
                // Search and Filters
                HStack(spacing: DesignSystem.Spacing.sm) {
                    SearchBar(text: $searchText, placeholder: "Search formulas...")
                        .frame(maxWidth: 400)
                    
                    Toggle(isOn: $showOutdatedOnly) {
                        Label("Outdated Only", systemImage: "arrow.triangle.2.circlepath")
                            .font(.system(size: DesignSystem.Typography.callout))
                    }
                    .toggleStyle(.button)
                    .tint(showOutdatedOnly ? .ds.warning : .gray)
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.background)
            
            Divider()
            
            // Content
            if brew.isLoading {
                VStack(spacing: DesignSystem.Spacing.md) {
                    ProgressView()
                    Text("Loading packages...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredPackages.isEmpty {
                emptyState
            } else {
                packageGrid
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
        .sheet(item: $selectedPackage) { package in
            PackageDetailSheet(packageName: package.name)
        }
        .sheet(isPresented: $showingTerminalLog) {
            TerminalLogSheet(output: terminalLogOutput, title: terminalLogTitle)
        }
    }
    
    private var packageGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: DesignSystem.Layout.cardMinWidth, maximum: DesignSystem.Layout.cardMaxWidth), spacing: DesignSystem.Spacing.md)
                ],
                spacing: DesignSystem.Spacing.md
            ) {
                ForEach(filteredPackages) { package in
                    PackageCard(
                        package: package,
                        onUpgrade: {
                            Task {
                                terminalLogTitle = "Upgrading \(package.name)"
                                terminalLogOutput = "Starting upgrade...\n"
                                showingTerminalLog = true
                                
                                let result = await brew.upgradePackage(package.name)
                                terminalLogOutput = result.message
                            }
                        },
                        onUninstall: {
                            Task {
                                terminalLogTitle = "Uninstalling \(package.name)"
                                terminalLogOutput = "Removing package...\n"
                                showingTerminalLog = true
                                
                                let result = await brew.uninstallPackage(package.name)
                                terminalLogOutput = result.message
                            }
                        },
                        onInfo: {
                            selectedPackage = package
                        }
                    )
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: searchText.isEmpty ? "terminal" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(searchText.isEmpty ? "No Packages Installed" : "No Packages Found")
                .font(.system(size: DesignSystem.Typography.title2, weight: .semibold))
            
            Text(searchText.isEmpty ? "Install packages using the + button" : "Try a different search term")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ModernPackagesView()
        .frame(width: 900, height: 700)
}
