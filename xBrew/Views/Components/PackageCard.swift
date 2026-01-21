import SwiftUI

/// Rich package card with metadata and actions
struct PackageCard: View {
    let package: BrewPackage
    let onUpgrade: () -> Void
    let onUninstall: () -> Void
    let onInfo: () -> Void
    
    @State private var isUpgrading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.name)
                        .font(.system(size: DesignSystem.Typography.headline, weight: DesignSystem.Typography.Weight.semibold))
                        .foregroundColor(.primary)
                    
                    Text("v\(package.version)")
                        .font(.system(size: DesignSystem.Typography.caption1))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Badge
                if package.isOutdated {
                    Text("Outdated")
                        .statusBadge(color: DesignSystem.Colors.warning)
                } else {
                    Text("Up to date")
                        .statusBadge(color: DesignSystem.Colors.success)
                }
            }
            
            Divider()
                .opacity(0.5)
            
            // Always visible actions
            HStack(spacing: DesignSystem.Spacing.xs) {
                if package.isOutdated {
                    Button {
                        isUpgrading = true
                        onUpgrade()
                        // isUpgrading will be reset from parent
                    } label: {
                        HStack(spacing: 4) {
                            if isUpgrading {
                                ProgressView()
                                    .controlSize(.small)
                                    .frame(width: 12, height: 12)
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 14))
                            }
                            Text("Upgrade")
                                .font(.system(size: DesignSystem.Typography.caption1, weight: .medium))
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(isUpgrading)
                }
                
                Button(action: onInfo) {
                    Label("Info", systemImage: "info.circle")
                        .font(.system(size: DesignSystem.Typography.caption1, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Spacer()
                
                Button(action: onUninstall) {
                    Image(systemName: "trash")
                        .font(.system(size: DesignSystem.Typography.caption1))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(.red)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(minWidth: DesignSystem.Layout.cardMinWidth, maxWidth: DesignSystem.Layout.cardMaxWidth)
        .modernCard()
    }
}

#Preview {
    HStack(spacing: 16) {
        PackageCard(
            package: BrewPackage(name: "python@3.11", version: "3.11.6", isOutdated: false),
            onUpgrade: {},
            onUninstall: {},
            onInfo: {}
        )
        
        PackageCard(
            package: BrewPackage(name: "node", version: "18.17.0", isOutdated: true),
            onUpgrade: {},
            onUninstall: {},
            onInfo: {}
        )
    }
    .padding()
}
