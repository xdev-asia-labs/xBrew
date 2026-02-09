import SwiftUI
import Foundation
import AppKit

/// Homebrew Installer - Provides installation guidance for sandboxed App Store version
/// Note: Direct installation is not possible in sandboxed apps, so we guide users through manual installation
@MainActor
final class HomebrewInstaller: ObservableObject {
    @Published var showInstructions = false
    @Published var commandCopied = false
    @Published var terminalOpenFailed = false
    @Published var terminalOpened = false
    
    /// The official Homebrew installation command
    static let installCommand = "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    
    /// Homebrew website URL
    static let homebrewWebsite = URL(string: "https://brew.sh")!
    
    /// Installation steps for users
    static let installationSteps: [(icon: String, title: String, description: String)] = [
        ("1.circle.fill", "Copy the Install Command", "Click the button below to copy the Homebrew installation command to your clipboard."),
        ("2.circle.fill", "Open Terminal", "Click 'Open Terminal' or find Terminal in Applications → Utilities."),
        ("3.circle.fill", "Paste and Run", "Paste the command (⌘V) in Terminal and press Enter. Follow the on-screen prompts."),
        ("4.circle.fill", "Restart xBrew", "Once installation completes, restart xBrew to start managing your packages.")
    ]
    
    /// Copy the Homebrew installation command to clipboard
    func copyInstallCommand() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(Self.installCommand, forType: .string)
        
        // Show feedback
        commandCopied = true
        
        // Reset after 2 seconds
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            commandCopied = false
        }
    }
    
    /// Open Terminal.app using NSWorkspace with completion handler for better error handling
    func openTerminal() {
        let terminalURL = URL(fileURLWithPath: "/System/Applications/Utilities/Terminal.app")
        
        // Use the async configuration API for better error handling
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        
        NSWorkspace.shared.openApplication(at: terminalURL, configuration: configuration) { [weak self] app, error in
            Task { @MainActor in
                if let error = error {
                    print("Failed to open Terminal: \(error.localizedDescription)")
                    self?.terminalOpenFailed = true
                    self?.terminalOpened = false
                    
                    // Reset after 3 seconds
                    Task {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        self?.terminalOpenFailed = false
                    }
                } else if app != nil {
                    self?.terminalOpened = true
                    self?.terminalOpenFailed = false
                    
                    // Reset after 2 seconds
                    Task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        self?.terminalOpened = false
                    }
                }
            }
        }
    }
    
    /// Open Homebrew website
    func openHomebrewWebsite() {
        NSWorkspace.shared.open(Self.homebrewWebsite)
    }
}
