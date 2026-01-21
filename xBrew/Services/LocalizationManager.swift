import Foundation
import SwiftUI

/// Localization Manager for xBrew
/// Handles language switching between Vietnamese and English
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language {
        didSet {
            // Save immediately (synchronous is OK for UserDefaults)
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
            
            // Update bundle in next run loop to avoid SwiftUI warnings
            Task { @MainActor in
                self.updateBundle()
                // Force UI refresh
                self.objectWillChange.send()
            }
        }
    }
    
    
    private var bundle: Bundle = .main
    
    enum Language: String, CaseIterable {
        case vietnamese = "vi"
        case english = "en"
        
        var displayName: String {
            switch self {
            case .vietnamese: return "Tiếng Việt"
            case .english: return "English"
            }
        }
        
        var flag: String {
            switch self {
            case .vietnamese: return "🇻🇳"
            case .english: return "🇺🇸"
            }
        }
    }
    
    private init() {
        // Load saved language or use system default
        if let savedLang = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLang) {
            self.currentLanguage = language
        } else {
            // Default to Vietnamese
            self.currentLanguage = .vietnamese
        }
        updateBundle()
    }
    
    private func updateBundle() {
        if let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            self.bundle = .main
        }
    }
    
    nonisolated func localize(_ key: String) -> String {
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

// MARK: - String Extension for Easy Localization

extension String {
    var localized: String {
        return LocalizationManager.shared.localize(self)
    }
    
    func localized(_ args: CVarArg...) -> String {
        return String(format: localized, arguments: args)
    }
}

// MARK: - SwiftUI Environment Key

private struct LocalizationKey: EnvironmentKey {
    static let defaultValue = LocalizationManager.shared
}

extension EnvironmentValues {
    var localization: LocalizationManager {
        get { self[LocalizationKey.self] }
        set { self[LocalizationKey.self] = newValue }
    }
}

// MARK: - Localization Keys

enum L10n {
    // Navigation
    static let overview = "navigation.overview"
    static let packages = "navigation.packages"
    static let casks = "navigation.casks"
    static let services = "navigation.services"
    static let maintenance = "navigation.maintenance"
    
    // Dashboard
    static let dashboardTitle = "dashboard.title"
    static let dashboardSubtitle = "dashboard.subtitle"
    static let totalPackages = "dashboard.total_packages"
    static let outdated = "dashboard.outdated"
    static let servicesRunning = "dashboard.services_running"
    static let updatesAvailable = "dashboard.updates_available"
    static let packageDistribution = "dashboard.package_distribution"
    static let formulas = "dashboard.formulas"
    static let quickActions = "dashboard.quick_actions"
    static let updateAll = "dashboard.update_all"
    static let cleanup = "dashboard.cleanup"
    static let healthCheck = "dashboard.health_check"
    static let systemInformation = "dashboard.system_info"
    static let homebrewVersion = "dashboard.homebrew_version"
    static let installed = "dashboard.installed"
    static let total = "dashboard.total"
    static let running = "dashboard.running"
    
    // Packages
    static let packagesTitle = "packages.title"
    static let searchPackages = "packages.search"
    static let outdatedOnly = "packages.outdated_only"
    static let upgrade = "packages.upgrade"
    static let upgradeAll = "packages.upgrade_all"
    static let info = "packages.info"
    static let uninstall = "packages.uninstall"
    static let noPackages = "packages.no_packages"
    static let noPackagesFound = "packages.no_packages_found"
    
    // Maintenance
    static let maintenanceTitle = "maintenance.title"
    static let maintenanceSubtitle = "maintenance.subtitle"
    static let systemHealth = "maintenance.system_health"
    static let healthy = "maintenance.healthy"
    static let needsAttention = "maintenance.needs_attention"
    static let homebrewStatus = "maintenance.homebrew_status"
    static let allUpToDate = "maintenance.all_up_to_date"
    static let needsUpdating = "maintenance.needs_updating"
    static let maintenanceActions = "maintenance.actions"
    static let updateHomebrew = "maintenance.update_homebrew"
    static let runDiagnostics = "maintenance.run_diagnostics"
    static let cleanupOld = "maintenance.cleanup_old"
    static let run = "maintenance.run"
    
    // Brewfile
    static let exportToDownloads = "brewfile.export_downloads"
    static let exportToICloud = "brewfile.export_icloud"
    static let importFromFile = "brewfile.import_file"
    static let importFromICloud = "brewfile.import_icloud"
    static let lastSync = "brewfile.last_sync"
    
    // Common
    static let install = "common.install"
    static let refresh = "common.refresh"
    static let loading = "common.loading"
    static let done = "common.done"
    static let close = "common.close"
    static let cancel = "common.cancel"
    static let save = "common.save"
    static let settings = "common.settings"
    static let language = "common.language"
}
