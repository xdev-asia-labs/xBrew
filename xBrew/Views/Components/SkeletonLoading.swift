import SwiftUI

// MARK: - Skeleton Loading Components

/// A shimmer effect modifier for skeleton loading
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Skeleton Shapes

/// A skeleton placeholder view that mimics content while loading
struct SkeletonView: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var cornerRadius: CGFloat = DesignSystem.Radius.sm
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .shimmer()
    }
}

/// Skeleton for a stat card
struct SkeletonStatCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                SkeletonView(width: 40, height: 40, cornerRadius: DesignSystem.Radius.md)
                Spacer()
                SkeletonView(width: 24, height: 24, cornerRadius: 12)
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                SkeletonView(width: 60, height: 28)
                SkeletonView(width: 80, height: 12)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(DesignSystem.Radius.lg)
    }
}

/// Skeleton for a package row
struct SkeletonPackageRow: View {
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon placeholder
            SkeletonView(width: 36, height: 36, cornerRadius: DesignSystem.Radius.md)
            
            // Text content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                SkeletonView(width: 120, height: 14)
                SkeletonView(width: 60, height: 10)
            }
            
            Spacer()
            
            // Action button placeholder
            SkeletonView(width: 70, height: 24, cornerRadius: DesignSystem.Radius.md)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(DesignSystem.Radius.md)
    }
}

/// Skeleton for service row
struct SkeletonServiceRow: View {
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Status indicator
            SkeletonView(width: 8, height: 8, cornerRadius: 4)
            
            // Service info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                SkeletonView(width: 100, height: 14)
                SkeletonView(width: 150, height: 10)
            }
            
            Spacer()
            
            // Toggle placeholder
            SkeletonView(width: 50, height: 24, cornerRadius: 12)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(DesignSystem.Radius.md)
    }
}

/// Skeleton for dashboard stat cards row
struct SkeletonDashboardStats: View {
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ForEach(0..<4, id: \.self) { _ in
                SkeletonStatCard()
            }
        }
    }
}

/// Skeleton for package list
struct SkeletonPackageList: View {
    var count: Int = 5
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(0..<count, id: \.self) { _ in
                SkeletonPackageRow()
            }
        }
    }
}

/// Skeleton for service list
struct SkeletonServiceList: View {
    var count: Int = 4
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(0..<count, id: \.self) { _ in
                SkeletonServiceRow()
            }
        }
    }
}

// MARK: - Dashboard Skeleton

struct DashboardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Header
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                SkeletonView(width: 200, height: 24)
                SkeletonView(width: 150, height: 12)
            }
            
            // Stat cards
            SkeletonDashboardStats()
            
            // Recent section
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                SkeletonView(width: 140, height: 18)
                SkeletonPackageList(count: 3)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
    }
}

// MARK: - Package View Skeleton

struct PackageViewSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Search bar skeleton
            SkeletonView(height: 36, cornerRadius: DesignSystem.Radius.md)
            
            // Filter chips
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonView(width: 60, height: 24, cornerRadius: 12)
                }
                Spacer()
            }
            
            // Package list
            SkeletonPackageList(count: 8)
        }
        .padding(DesignSystem.Spacing.lg)
    }
}

// MARK: - Services View Skeleton

struct ServicesViewSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Header
            SkeletonView(width: 180, height: 24)
            
            // Stats row
            HStack(spacing: DesignSystem.Spacing.md) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        SkeletonView(width: 32, height: 32, cornerRadius: 8)
                        SkeletonView(width: 40, height: 12)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(DesignSystem.Radius.lg)
            
            // Service list
            SkeletonServiceList(count: 5)
        }
        .padding(DesignSystem.Spacing.lg)
    }
}

// MARK: - Preview

#Preview("Skeleton Components") {
    VStack(spacing: 20) {
        SkeletonStatCard()
            .frame(width: 200)
        
        SkeletonPackageRow()
            .frame(width: 400)
        
        SkeletonServiceRow()
            .frame(width: 400)
    }
    .padding()
}

#Preview("Dashboard Skeleton") {
    DashboardSkeleton()
        .frame(width: 800, height: 600)
}
