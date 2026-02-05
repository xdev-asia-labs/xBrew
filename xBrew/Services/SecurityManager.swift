import Foundation
import SwiftUI

/// Security issue severity levels
enum SecuritySeverity: String, CaseIterable, Comparable {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var color: Color {
        switch self {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .critical: return "exclamationmark.shield.fill"
        case .high: return "exclamationmark.triangle.fill"
        case .medium: return "exclamationmark.circle.fill"
        case .low: return "info.circle.fill"
        }
    }
    
    static func < (lhs: SecuritySeverity, rhs: SecuritySeverity) -> Bool {
        let order: [SecuritySeverity] = [.critical, .high, .medium, .low]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

/// A security issue model
struct SecurityIssue: Identifiable {
    let id = UUID()
    let packageName: String
    let type: IssueType
    let severity: SecuritySeverity
    let description: String
    let recommendation: String
    let installedVersion: String?
    let latestVersion: String?
    
    enum IssueType: String {
        case outdated = "Outdated Package"
        case deprecated = "Deprecated Package"
        case vulnerability = "Known Vulnerability"
        case orphaned = "Orphaned Package"
    }
}

/// Security analysis result
struct SecurityAnalysis {
    let score: Int // 0-100
    let issues: [SecurityIssue]
    let lastScanDate: Date
    
    var gradeColor: Color {
        switch score {
        case 90...100: return .green
        case 70..<90: return .blue
        case 50..<70: return .yellow
        case 25..<50: return .orange
        default: return .red
        }
    }
    
    var grade: String {
        switch score {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
}

/// Security Manager Service
/// Analyzes installed packages for security issues
@MainActor
final class SecurityManager: ObservableObject {
    static let shared = SecurityManager()
    
    @Published var isScanning = false
    @Published var lastAnalysis: SecurityAnalysis?
    @Published var scanProgress: String = ""
    
    private init() {}
    
    /// Run a full security scan
    func runSecurityScan() async {
        isScanning = true
        scanProgress = "Analyzing packages..."
        defer { isScanning = false }
        
        // Run all checks in parallel for better performance
        async let outdatedTask = analyzeOutdatedPackages()
        async let orphanedTask = analyzeOrphanedPackages()
        async let deprecatedTask = analyzeDeprecatedPackages()
        
        scanProgress = "Running security analysis..."
        
        // Wait for all tasks to complete
        let (outdatedIssues, orphanedIssues, deprecatedIssues) = await (outdatedTask, orphanedTask, deprecatedTask)
        
        var issues: [SecurityIssue] = []
        issues.append(contentsOf: outdatedIssues)
        issues.append(contentsOf: orphanedIssues)
        issues.append(contentsOf: deprecatedIssues)
        
        // Calculate security score
        let score = calculateSecurityScore(issues: issues)
        
        lastAnalysis = SecurityAnalysis(
            score: score,
            issues: issues.sorted { $0.severity < $1.severity },
            lastScanDate: Date()
        )
        
        scanProgress = "Scan complete"
    }
    
    // MARK: - Analysis Methods
    
    private func analyzeOutdatedPackages() async -> [SecurityIssue] {
        guard let output = await runBrewCommand(["outdated", "--json"]) else { return [] }
        
        var issues: [SecurityIssue] = []
        
        do {
            if let data = output.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                // Parse formulae
                if let formulae = json["formulae"] as? [[String: Any]] {
                    for formula in formulae {
                        if let name = formula["name"] as? String,
                           let installedVersions = formula["installed_versions"] as? [String],
                           let currentVersion = formula["current_version"] as? String {
                            
                            let severity = determineSeverity(
                                installed: installedVersions.first ?? "",
                                latest: currentVersion
                            )
                            
                            issues.append(SecurityIssue(
                                packageName: name,
                                type: .outdated,
                                severity: severity,
                                description: "Package is outdated and may contain security fixes in newer versions.",
                                recommendation: "Update to version \(currentVersion)",
                                installedVersion: installedVersions.first,
                                latestVersion: currentVersion
                            ))
                        }
                    }
                }
                
                // Parse casks
                if let casks = json["casks"] as? [[String: Any]] {
                    for cask in casks {
                        if let name = cask["name"] as? String,
                           let installedVersions = cask["installed_versions"] as? String,
                           let currentVersion = cask["current_version"] as? String {
                            
                            issues.append(SecurityIssue(
                                packageName: name,
                                type: .outdated,
                                severity: .medium,
                                description: "Application is outdated.",
                                recommendation: "Update to version \(currentVersion)",
                                installedVersion: installedVersions,
                                latestVersion: currentVersion
                            ))
                        }
                    }
                }
            }
        } catch {
            print("Failed to parse outdated JSON: \(error)")
        }
        
        return issues
    }
    
    private func analyzeOrphanedPackages() async -> [SecurityIssue] {
        guard let output = await runBrewCommand(["autoremove", "--dry-run"]) else { return [] }
        
        var issues: [SecurityIssue] = []
        let lines = output.components(separatedBy: "\n")
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Look for package names that would be removed
            if !trimmed.isEmpty && !trimmed.hasPrefix("==>") && !trimmed.contains("Would remove") {
                issues.append(SecurityIssue(
                    packageName: trimmed,
                    type: .orphaned,
                    severity: .low,
                    description: "This package is no longer required by any other installed package.",
                    recommendation: "Consider removing with `brew autoremove`",
                    installedVersion: nil,
                    latestVersion: nil
                ))
            }
        }
        
        return issues
    }
    
    private func analyzeDeprecatedPackages() async -> [SecurityIssue] {
        // Use cached data from HomebrewManager for fast analysis
        // Deprecated packages are rare, so skip the slow brew info call
        // Instead, check package names against known deprecated patterns
        let brew = HomebrewManager.shared
        var issues: [SecurityIssue] = []
        
        // Known deprecated package patterns (common ones)
        let deprecatedPatterns = ["python@2", "php@7.2", "php@7.3", "node@10", "node@12", "ruby@2.5", "ruby@2.6"]
        
        for package in brew.packages {
            let isDeprecated = deprecatedPatterns.contains { package.name.hasPrefix($0) }
            
            if isDeprecated {
                issues.append(SecurityIssue(
                    packageName: package.name,
                    type: .deprecated,
                    severity: .high,
                    description: "This package version is deprecated and no longer receives updates.",
                    recommendation: "Upgrade to a newer version or find an alternative",
                    installedVersion: package.version,
                    latestVersion: nil
                ))
            }
        }
        
        return issues
    }
    
    private func getPackageInfo(_ name: String) async -> String? {
        return await runBrewCommand(["info", name])
    }
    
    // MARK: - Helpers
    
    private func determineSeverity(installed: String, latest: String) -> SecuritySeverity {
        // Simple heuristic: major version difference = high, minor = medium, patch = low
        let installedParts = installed.split(separator: ".").compactMap { Int($0) }
        let latestParts = latest.split(separator: ".").compactMap { Int($0) }
        
        guard installedParts.count >= 1 && latestParts.count >= 1 else { return .medium }
        
        // Major version difference
        if latestParts[0] > installedParts[0] {
            let diff = latestParts[0] - installedParts[0]
            return diff >= 2 ? .critical : .high
        }
        
        // Minor version difference
        if latestParts.count >= 2 && installedParts.count >= 2 {
            if latestParts[1] > installedParts[1] {
                let diff = latestParts[1] - installedParts[1]
                return diff >= 5 ? .high : .medium
            }
        }
        
        return .low
    }
    
    private func calculateSecurityScore(issues: [SecurityIssue]) -> Int {
        if issues.isEmpty { return 100 }
        
        // Use weighted scoring based on severity
        let criticalCount = issues.filter { $0.severity == .critical }.count
        let highCount = issues.filter { $0.severity == .high }.count
        let mediumCount = issues.filter { $0.severity == .medium }.count
        let lowCount = issues.filter { $0.severity == .low }.count
        
        // Calculate weighted penalty (max 100)
        // Critical issues have most impact, but diminishing returns for many issues
        let criticalPenalty = min(30, criticalCount * 10) // max 30 from critical
        let highPenalty = min(25, highCount * 5)          // max 25 from high
        let mediumPenalty = min(25, mediumCount * 2)      // max 25 from medium
        let lowPenalty = min(20, lowCount * 1)            // max 20 from low
        
        let totalPenalty = criticalPenalty + highPenalty + mediumPenalty + lowPenalty
        
        return max(0, 100 - totalPenalty)
    }
    
    private func runBrewCommand(_ arguments: [String]) async -> String? {
        let paths = [
            "/opt/homebrew/bin/brew",
            "/usr/local/bin/brew"
        ]
        
        guard let brewPath = paths.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else {
            return nil
        }
        
        // Run on background thread to avoid blocking main thread
        return await Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: brewPath)
            process.arguments = arguments
            process.environment = [
                "PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin",
                "HOME": NSHomeDirectory(),
                "HOMEBREW_NO_AUTO_UPDATE": "1",
                "HOMEBREW_NO_INSTALL_CLEANUP": "1"
            ]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice
            
            do {
                try process.run()
                
                // Add timeout of 30 seconds
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 30_000_000_000)
                    if process.isRunning {
                        process.terminate()
                    }
                }
                
                process.waitUntilExit()
                timeoutTask.cancel()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                return String(data: data, encoding: .utf8)
            } catch {
                return nil
            }
        }.value
    }
    
    /// Update all outdated packages
    func updateAllPackages() async -> String {
        isScanning = true
        scanProgress = "Updating packages..."
        defer { isScanning = false }
        
        let result = await runBrewCommand(["upgrade"]) ?? "Update failed"
        
        // Re-scan after update
        await runSecurityScan()
        
        return result
    }
}
