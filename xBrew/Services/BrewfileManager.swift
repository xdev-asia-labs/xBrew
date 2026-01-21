import Foundation
import Combine
import UniformTypeIdentifiers

/// Brewfile Manager with iCloud Sync
/// Manages Brewfile import/export and iCloud synchronization
@MainActor
final class BrewfileManager: ObservableObject {
    static let shared = BrewfileManager()
    
    @Published var isImporting = false
    @Published var isExporting = false
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    
    // iCloud container
    private let iCloudContainerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    private let brewfileName = "Brewfile"
    
    private init() {
        // Check iCloud availability
        setupiCloudSync()
    }
    
    private func setupiCloudSync() {
        // Monitor iCloud for changes
        if let iCloudURL = iCloudContainerURL {
            print("📱 iCloud container available at: \(iCloudURL.path)")
        } else {
            print("⚠️ iCloud not available")
        }
    }
    
    // MARK: - Export
    
    /// Quick export Brewfile to ~/Downloads
    func quickExport() async -> URL? {
        isExporting = true
        defer { isExporting = false }
        
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmm"
        let dateString = dateFormatter.string(from: Date())
        
        guard let destinationURL = downloadsURL?.appendingPathComponent("Brewfile_\(dateString)") else {
            return nil
        }
        
        // Run brew bundle dump
        guard let output = await runBrewCommand(["bundle", "dump", "--file=\(destinationURL.path)", "--force"]) else {
            return nil
        }
        
        print("✅ Exported Brewfile: \(output)")
        return destinationURL
    }
    
    /// Export to iCloud Drive
    func exportToiCloud() async -> Bool {
        guard let iCloudURL = iCloudContainerURL else {
            print("❌ iCloud not available")
            return false
        }
        
        isExporting = true
        isSyncing = true
        defer {
            isExporting = false
            isSyncing = false
        }
        
        // Create Documents folder if needed
        try? FileManager.default.createDirectory(at: iCloudURL, withIntermediateDirectories: true)
        
        let destinationURL = iCloudURL.appendingPathComponent(brewfileName)
        
        // Export Brewfile
        guard let _ = await runBrewCommand(["bundle", "dump", "--file=\(destinationURL.path)", "--force"]) else {
            return false
        }
        
        lastSyncDate = Date()
        print("☁️ Synced to iCloud: \(destinationURL.path)")
        return true
    }
    
    // MARK: - Import
    
    /// Import Brewfile from URL
    func importBrewfile(from url: URL) async -> (success: Bool, message: String) {
        isImporting = true
        defer { isImporting = false }
        
        guard url.startAccessingSecurityScopedResource() else {
            return (false, "Could not access file")
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            return (false, "Brewfile not found at: \(url.path)")
        }
        
        print("📥 Importing Brewfile from: \(url.path)")
        
        // Run brew bundle install
        guard let output = await runBrewCommand(["bundle", "install", "--file=\(url.path)"]) else {
            return (false, "Import failed - brew bundle command error")
        }
        
        print("✅ Import completed: \(output)")
        return (true, "Successfully imported Brewfile\n\n\(output)")
    }
    
    /// Import from iCloud Drive
    func importFromiCloud() async -> (success: Bool, message: String) {
        guard let iCloudURL = iCloudContainerURL else {
            return (false, "iCloud not available")
        }
        
        isSyncing = true
        defer { isSyncing = false }
        
        let brewfileURL = iCloudURL.appendingPathComponent(brewfileName)
        
        guard FileManager.default.fileExists(atPath: brewfileURL.path) else {
            return (false, "No Brewfile found in iCloud Drive")
        }
        
        let result = await importBrewfile(from: brewfileURL)
        if result.success {
            lastSyncDate = Date()
        }
        return result
    }
    
    /// Check if Brewfile exists in iCloud
    func hasiCloudBrewfile() -> Bool {
        guard let iCloudURL = iCloudContainerURL else { return false }
        let brewfileURL = iCloudURL.appendingPathComponent(brewfileName)
        return FileManager.default.fileExists(atPath: brewfileURL.path)
    }
    
    // MARK: - Helper
    
    private func runBrewCommand(_ args: [String]) async -> String? {
        let brewPath = findBrewPath()
        guard let path = brewPath else { return nil }
        
        return await withCheckedContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = args
            
            var env = ProcessInfo.processInfo.environment
            env["HOMEBREW_NO_AUTO_UPDATE"] = "1"
            process.environment = env
            
            let pipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = pipe
            process.standardError = errorPipe
            
            do {
                try process.run()
                process.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                
                var output = String(data: data, encoding: .utf8) ?? ""
                if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
                    output += "\n\nErrors:\n\(errorOutput)"
                }
                
                continuation.resume(returning: output)
            } catch {
                continuation.resume(returning: "Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func findBrewPath() -> String? {
        let paths = [
            "/opt/homebrew/bin/brew",
            "/usr/local/bin/brew"
        ]
        return paths.first { FileManager.default.isExecutableFile(atPath: $0) }
    }
}
