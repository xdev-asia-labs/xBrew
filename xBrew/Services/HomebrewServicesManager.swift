import Foundation
import Combine

/// Homebrew Services Manager
/// Manages Homebrew services (start, stop, list)
@MainActor
final class HomebrewServicesManager: ObservableObject {
    static let shared = HomebrewServicesManager()
    
    @Published var services: [BrewService] = []
    @Published var isLoading = false
    
    var runningServicesCount: Int {
        services.filter { $0.status == .running }.count
    }
    
    private init() {
        // Services will be refreshed when view appears
    }
    
    func refreshServices() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let output = await runBrewCommand(["services", "list"]) else {
            services = []
            return
        }
        
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        var newServices: [BrewService] = []
        
        for line in lines.dropFirst() { // Skip header
            let components = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
            guard components.count >= 2 else { continue }
            
            let name = components[0]
            let statusString = components[1].lowercased()
            let status: ServiceStatus = statusString.contains("started") ? .running : .stopped
            let user = components.count > 2 ? components[2] : nil
            
            newServices.append(BrewService(
                name: name,
                status: status,
                user: user
            ))
        }
        
        services = newServices
    }
    
    func startService(_ name: String) async -> (success: Bool, message: String) {
        guard let output = await runBrewCommand(["services", "start", name]) else {
            return (false, "Failed to start service")
        }
        return (true, output)
    }
    
    func stopService(_ name: String) async -> (success: Bool, message: String) {
        guard let output = await runBrewCommand(["services", "stop", name]) else {
            return (false, "Failed to stop service")
        }
        return (true, output)
    }
    
    func restartService(_ name: String) async -> (success: Bool, message: String) {
        guard let output = await runBrewCommand(["services", "restart", name]) else {
            return (false, "Failed to restart service")
        }
        return (true, output)
    }
    
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
            process.standardOutput = pipe
            
            do {
                try process.run()
                process.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8)
                continuation.resume(returning: output)
            } catch {
                continuation.resume(returning: nil)
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

// MARK: - Models

enum ServiceStatus: String {
    case running = "started"
    case stopped = "stopped"
}

struct BrewService: Identifiable {
    let id = UUID()
    let name: String
    let status: ServiceStatus
    let user: String?
}
