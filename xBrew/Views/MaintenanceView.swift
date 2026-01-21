import SwiftUI

/// Maintenance center for system health and cleanup
struct MaintenanceView: View {
    @StateObject private var brew = HomebrewManager.shared
    
    @State private var doctorOutput: String = ""
    @State private var cleanupOutput: String = ""
    @State private var showingDoctorOutput = false
    @State private var showingCleanupOutput = false
    @State private var isRunningDoctor = false
    @State private var isRunningCleanup = false
    @State private var isUpdating = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Maintenance")
                        .font(.system(size: DesignSystem.Typography.largeTitle, weight: .bold))
                    
                    Text("Keep your Homebrew installation healthy")
                        .font(.system(size: DesignSystem.Typography.body))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
                
                // System Health
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("System Health")
                        .sectionHeader()
                    
                    HStack(spacing: DesignSystem.Spacing.md) {
                        // Health Status Card
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            HStack {
                                Image(systemName: brew.totalOutdated == 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(brew.totalOutdated == 0 ? .ds.success : .ds.warning)
                                
                                Spacer()
                                
                                Text(brew.totalOutdated == 0 ? "Healthy" : "Needs Attention")
                                    .statusBadge(color: brew.totalOutdated == 0 ? .ds.success : .ds.warning)
                            }
                            
                            Text("Homebrew Status")
                                .font(.system(size: DesignSystem.Typography.headline, weight: .semibold))
                            
                            if brew.totalOutdated > 0 {
                                Text("\(brew.totalOutdated) packages need updating")
                                    .font(.system(size: DesignSystem.Typography.caption1))
                                    .foregroundColor(.secondary)
                            } else {
                                Text("All packages up to date")
                                    .font(.system(size: DesignSystem.Typography.caption1))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(DesignSystem.Spacing.md)
                        .frame(maxWidth: .infinity)
                        .modernCard(isPressable: false)
                        
                        // Homebrew Version
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "mug.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.ds.primary)
                            
                            Text("Homebrew")
                                .font(.system(size: DesignSystem.Typography.headline, weight: .semibold))
                            
                            Text(brew.brewVersion)
                                .font(.system(size: DesignSystem.Typography.caption1))
                                .foregroundColor(.secondary)
                        }
                        .padding(DesignSystem.Spacing.md)
                        .frame(maxWidth: .infinity)
                        .modernCard(isPressable: false)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                // Maintenance Actions
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Maintenance Actions")
                        .sectionHeader()
                    
                    // Update Homebrew
                    MaintenanceActionCard(
                        title: "Update Homebrew",
                        description: "Update Homebrew itself to the latest version",
                        icon: "arrow.down.circle.fill",
                        color: .ds.primary,
                        isLoading: isUpdating,
                        action: {
                            isUpdating = true
                            Task {
                                _ = await brew.updateBrew()
                                await brew.refreshAll(forceRefresh: true)
                                isUpdating = false
                            }
                        }
                    )
                    
                    // Run Doctor
                    MaintenanceActionCard(
                        title: "Run Diagnostics",
                        description: "Check for potential issues with brew doctor",
                        icon: "heart.text.square.fill",
                        color: .ds.success,
                        isLoading: isRunningDoctor,
                        hasOutput: !doctorOutput.isEmpty,
                        action: {
                            isRunningDoctor = true
                            Task {
                                doctorOutput = await brew.doctor()
                                showingDoctorOutput = true
                                isRunningDoctor = false
                            }
                        }
                    )
                    
                    // Cleanup
                    MaintenanceActionCard(
                        title: "Cleanup Old Versions",
                        description: "Remove old package versions to free up disk space",
                        icon: "trash.circle.fill",
                        color: .ds.warning,
                        isLoading: isRunningCleanup,
                        hasOutput: !cleanupOutput.isEmpty,
                        action: {
                            isRunningCleanup = true
                            Task {
                                cleanupOutput = await brew.cleanup()
                                showingCleanupOutput = true
                                isRunningCleanup = false
                            }
                        }
                    )
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
        .sheet(isPresented: $showingDoctorOutput) {
            OutputSheet(title: "Doctor Output", output: doctorOutput)
        }
        .sheet(isPresented: $showingCleanupOutput) {
            OutputSheet(title: "Cleanup Output", output: cleanupOutput)
        }
    }
}

// MARK: - Maintenance Action Card

struct MaintenanceActionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isLoading: Bool
    var hasOutput: Bool = false
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.12))
                .cornerRadius(DesignSystem.Radius.lg)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: DesignSystem.Typography.headline, weight: .semibold))
                
                Text(description)
                    .font(.system(size: DesignSystem.Typography.caption1))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Button(action: action) {
                    Text("Run")
                        .font(.system(size: DesignSystem.Typography.body, weight: .medium))
                }
                .buttonStyle(.borderedProminent)
                .tint(color)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .modernCard()
        .disabled(isLoading)
    }
}

// MARK: - Output Sheet

struct OutputSheet: View {
    let title: String
    let output: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: DesignSystem.Typography.title2, weight: .bold))
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(DesignSystem.Spacing.md)
            
            Divider()
            
            ScrollView {
                Text(output)
                    .font(.system(size: DesignSystem.Typography.caption1, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.gray50)
        }
        .frame(width: 600, height: 400)
    }
}

#Preview {
    MaintenanceView()
        .frame(width: 900, height: 700)
}
