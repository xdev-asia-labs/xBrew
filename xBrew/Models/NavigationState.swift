import SwiftUI

// MARK: - Navigation State

enum NavigationItem: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case formulas = "Formulas"
    case casks = "Casks"
    case services = "Services"
    case taps = "Taps"
    case maintenance = "Maintenance"
    case support = "Support"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .overview: return "chart.bar.fill"
        case .formulas: return "terminal.fill"
        case .casks: return "app.fill"
        case .services: return "gearshape.2.fill"
        case .taps: return "arrow.triangle.branch"
        case .maintenance: return "wrench.and.screwdriver.fill"
        case .support: return "heart.fill"
        }
    }
    
    var description: String {
        switch self {
        case .overview: return "Stats & quick actions"
        case .formulas: return "Command-line packages"
        case .casks: return "GUI applications"
        case .services: return "Background services"
        case .taps: return "Package repositories"
        case .maintenance: return "Cleanup & health"
        case .support: return "Support the developer"
        }
    }
    
    var label: String {
        switch self {
        case .overview: return L10n.overview.localized
        case .formulas: return L10n.packages.localized
        case .casks: return L10n.casks.localized
        case .services: return L10n.services.localized
        case .taps: return "Taps"
        case .maintenance: return L10n.maintenance.localized
        case .support: return "Hỗ trợ"
        }
    }
}

@MainActor
class NavigationState: ObservableObject {
    @Published var selectedItem: NavigationItem = .overview
    @Published var selectedPackage: BrewPackage?
    @Published var selectedCask: BrewCask?
    @Published var searchQuery: String = ""
    @Published var showOutdatedOnly: Bool = false
    @Published var showPackageDetail: Bool = false
}
