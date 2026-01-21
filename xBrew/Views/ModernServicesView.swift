import SwiftUI

/// Modern services view with status controls
struct ModernServicesView: View {
    @StateObject private var servicesManager = HomebrewServicesManager.shared
    
    @State private var searchText = ""
    
    var filteredServices: [BrewService] {
        guard !searchText.isEmpty else { return servicesManager.services }
        return servicesManager.services.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Services")
                            .font(.system(size: DesignSystem.Typography.largeTitle, weight: .bold))
                        
                        Text("\(servicesManager.runningServicesCount) running • \(servicesManager.services.count) total")
                            .font(.system(size: DesignSystem.Typography.body))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        Task { await servicesManager.refreshServices() }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                }
                
                SearchBar(text: $searchText, placeholder: "Search services...")
                    .frame(maxWidth: 400)
            }
            .padding(DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.background)
            
            Divider()
            
            // Content
            if filteredServices.isEmpty {
                emptyState
            } else {
                servicesList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
    
    private var servicesList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(filteredServices) { service in
                    ServiceCard(service: service)
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "gearshape.2")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Services Found")
                .font(.system(size: DesignSystem.Typography.title2, weight: .semibold))
            
            Text("Install packages that provide services")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Service Card

struct ServiceCard: View {
    let service: BrewService
    @StateObject private var servicesManager = HomebrewServicesManager.shared
    
    @State private var isHovered = false
    @State private var isToggling = false
    
    var isRunning: Bool {
        service.status == .running
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Status Indicator
            VStack {
                Circle()
                    .fill(isRunning ? DesignSystem.Colors.success : DesignSystem.Colors.gray400)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .fill(isRunning ? DesignSystem.Colors.success : .clear)
                            .scaleEffect(isRunning ? 1.5 : 1.0)
                            .opacity(isRunning ? 0 : 0.8)
                            .animation(
                                isRunning ? Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false) : .default,
                                value: isRunning
                            )
                    )
            }
            .frame(width: 32)
            
            // Service Info
            VStack(alignment: .leading, spacing: 4) {
                Text(service.name)
                    .font(.system(size: DesignSystem.Typography.headline, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text(service.status.rawValue.capitalized)
                        .font(.system(size: DesignSystem.Typography.caption1))
                        .foregroundColor(.secondary)
                    
                    if let user = service.user {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("User: \(user)")
                            .font(.system(size: DesignSystem.Typography.caption1))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Actions
            if isHovered || isToggling {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if isToggling {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 60)
                    } else {
                        if isRunning {
                            Button {
                                toggleService(start: false)
                            } label: {
                                Label("Stop", systemImage: "stop.circle.fill")
                                    .font(.system(size: DesignSystem.Typography.caption1, weight: .medium))
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .tint(.red)
                        } else {
                            Button {
                                toggleService(start: true)
                            } label: {
                                Label("Start", systemImage: "play.circle.fill")
                                    .font(.system(size: DesignSystem.Typography.caption1, weight: .medium))
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        
                        Button {
                            toggleService(start: !isRunning)
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .modernCard()
        .animation(DesignSystem.Animation.fast, value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private func toggleService(start: Bool) {
        isToggling = true
        Task {
            if start {
                _ = await servicesManager.startService(service.name)
            } else {
                _ = await servicesManager.stopService(service.name)
            }
            await servicesManager.refreshServices()
            isToggling = false
        }
    }
}

#Preview {
    ModernServicesView()
        .frame(width: 900, height: 700)
}
