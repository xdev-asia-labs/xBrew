import SwiftUI

/// Dashboard overview with stats and quick actions
struct DashboardView: View {
    @StateObject private var brew = HomebrewManager.shared
    @StateObject private var servicesManager = HomebrewServicesManager.shared
    
    @State private var showingUpdateOutput = false
    @State private var showingCleanupOutput = false
    @State private var showingDoctorOutput = false
    @State private var updateOutput = ""
    @State private var cleanupOutput = ""
    @State private var doctorOutput = ""
    
    var body: some View {
        ScrollView {
            if brew.isLoading && brew.packages.isEmpty {
                // Skeleton loading state
                DashboardSkeleton()
            } else {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Overview")
                            .font(.system(size: DesignSystem.Typography.largeTitle, weight: DesignSystem.Typography.Weight.bold))
                        
                        Text("Homebrew package manager dashboard")
                            .font(.system(size: DesignSystem.Typography.body))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.lg)
                
                // Quick Stats
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignSystem.Spacing.md) {
                    StatCard(
                        title: "Total Packages",
                        value: "\(brew.totalPackages)",
                        icon: "cube.fill",
                        color: .ds.primary
                    )
                    
                    StatCard(
                        title: "Outdated",
                        value: "\(brew.totalOutdated)",
                        icon: "arrow.triangle.2.circlepath",
                        color: brew.totalOutdated > 0 ? .ds.warning : .ds.success,
                        trend: brew.totalOutdated > 0 ? "Updates available" : nil
                    )
                    
                    StatCard(
                        title: "Services Running",
                        value: "\(servicesManager.runningServicesCount)",
                        icon: "gearshape.2.fill",
                        color: .ds.info
                    )
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                // Package Distribution
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Package Distribution")
                        .sectionHeader()
                    
                    HStack(spacing: DesignSystem.Spacing.lg) {
                        // Formulas
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            HStack {
                                Image(systemName: "terminal.fill")
                                    .foregroundColor(.ds.primary)
                                Text("Formulas")
                                    .font(.system(size: DesignSystem.Typography.callout, weight: .medium))
                                Spacer()
                                Text("\(brew.packages.count)")
                                    .font(.system(size: DesignSystem.Typography.title2, weight: .bold))
                            }
                            
                            if brew.outdatedPackages.count > 0 {
                                Text("\(brew.outdatedPackages.count) outdated")
                                    .font(.system(size: DesignSystem.Typography.caption1))
                                    .foregroundColor(.ds.warning)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(DesignSystem.Spacing.md)
                        .frame(maxWidth: .infinity)
                        .modernCard(isPressable: false)
                        
                        // Casks
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            HStack {
                                Image(systemName: "app.fill")
                                    .foregroundColor(.ds.info)
                                Text("Casks")
                                    .font(.system(size: DesignSystem.Typography.callout, weight: .medium))
                                Spacer()
                                Text("\(brew.casks.count)")
                                    .font(.system(size: DesignSystem.Typography.title2, weight: .bold))
                            }
                            
                            if brew.outdatedCasks.count > 0 {
                                Text("\(brew.outdatedCasks.count) outdated")
                                    .font(.system(size: DesignSystem.Typography.caption1))
                                    .foregroundColor(.ds.warning)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(DesignSystem.Spacing.md)
                        .frame(maxWidth: .infinity)
                        .modernCard(isPressable: false)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                // Quick Actions
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Quick Actions")
                        .sectionHeader()
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DesignSystem.Spacing.sm) {
                        QuickActionButton(
                            title: "Refresh Packages",
                            icon: "arrow.clockwise.circle.fill",
                            color: .ds.primary,
                            isLoading: brew.isLoading
                        ) {
                            Task {
                                updateOutput = "Refreshing package data...\n"
                                showingUpdateOutput = true
                                
                                await brew.refreshAll(forceRefresh: true)
                                updateOutput += "Refresh complete.\n"
                            }
                        }
                        
                        QuickActionButton(
                            title: "Cleanup",
                            icon: "trash.circle.fill",
                            color: .ds.warning,
                            isLoading: brew.isUpdating
                        ) {
                            Task {
                                cleanupOutput = "Running cleanup...\n"
                                showingCleanupOutput = true
                                
                                cleanupOutput += await brew.cleanup()
                            }
                        }
                        
                        QuickActionButton(
                            title: "Health Check",
                            icon: "heart.circle.fill",
                            color: .ds.success,
                            isLoading: brew.isUpdating
                        ) {
                            Task {
                                doctorOutput = "Running diagnostics...\n"
                                showingDoctorOutput = true
                                
                                doctorOutput += await brew.doctor()
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                // System Info
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("System Information")
                        .sectionHeader()
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        InfoRow(label: "Homebrew Version", value: brew.brewVersion)
                        Divider()
                        InfoRow(label: "Formulas", value: "\(brew.packages.count) installed")
                        Divider()
                        InfoRow(label: "Casks", value: "\(brew.casks.count) installed")
                        Divider()
                        InfoRow(label: "Services", value: "\(servicesManager.services.count) total, \(servicesManager.runningServicesCount) running")
                    }
                    .padding(DesignSystem.Spacing.md)
                    .modernCard(isPressable: false)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.lg)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
        .sheet(isPresented: $showingUpdateOutput) {
            TerminalLogSheet(output: updateOutput, title: "Refresh Packages")
        }
        .sheet(isPresented: $showingCleanupOutput) {
            TerminalLogSheet(output: cleanupOutput, title: "Cleanup")
        }
        .sheet(isPresented: $showingDoctorOutput) {
            TerminalLogSheet(output: doctorOutput, title: "Health Check")
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.xs) {
                if isLoading {
                    ProgressView().frame(width: 16, height: 16)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: DesignSystem.Typography.caption1, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .modernCard()
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: DesignSystem.Typography.body))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: DesignSystem.Typography.body, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    DashboardView()
        .frame(width: 900, height: 700)
}
