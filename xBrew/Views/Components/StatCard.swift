import SwiftUI

/// Reusable statistics card for dashboard
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String?
    
    init(title: String, value: String, icon: String, color: Color, trend: String? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.trend = trend
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.12))
                    .cornerRadius(DesignSystem.Radius.md)
                
                Spacer()
                
                if let trend = trend {
                    Text(trend)
                        .font(.system(size: DesignSystem.Typography.caption1, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Text(value)
                .font(.system(size: DesignSystem.Typography.largeTitle, weight: DesignSystem.Typography.Weight.bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: DesignSystem.Typography.callout, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modernCard()
    }
}

#Preview {
    HStack(spacing: 16) {
        StatCard(
            title: "Total Packages",
            value: "127",
            icon: "cube.fill",
            color: .ds.primary,
            trend: "+12"
        )
        
        StatCard(
            title: "Outdated",
            value: "8",
            icon: "arrow.triangle.2.circlepath",
            color: .ds.warning
        )
    }
    .padding()
    .frame(width: 600)
}
