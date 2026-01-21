import Foundation

/// HomebrewManager Extension - Package Operations with Terminal Output
extension HomebrewManager {
    
    // MARK: - Package Actions with Output
    
    /// Install package with streaming terminal output
    func installPackage(_ name: String) async -> (success: Bool, message: String) {
        isUpdating = true
        defer { isUpdating = false }
        
        let output = await runBrewCommand(["install", name])
        await refreshPackages()
        
        return (output != nil, output ?? "Installation failed")
    }
    
    /// Uninstall package with streaming terminal output
    func uninstallPackage(_ name: String) async -> (success: Bool, message: String) {
        isUpdating = true
        defer { isUpdating = false }
        
        let output = await runBrewCommand(["uninstall", name])
        await refreshPackages()
        
        return (output != nil, output ?? "Uninstallation failed")
    }
    
    /// Upgrade package with streaming terminal output
    func upgradePackage(_ name: String) async -> (success: Bool, message: String) {
        isUpdating = true
        defer { isUpdating = false }
        
        let output = await runBrewCommand(["upgrade", name])
        
        // Only refresh packages, not full refresh (performance improvement)
        await refreshPackages()
        await refreshOutdated()
        
        return (output != nil, output ?? "Upgrade failed")
    }
    
    /// Upgrade all packages with streaming terminal output
    func upgradeAllPackages() async -> (success: Bool, message: String) {
        isUpdating = true
        defer { isUpdating = false }
        
        let output = await runBrewCommand(["upgrade"])
        
        // Targeted refresh for performance
        await refreshPackages()
        await refreshOutdated()
        
        return (output != nil, output ?? "Upgrade failed")
    }
    
    // MARK: - Cask Actions with Output
    
    /// Install cask with streaming terminal output
    func installCask(_ name: String) async -> (success: Bool, message: String) {
        isUpdating = true
        defer { isUpdating = false }
        
        let output = await runBrewCommand(["install", "--cask", name])
        await refreshCasks()
        
        return (output != nil, output ?? "Installation failed")
    }
    
    /// Uninstall cask with streaming terminal output
    func uninstallCask(_ name: String) async -> (success: Bool, message: String) {
        isUpdating = true
        defer { isUpdating = false }
        
        let output = await runBrewCommand(["uninstall", "--cask", name])
        await refreshCasks()
        
        return (output != nil, output ?? "Uninstallation failed")
    }
    
    /// Upgrade cask with streaming terminal output
    func upgradeCask(_ name: String) async -> (success: Bool, message: String) {
        isUpdating = true
        defer { isUpdating = false }
        
        let output = await runBrewCommand(["upgrade", "--cask", name])
        
        // Targeted refresh
        await refreshCasks()
        await refreshOutdated()
        
        return (output != nil, output ?? "Upgrade failed")
    }
    
    // MARK: - Package Info
    
    func getInfo(_ name: String) async -> String {
        return await runBrewCommand(["info", name]) ?? "Info not available"
    }
    
    func getPackageDetails(_ name: String) async -> BrewPackageDetails? {
        guard let output = await runBrewCommand(["info", "--json=v2", name]) else { return nil }
        
        guard let data = output.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let formulae = json["formulae"] as? [[String: Any]],
              let formula = formulae.first else {
            return nil
        }
        
        let dependencies = (formula["dependencies"] as? [String]) ?? []
        let homepage = (formula["homepage"] as? String) ?? ""
        let description = (formula["desc"] as? String) ?? ""
        
        return BrewPackageDetails(
            name: name,
            description: description,
            homepage: homepage,
            dependencies: dependencies
        )
    }
    
    // MARK: - Detailed Package Info
    
    func getDetailedPackageInfo(_ name: String) async -> PackageInfo? {
        guard let output = await runBrewCommand(["info", "--json=v2", name]) else { return nil }
        
        guard let data = output.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let formulae = json["formulae"] as? [[String: Any]],
              let formula = formulae.first else {
            return nil
        }
        
        let dependencies = (formula["dependencies"] as? [String]) ?? []
        let homepage = (formula["homepage"] as? String) ?? ""
        let description = (formula["desc"] as? String) ?? ""
        let version = (formula["versions"] as? [String: Any])?["stable"] as? String ?? ""
        let caveats = formula["caveats"] as? String
        let tap = formula["tap"] as? String
        
        return PackageInfo(
            name: name,
            version: version,
            description: description,
            homepage: homepage,
            installedDate: nil,
            sizeOnDisk: nil,
            dependencies: dependencies,
            dependents: [],
            caveats: caveats,
            isPinned: false,
            isOutdated: outdatedPackages.contains(name),
            tap: tap
        )
    }
}
