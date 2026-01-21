import Foundation

/// Configuration Service for xBrew
/// Centralized settings and configuration management
final class AppConfig {
    static let shared = AppConfig()
    
    // MARK: - Homebrew Settings
    
    /// Homebrew command timeout (seconds)
    static let commandTimeout: TimeInterval = 300  // 5 minutes
    
    /// Cache expiration time (seconds)
    static let cacheTimeout: TimeInterval = 300  // 5 minutes
    
    /// Maximum concurrent package operations
    static let maxConcurrentOperations: Int = 4
    
    // MARK: - Homebrew Paths
    
    /// Possible Homebrew installation paths
    static let brewPaths = [
        "/opt/homebrew/bin/brew",  // Apple Silicon (M1/M2/M3)
        "/usr/local/bin/brew"       // Intel Macs
    ]
    
    /// Homebrew Cellar paths
    static let cellarPaths = [
        "/opt/homebrew/Cellar",     // Apple Silicon
        "/usr/local/Cellar"         // Intel
    ]
    
    // MARK: - Environment Variables
    
    /// Disable automatic Homebrew updates during operations
    static let disableAutoUpdate = true
    
    /// Disable Homebrew analytics
    static let disableAnalytics = true
    
    /// Enable verbose output for debugging
    static let verboseOutput = false
    
    // MARK: - UI Settings
    
    /// Enable animations
    static let enableAnimations = true
    
    /// Animation duration (seconds)
    static let animationDuration: Double = 0.25
    
    /// Card hover animation duration
    static let hoverAnimationDuration: Double = 0.15
    
    // MARK: - iCloud Settings
    
    /// iCloud container identifier
    static let iCloudContainerID = "iCloud.asia.xdev.xBrew"
    
    /// Auto-sync Brewfile to iCloud
    static let autoSyncToiCloud = false
    
    // MARK: - Helper Methods
    
    /// Get environment variables for Homebrew commands
    static func brewEnvironment() -> [String: String] {
        var env = ProcessInfo.processInfo.environment
        
        if disableAutoUpdate {
            env["HOMEBREW_NO_AUTO_UPDATE"] = "1"
        }
        
        if disableAnalytics {
            env["HOMEBREW_NO_ANALYTICS"] = "1"
        }
        
        if verboseOutput {
            env["HOMEBREW_VERBOSE"] = "1"
        }
        
        return env
    }
    
    private init() {}
}
