import SwiftUI

/// Modern casks view with app icons and metadata
struct ModernCasksView: View {
    @StateObject private var brew = HomebrewManager.shared
    
    @State private var searchText = ""
    @State private var showOutdatedOnly = false
    
    var filteredCasks: [BrewCask] {
        let filtered = brew.casks.filter { cask in
            let matchesSearch = searchText.isEmpty || cask.name.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = !showOutdatedOnly || cask.isOutdated
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
                        Text("Casks")
                            .font(.system(size: DesignSystem.Typography.largeTitle, weight: .bold))
                        
                        Text("\(filteredCasks.count) of \(brew.casks.count) applications")
                            .font(.system(size: DesignSystem.Typography.body))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Search and Filters
                HStack(spacing: DesignSystem.Spacing.sm) {
                    SearchBar(text: $searchText, placeholder: "Search casks...")
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
                    Text("Loading casks...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredCasks.isEmpty {
                emptyState
            } else {
                caskGrid
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
    
    private var caskGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: DesignSystem.Layout.cardMinWidth, maximum: DesignSystem.Layout.cardMaxWidth), spacing: DesignSystem.Spacing.md)
                ],
                spacing: DesignSystem.Spacing.md
            ) {
                ForEach(filteredCasks) { cask in
                    CaskCard(
                        cask: cask,
                        onUpgrade: {
                            Task { _ = await brew.upgradeCask(cask.name) }
                        },
                        onUninstall: {
                            Task { _ = await brew.uninstallCask(cask.name) }
                        }
                    )
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: searchText.isEmpty ? "app" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(searchText.isEmpty ? "No Casks Installed" : "No Casks Found")
                .font(.system(size: DesignSystem.Typography.title2, weight: .semibold))
            
            Text(searchText.isEmpty ? "Install GUI applications using the + button" : "Try a different search term")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Cask Card

struct CaskCard: View {
    let cask: BrewCask
    let onUpgrade: () -> Void
    let onUninstall: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(alignment: .top) {
                // App Icon Placeholder
                Image(systemName: "app.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.ds.primary)
                    .frame(width: 48, height: 48)
                    .background(DesignSystem.Colors.gray100)
                    .cornerRadius(DesignSystem.Radius.lg)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(cask.name)
                        .font(.system(size: DesignSystem.Typography.headline, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("v\(cask.version)")
                        .font(.system(size: DesignSystem.Typography.caption1))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if cask.isOutdated {
                    Text("Outdated")
                        .statusBadge(color: .ds.warning)
                } else {
                    Text("Up to date")
                        .statusBadge(color: .ds.success)
                }
            }
            
            if isHovered {
                Divider()
                
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if cask.isOutdated {
                        Button(action: onUpgrade) {
                            Label("Upgrade", systemImage: "arrow.up.circle.fill")
                                .font(.system(size: DesignSystem.Typography.caption1, weight: .medium))
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    
                    Spacer()
                    
                    Button(action: onUninstall) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.red)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(minWidth: DesignSystem.Layout.cardMinWidth, maxWidth: DesignSystem.Layout.cardMaxWidth)
        .frame(height: isHovered ? nil : 90)
        .modernCard()
        .animation(DesignSystem.Animation.medium, value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    ModernCasksView()
        .frame(width: 900, height: 700)
}
