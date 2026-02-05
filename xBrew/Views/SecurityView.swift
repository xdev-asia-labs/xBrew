import SwiftUI

/// Security vulnerabilities and recommendations view
struct SecurityView: View {
    @StateObject private var security = SecurityManager.shared
    @StateObject private var brew = HomebrewManager.shared
    
    @State private var showingUpdateOutput = false
    @State private var updateOutput = ""
    
    var body: some View {
        ScrollView {
            if security.isScanning && security.lastAnalysis == nil {
                SecurityViewSkeleton()
            } else if let analysis = security.lastAnalysis {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Header
                    headerSection
                    
                    // Score Card
                    scoreCard(analysis: analysis)
                    
                    // Quick Actions
                    quickActions
                    
                    // Issues by Severity
                    if !analysis.issues.isEmpty {
                        issuesSection(analysis: analysis)
                    } else {
                        noIssuesView
                    }
                    
                    // Last Scan Info
                    lastScanInfo(analysis: analysis)
                }
                .padding(DesignSystem.Spacing.lg)
            } else {
                emptyState
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
        .onAppear {
            if security.lastAnalysis == nil {
                Task { await security.runSecurityScan() }
            }
        }
        .sheet(isPresented: $showingUpdateOutput) {
            TerminalLogSheet(output: updateOutput, title: "Update Packages")
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Security")
                .font(.system(size: DesignSystem.Typography.largeTitle, weight: .bold))
            
            Text("Package vulnerability analysis and recommendations")
                .font(.system(size: DesignSystem.Typography.body))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Score Card
    
    private func scoreCard(analysis: SecurityAnalysis) -> some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
            // Score Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: CGFloat(analysis.score) / 100)
                    .stroke(analysis.gradeColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: analysis.score)
                
                VStack(spacing: 2) {
                    Text(analysis.grade)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(analysis.gradeColor)
                    
                    Text("\(analysis.score)%")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            // Score Details
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Security Score")
                    .font(.system(size: DesignSystem.Typography.title2, weight: .semibold))
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    scoreDetailRow(
                        icon: "exclamationmark.shield.fill",
                        color: .red,
                        label: "Critical",
                        count: analysis.issues.filter { $0.severity == .critical }.count
                    )
                    scoreDetailRow(
                        icon: "exclamationmark.triangle.fill",
                        color: .orange,
                        label: "High",
                        count: analysis.issues.filter { $0.severity == .high }.count
                    )
                    scoreDetailRow(
                        icon: "exclamationmark.circle.fill",
                        color: .yellow,
                        label: "Medium",
                        count: analysis.issues.filter { $0.severity == .medium }.count
                    )
                    scoreDetailRow(
                        icon: "info.circle.fill",
                        color: .blue,
                        label: "Low",
                        count: analysis.issues.filter { $0.severity == .low }.count
                    )
                }
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(DesignSystem.Radius.lg)
    }
    
    private func scoreDetailRow(icon: String, color: Color, label: String, count: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: DesignSystem.Typography.callout))
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: DesignSystem.Typography.callout, weight: .semibold))
                .foregroundColor(count > 0 ? color : .secondary)
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActions: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Button {
                Task {
                    updateOutput = "Updating all packages...\n"
                    showingUpdateOutput = true
                    updateOutput += await security.updateAllPackages()
                }
            } label: {
                Label("Update All Packages", systemImage: "arrow.up.circle.fill")
                    .font(.system(size: DesignSystem.Typography.body, weight: .medium))
            }
            .buttonStyle(.borderedProminent)
            .disabled(security.isScanning || brew.isUpdating)
            
            Button {
                Task { await security.runSecurityScan() }
            } label: {
                if security.isScanning {
                    ProgressView()
                        .controlSize(.small)
                        .frame(width: 16, height: 16)
                } else {
                    Label("Scan Again", systemImage: "arrow.clockwise")
                }
            }
            .buttonStyle(.bordered)
            .disabled(security.isScanning)
            
            Spacer()
            
            if security.isScanning {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    ProgressView()
                        .controlSize(.small)
                    Text(security.scanProgress)
                        .font(.system(size: DesignSystem.Typography.caption1))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Issues Section
    
    private func issuesSection(analysis: SecurityAnalysis) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Issues Found")
                .sectionHeader()
            
            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(analysis.issues) { issue in
                    IssueRow(issue: issue)
                }
            }
        }
    }
    
    // MARK: - No Issues View
    
    private var noIssuesView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            
            Text("All Clear!")
                .font(.system(size: DesignSystem.Typography.title2, weight: .semibold))
            
            Text("No security issues found. Your packages are up to date.")
                .font(.system(size: DesignSystem.Typography.body))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xl)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(DesignSystem.Radius.lg)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("Security Analysis")
                .font(.system(size: DesignSystem.Typography.title2, weight: .semibold))
            
            Text("Run a scan to check your packages for security issues.")
                .font(.system(size: DesignSystem.Typography.body))
                .foregroundColor(.secondary)
            
            Button {
                Task { await security.runSecurityScan() }
            } label: {
                Label("Start Scan", systemImage: "shield.checkerboard")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.xl)
    }
    
    // MARK: - Last Scan Info
    
    private func lastScanInfo(analysis: SecurityAnalysis) -> some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(.secondary)
            
            Text("Last scan: \(analysis.lastScanDate.formatted(date: .abbreviated, time: .shortened))")
                .font(.system(size: DesignSystem.Typography.caption1))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Issue Row

