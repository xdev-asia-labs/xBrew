import SwiftUI

/// Modern Taps Management View
struct ModernTapsView: View {
    @StateObject private var brew = HomebrewManager.shared
    @State private var showingAddTap = false
    @State private var newTapName = ""
    @State private var isAdding = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Taps")
                        .font(.system(size: DesignSystem.Typography.largeTitle, weight: DesignSystem.Typography.Weight.bold))
                    
                    Text("Package repositories")
                        .font(.system(size: DesignSystem.Typography.body))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    showingAddTap = true
                } label: {
                    Label("Add Tap", systemImage: "plus.circle.fill")
                        .font(.system(size: DesignSystem.Typography.body, weight: .medium))
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            
            Divider()
            
            // Content
            if brew.taps.isEmpty {
                emptyState
            } else {
                tapsList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
        .onAppear {
            Task {
                await brew.refreshTaps()
            }
        }
        .sheet(isPresented: $showingAddTap) {
            addTapSheet
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Taps Added")
                .font(.system(size: DesignSystem.Typography.title2, weight: .semibold))
            
            Text("Add third-party repositories to access more packages")
                .font(.system(size: DesignSystem.Typography.body))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingAddTap = true
            } label: {
                Label("Add Tap", systemImage: "plus.circle")
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Taps List
    
    private var tapsList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(brew.taps) { tap in
                    TapCard(tap: tap) {
                        // Remove tap
                        Task {
                            await brew.untap(tap.name)
                            await brew.refreshTaps()
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
    
    // MARK: - Add Tap Sheet
    
    private var addTapSheet: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            HStack {
                Text("Add Tap")
                    .font(.system(size: DesignSystem.Typography.title2, weight: .bold))
                
                Spacer()
                
                Button {
                    showingAddTap = false
                    newTapName = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Tap Name")
                    .font(.system(size: DesignSystem.Typography.callout, weight: .medium))
                
                TextField("e.g., homebrew/cask-fonts", text: $newTapName)
                    .textFieldStyle(.roundedBorder)
                
                Text("Format: username/repository")
                    .font(.system(size: DesignSystem.Typography.caption1))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                Button("Cancel") {
                    showingAddTap = false
                    newTapName = ""
                }
                .buttonStyle(.bordered)
                
                Button("Add Tap") {
                    Task {
                        isAdding = true
                        await brew.tap(newTapName)
                        await brew.refreshTaps()
                        isAdding = false
                        showingAddTap = false
                        newTapName = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(newTapName.isEmpty || isAdding)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(width: 500, height: 250)
    }
}

// MARK: - Tap Card

struct TapCard: View {
    let tap: BrewTap
    let onRemove: () -> Void
    
    @State private var isHovered = false
    @State private var showingRemoveConfirm = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 24))
                .foregroundColor(.ds.primary)
                .frame(width: 40, height: 40)
                .background(Color.ds.primary.opacity(0.1))
                .cornerRadius(8)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(tap.name)
                    .font(.system(size: DesignSystem.Typography.body, weight: .semibold))
                
                if let url = tap.url {
                    Text(url)
                        .font(.system(size: DesignSystem.Typography.caption1))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Actions
            if isHovered {
                Button {
                    showingRemoveConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Remove tap")
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(isHovered ? Color.ds.cardHover : Color.ds.card)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .alert("Remove Tap", isPresented: $showingRemoveConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                onRemove()
            }
        } message: {
            Text("Are you sure you want to remove \(tap.name)?")
        }
    }
}
