import Foundation

/// HomebrewManager Extension - Tap Management
extension HomebrewManager {
    
    // MARK: - Tap Management
    
    func refreshTaps() async {
        guard let output = await runBrewCommand(["tap"]) else { return }
        
        let tapNames = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        var newTaps: [BrewTap] = []
        
        for tapName in tapNames {
            let count = packages.filter { $0.name.starts(with: "\(tapName)/") }.count +
                       casks.filter { $0.name.starts(with: "\(tapName)/") }.count
            
            let isOfficial = tapName.hasPrefix("homebrew/")
            
            newTaps.append(BrewTap(
                name: tapName,
                packageCount: count,
                isOfficial: isOfficial
            ))
        }
        
        taps = newTaps
    }
    
    func tap(_ tapName: String) async {
        isUpdating = true
        defer { isUpdating = false }
        
        _ = await runBrewCommand(["tap", tapName])
        await refreshTaps()
    }
    
    func untap(_ tapName: String) async {
        isUpdating = true
        defer { isUpdating = false }
        
        _ = await runBrewCommand(["untap", tapName])
        await refreshTaps()
    }
}
