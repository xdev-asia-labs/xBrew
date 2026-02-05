import Foundation
import Combine
import UserNotifications

/// Homebrew Package Manager - Core Service
/// Manages Homebrew packages, casks, taps and updates
@MainActor
final class HomebrewManager: ObservableObject {
    static let shared = HomebrewManager()

    // MARK: - Published Properties

    @Published var isBrewInstalled = false
    @Published var packages: [BrewPackage] = []
    @Published var casks: [BrewCask] = []
    @Published var outdatedPackages: [String] = []
    @Published var outdatedCasks: [String] = []
    @Published var taps: [BrewTap] = []
    @Published var isLoading = false
    @Published var isUpdating = false
    @Published var lastError: String?
    @Published var brewVersion: String = ""
    @Published var upgradeProgress: [String: Double] = [:]
    @Published var orphanedPackages: [String] = []

    // MARK: - Private Properties

    private var packageCache: (packages: [BrewPackage], timestamp: Date)?
    private var caskCache: (casks: [BrewCask], timestamp: Date)?
    private var cacheTimeout: TimeInterval { SettingsManager.shared.commandTimeout }
    private var searchIndex: [String: BrewPackage] = [:]
    private var caskSearchIndex: [String: BrewCask] = [:]

    // Background refresh
    private var refreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    private init() {
        detectHomebrew()
        setupBackgroundRefresh()
        requestNotificationPermission()
        
        // Defer loading state to avoid publishing from init
        Task { @MainActor [weak self] in
            self?.isLoading = true
            self?.checkBrewStatus()
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }

    // MARK: - Background Refresh

    private func setupBackgroundRefresh() {
        // Setup initial timer based on current settings
        let settings = SettingsManager.shared
        updateRefreshTimer(enabled: settings.autoCheckUpdates, interval: settings.updateCheckIntervalRaw)
    }

    private func updateRefreshTimer(enabled: Bool, interval: TimeInterval) {
        refreshTimer?.invalidate()
        refreshTimer = nil

        guard enabled, isBrewInstalled else { return }

        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.backgroundRefresh()
            }
        }
    }

    private func backgroundRefresh() async {
        let previousOutdated = totalOutdated
        await refreshOutdated()

        // Notify if new outdated packages found
        let settings = SettingsManager.shared
        if settings.notifyOutdated && totalOutdated > previousOutdated {
            let newCount = totalOutdated - previousOutdated
            if newCount >= settings.outdatedThreshold {
                sendNotification(
                    title: "Updates Available",
                    body: "\(newCount) new package update\(newCount > 1 ? "s" : "") available"
                )
            }
        }
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("✅ Notification permission granted")
            }
        }
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
    
    private func detectHomebrew() {
        let paths = [
            "/opt/homebrew/bin/brew",  // Apple Silicon
            "/usr/local/bin/brew"       // Intel
        ]
        
        print("🔍 Checking for Homebrew...")
        for path in paths {
            let exists = FileManager.default.fileExists(atPath: path)
            let isExecutable = FileManager.default.isExecutableFile(atPath: path)
            print("   \(path): exists=\(exists), executable=\(isExecutable)")
        }
        
        self.isBrewInstalled = paths.contains { FileManager.default.isExecutableFile(atPath: $0) }
        print("🍺 Homebrew detected: \(isBrewInstalled)")
    }
    
    // MARK: - Brew Status
    
    func checkBrewStatus() {
        Task {
            isBrewInstalled = await checkBrewInstalled()
            if isBrewInstalled {
                brewVersion = await getBrewVersion()
                await refreshAll()
            }
        }
    }
    
    private func checkBrewInstalled() async -> Bool {
        let paths = [
            "/opt/homebrew/bin/brew",
            "/usr/local/bin/brew"
        ]
        return paths.contains { FileManager.default.isExecutableFile(atPath: $0) }
    }
    
    private func getBrewVersion() async -> String {
        let output = await runBrewCommand(["--version"])
        return output?.components(separatedBy: "\n").first ?? ""
    }
    
    // MARK: - Refresh Data
    
    func refreshAll(forceRefresh: Bool = false) async {
        isLoading = true
        defer { isLoading = false }
        
        // Check cache
        if !forceRefresh, let cache = packageCache, 
           Date().timeIntervalSince(cache.timestamp) < cacheTimeout {
            return
        }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.refreshPackages() }
            group.addTask { await self.refreshCasks() }
            group.addTask { await self.refreshOutdated() }
        }
    }
    
    func refreshPackages() async {
        guard let output = await runBrewCommand(["list", "--formula", "--versions"]) else { return }
        
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        packages = lines.map { line in
            let parts = line.components(separatedBy: " ")
            let name = parts.first ?? line
            let version = parts.count > 1 ? parts[1] : ""
            return BrewPackage(name: name, version: version, isOutdated: outdatedPackages.contains(name))
        }
        
        packageCache = (packages, Date())
        buildSearchIndex()
    }
    
    func refreshCasks() async {
        guard let output = await runBrewCommand(["list", "--cask", "--versions"]) else { return }
        
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        casks = lines.map { line in
            let parts = line.components(separatedBy: " ")
            let name = parts.first ?? line
            let version = parts.count > 1 ? parts[1] : ""
            return BrewCask(name: name, version: version, isOutdated: outdatedCasks.contains(name))
        }
        
        caskCache = (casks, Date())
    }
    
    func refreshOutdated() async {
        // Outdated formulas
        if let output = await runBrewCommand(["outdated", "--formula", "-q"]) {
            outdatedPackages = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        }
        
        // Outdated casks
        if let output = await runBrewCommand(["outdated", "--cask", "-q"]) {
            outdatedCasks = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        }
        
        // Update status
        packages = packages.map { pkg in
            var p = pkg
            p.isOutdated = outdatedPackages.contains(pkg.name)
            return p
        }
        casks = casks.map { cask in
            var c = cask
            c.isOutdated = outdatedCasks.contains(cask.name)
            return c
        }
    }
    
    // MARK: - Search
    
    func search(_ query: String) async -> [String] {
        let localResults = fastSearch(query)
        if !localResults.isEmpty {
            return localResults
        }
        
        guard let output = await runBrewCommand(["search", query]) else { return [] }
        return output.components(separatedBy: "\n").filter { !$0.isEmpty && !$0.starts(with: "==>") }
    }
    
    func fastSearch(_ query: String) -> [String] {
        let lowercaseQuery = query.lowercased()
        
        if searchIndex.keys.contains(query) || caskSearchIndex.keys.contains(query) {
            return [query]
        }
        
        let packageMatches = searchIndex.keys.filter { $0.lowercased().contains(lowercaseQuery) }
        let caskMatches = caskSearchIndex.keys.filter { $0.lowercased().contains(lowercaseQuery) }
        
        return (packageMatches + caskMatches).sorted()
    }
    
    private func buildSearchIndex() {
        searchIndex = Dictionary(uniqueKeysWithValues: packages.map { ($0.name, $0) })
        caskSearchIndex = Dictionary(uniqueKeysWithValues: casks.map { ($0.name, $0) })
    }
    
    // MARK: - Maintenance

    func updateBrew() async -> String {
        isUpdating = true
        defer {
            isUpdating = false
            notifyIfEnabled(title: "Update Complete", body: "Homebrew has been updated")
        }
        return await runBrewCommand(["update"]) ?? "Update failed"
    }

    func upgradeAll() async -> String {
        isUpdating = true
        defer {
            isUpdating = false
            Task { await refreshOutdated() }
            notifyIfEnabled(title: "Upgrade Complete", body: "All packages have been upgraded")
        }
        return await runBrewCommand(["upgrade"]) ?? "Upgrade failed"
    }

    func cleanup() async -> String {
        isUpdating = true
        defer { isUpdating = false }
        return await runBrewCommand(["cleanup", "-s"]) ?? "Cleanup failed"
    }

    func doctor() async -> String {
        return await runBrewCommand(["doctor"]) ?? "Doctor check failed"
    }

    private func notifyIfEnabled(title: String, body: String) {
        if SettingsManager.shared.notifyUpdateComplete {
            sendNotification(title: title, body: body)
        }
    }

    // MARK: - Stats

    var totalPackages: Int { packages.count + casks.count }
    var totalOutdated: Int { outdatedPackages.count + outdatedCasks.count }
}
