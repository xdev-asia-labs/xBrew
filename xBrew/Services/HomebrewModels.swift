import Foundation

/**
 # Homebrew Data Models
 
 This file contains all data structures used by the Homebrew manager.
 
 ## Models:
 - `BrewPackage`: Represents a Homebrew formula (command-line tool)
 - `BrewCask`: Represents a Homebrew cask (GUI application)
 - `BrewTap`: Represents a third-party package repository
 - `BrewPackageDetails`: Basic package information
 - `PackageInfo`: Extended package information with metadata
 */

// MARK: - Core Models

/// Represents a Homebrew formula (command-line package)
struct BrewPackage: Identifiable, Hashable {
    let id = UUID()
    let name: String         // Package name (e.g., "wget")
    let version: String      // Installed version (e.g., "1.21.3")
    var isOutdated: Bool     // Whether update is available
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: BrewPackage, rhs: BrewPackage) -> Bool {
        lhs.name == rhs.name
    }
}

/// Represents a Homebrew cask (GUI application)
struct BrewCask: Identifiable, Hashable {
    let id = UUID()
    let name: String         // Cask name (e.g., "visual-studio-code")
    let version: String      // Installed version
    var isOutdated: Bool     // Whether update is available
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: BrewCask, rhs: BrewCask) -> Bool {
        lhs.name == rhs.name
    }
}

/// Represents a Homebrew tap (third-party repository)
struct BrewTap: Identifiable {
    let id = UUID()
    let name: String             // Tap name (e.g., "homebrew/cask-fonts")
    var packageCount: Int = 0    // Number of packages from this tap
    var url: String?             // Repository URL
    var isOfficial: Bool = false // Whether it's an official Homebrew tap
}

// MARK: - Package Details

/// Basic package information from `brew info`
struct BrewPackageDetails {
    let name: String
    let description: String
    let homepage: String
    let dependencies: [String]
}

/// Extended package information with metadata
struct PackageInfo {
    let name: String
    let version: String
    let description: String
    let homepage: String
    let installedDate: Date?          // When package was installed
    let sizeOnDisk: Int64?            // Disk space used (bytes)
    let dependencies: [String]         // Packages this depends on
    let dependents: [String]           // Packages that depend on this
    let caveats: String?              // Post-install notes
    let isPinned: Bool                // Whether version is pinned
    let isOutdated: Bool              // Whether update is available
    let tap: String?                  // Source repository
}
