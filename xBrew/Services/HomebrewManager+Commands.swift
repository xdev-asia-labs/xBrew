import Foundation

/// HomebrewManager Extension - Command Execution with Buffered Streaming
extension HomebrewManager {
    
    // MARK: - Command Execution
    
    /// Execute brew command with buffered output (reduces SwiftUI warnings)
    /// - Parameters:
    ///   - args: Command arguments  
    ///   - outputBuffer: Shared string to accumulate output
    /// - Returns: Full command output or nil if failed
    func runBrewCommandBuffered(_ args: [String], outputBuffer: UnsafeMutablePointer<String>?) async -> String? {
        guard let brewPath = findBrewPath() else {
            await MainActor.run {
                self.lastError = "Homebrew not found"
            }
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: brewPath)
            process.arguments = args
            
            // Set environment from AppConfig
            process.environment = AppConfig.brewEnvironment()
            
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            
            var fullOutput = ""
            
            // Buffered reading - more efficient
            if let buffer = outputBuffer {
                let outputHandle = outputPipe.fileHandleForReading
                let errorHandle = errorPipe.fileHandleForReading
                
                // Read in background
                DispatchQueue.global(qos: .userInitiated).async {
                    while process.isRunning {
                        let data = outputHandle.availableData
                        if !data.isEmpty, let text = String(data: data, encoding: .utf8) {
                            fullOutput += text
                            buffer.pointee += text
                        }
                        
                        let errorData = errorHandle.availableData
                        if !errorData.isEmpty, let text = String(data: errorData, encoding: .utf8) {
                            fullOutput += text
                            buffer.pointee += text
                        }
                        
                        Thread.sleep(forTimeInterval: 0.1) // Buffer updates every 100ms
                    }
                }
            }
            
            do {
                try process.run()
                process.waitUntilExit()
                
                // Final read
                if outputBuffer == nil {
                    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                    fullOutput = (String(data: outputData, encoding: .utf8) ?? "") +
                                (String(data: errorData, encoding: .utf8) ?? "")
                }
                
                if process.terminationStatus != 0 {
                    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                    let error = String(data: errorData, encoding: .utf8) ?? ""
                    Task { @MainActor in
                        self.lastError = error
                    }
                }
                
                continuation.resume(returning: fullOutput.isEmpty ? nil : fullOutput)
            } catch {
                Task { @MainActor in
                    self.lastError = error.localizedDescription
                }
                continuation.resume(returning: nil)
            }
        }
    }
    
    /// Execute brew command with optional real-time output callback
    func runBrewCommand(_ args: [String], outputHandler: ((String) -> Void)? = nil) async -> String? {
        guard let brewPath = findBrewPath() else {
            await MainActor.run {
                self.lastError = "Homebrew not found"
            }
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: brewPath)
            process.arguments = args
            process.environment = AppConfig.brewEnvironment()
            
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            
            var fullOutput = ""
            
            do {
                try process.run()
                
                // Simple blocking read (no callbacks)
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                
                fullOutput = (String(data: outputData, encoding: .utf8) ?? "") +
                            (String(data: errorData, encoding: .utf8) ?? "")
                
                process.waitUntilExit()
                
                if process.terminationStatus != 0 {
                    Task { @MainActor in
                        self.lastError = String(data: errorData, encoding: .utf8) ?? ""
                    }
                }
                
                continuation.resume(returning: fullOutput.isEmpty ? nil : fullOutput)
            } catch {
                Task { @MainActor in
                    self.lastError = error.localizedDescription
                }
                continuation.resume(returning: nil)
            }
        }
    }
    
    /// Find Homebrew executable path
    func findBrewPath() -> String? {
        return AppConfig.brewPaths.first { FileManager.default.isExecutableFile(atPath: $0) }
    }
}