struct IssueRow: View {
    let issue: SecurityIssue
    @StateObject private var brew = HomebrewManager.shared
    
    @State private var isHovered = false
    @State private var isUpdating = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Severity Icon
            Image(systemName: issue.severity.icon)
                .font(.system(size: 20))
                .foregroundColor(issue.severity.color)
                .frame(width: 32)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(issue.packageName)
                        .font(.system(size: DesignSystem.Typography.headline, weight: .semibold))
                    
                    Text(issue.type.rawValue)
                        .font(.system(size: DesignSystem.Typography.caption2))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(issue.severity.color.opacity(0.2))
                        .foregroundColor(issue.severity.color)
                        .cornerRadius(4)
                }
                
                Text(issue.description)
                    .font(.system(size: DesignSystem.Typography.caption1))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if let installed = issue.installedVersion, let latest = issue.latestVersion {
                    Text("\(installed) → \(latest)")
                        .font(.system(size: DesignSystem.Typography.caption2, design: .monospaced))
                        .foregroundColor(.ds.primary)
                }
            }
            
            Spacer()
            
            // Actions
            if isHovered || isUpdating {
                if issue.type == .outdated {
                    Button {
                        Task {
                            isUpdating = true
                            _ = await brew.upgradePackage(issue.packageName)
                            isUpdating = false
                        }
                    } label: {
                        if isUpdating {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Label("Update", systemImage: "arrow.up.circle")
                                .font(.system(size: DesignSystem.Typography.caption1))
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(isUpdating)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(DesignSystem.Radius.md)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Skeleton

struct SecurityViewSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Header skeleton
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                SkeletonView(width: 120, height: 28)
                SkeletonView(width: 280, height: 14)
            }
            
            // Score card skeleton
            HStack(spacing: DesignSystem.Spacing.xl) {
                SkeletonView(width: 120, height: 120, cornerRadius: 60)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    SkeletonView(width: 140, height: 20)
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        ForEach(0..<4, id: \.self) { _ in
                            HStack {
                                SkeletonView(width: 20, height: 20, cornerRadius: 10)
                                SkeletonView(width: 60, height: 14)
                                Spacer()
                                SkeletonView(width: 24, height: 14)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(DesignSystem.Spacing.lg)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(DesignSystem.Radius.lg)
            
            // Actions skeleton
            HStack(spacing: DesignSystem.Spacing.md) {
                SkeletonView(width: 160, height: 32, cornerRadius: 8)
                SkeletonView(width: 100, height: 32, cornerRadius: 8)
                Spacer()
            }
            
            // Issues skeleton
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                SkeletonView(width: 100, height: 18)
                ForEach(0..<5, id: \.self) { _ in
                    SkeletonPackageRow()
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
    }
}

#Preview {
    SecurityView()
        .frame(width: 900, height: 700)
}
