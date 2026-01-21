import SwiftUI
import Foundation

/// Homebrew Installer - Runs installation with embedded terminal view
@MainActor
final class HomebrewInstaller: ObservableObject {
    @Published var isInstalling = false
    @Published var installOutput = ""
    @Published var showInstructions = false
    
    func installHomebrew() async -> Bool {
        isInstalling = true
        installOutput = "🍺 Starting Homebrew installation...\n\n"
        
        defer {
            isInstalling = false
        }
        
        // Use interactive process with pseudo-terminal
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let task = Process()
                task.executableURL = URL(fileURLWithPath: "/bin/bash")
                task.arguments = ["-c", "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""]
                
                // Set up environment
                var env = ProcessInfo.processInfo.environment
                env["NONINTERACTIVE"] = "0" // Allow interactive mode
                task.environment = env
                
                let pipe = Pipe()
                let errorPipe = Pipe()
                
                task.standardOutput = pipe
                task.standardError = errorPipe
                
                // Read output in real-time
                pipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    if !data.isEmpty, let output = String(data: data, encoding: .utf8) {
                        Task { @MainActor in
                            self.installOutput += output
                        }
                    }
                }
                
                errorPipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    if !data.isEmpty, let output = String(data: data, encoding: .utf8) {
                        Task { @MainActor in
                            self.installOutput += output
                        }
                    }
                }
                
                do {
                    try task.run()
                    task.waitUntilExit()
                    
                    let success = task.terminationStatus == 0
                    
                    Task { @MainActor in
                        if success {
                            self.installOutput += "\n\n✅ Homebrew installed successfully!\n"
                        } else {
                            self.installOutput += "\n\n❌ Installation failed. Please check the output above.\n"
                        }
                    }
                    
                    continuation.resume(returning: success)
                } catch {
                    Task { @MainActor in
                        self.installOutput += "\n\n❌ Error: \(error.localizedDescription)\n"
                    }
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    func installWithAppleScript() {
        // Fallback: Open Terminal if needed
        let script = """
        tell application "Terminal"
            activate
            do script "/bin/bash -c \\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\\"; echo ''; echo 'Close this window and restart xBrew'; read -p 'Press Enter...'"
        end tell
        """
        
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
        }
    }
    
    func copyInstallCommand() {
        let command = "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
    }
}
