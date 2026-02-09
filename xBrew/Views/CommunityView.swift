import SwiftUI

/// Community View - Community links, feedback, and app support
struct CommunityView: View {
    @State private var isHovering = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                Spacer(minLength: 40)
                
                // Header with icon
                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isHovering ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isHovering)
                        .onAppear { isHovering = true }
                    
                    Text("Cộng đồng xBrew")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("Kết nối với cộng đồng, đóng góp ý kiến và giúp xBrew phát triển tốt hơn!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 500)
                }
                
                // Action Cards
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Rate on App Store
                    CommunityActionCard(
                        icon: "star.fill",
                        iconColor: .yellow,
                        title: "Đánh giá trên App Store",
                        description: "Đánh giá 5 sao giúp xBrew tiếp cận được nhiều người dùng hơn",
                        action: {
                            if let url = URL(string: "macappstore://apps.apple.com/app/id6740168491?action=write-review") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                    )
                    
                    // GitHub - Report Bugs & Features
                    CommunityActionCard(
                        icon: "ladybug.fill",
                        iconColor: .red,
                        title: "Báo lỗi & Yêu cầu tính năng",
                        description: "Mở issue trên GitHub để báo lỗi hoặc đề xuất tính năng mới",
                        action: {
                            if let url = URL(string: "https://github.com/xdev-asia/xBrew/issues") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                    )
                    
                    // GitHub - Star the project
                    CommunityActionCard(
                        icon: "star.circle.fill",
                        iconColor: .purple,
                        title: "Star trên GitHub",
                        description: "Để lại một ⭐ trên GitHub để ủng hộ dự án mã nguồn mở",
                        action: {
                            if let url = URL(string: "https://github.com/xdev-asia/xBrew") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                    )
                    
                    // Homebrew Documentation
                    CommunityActionCard(
                        icon: "book.fill",
                        iconColor: .orange,
                        title: "Tài liệu Homebrew",
                        description: "Tìm hiểu thêm về Homebrew và cách sử dụng các lệnh nâng cao",
                        action: {
                            if let url = URL(string: "https://docs.brew.sh") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                    )
                }
                .frame(maxWidth: 550)
                
                Spacer(minLength: 20)
                
                // Social Links
                HStack(spacing: DesignSystem.Spacing.lg) {
                    Link(destination: URL(string: "https://github.com/xdev-asia/xBrew")!) {
                        Label("GitHub", systemImage: "link")
                    }
                    
                    Link(destination: URL(string: "https://brew.sh")!) {
                        Label("Homebrew", systemImage: "globe")
                    }
                    
                    Link(destination: URL(string: "https://xdev.asia")!) {
                        Label("xDev.asia", systemImage: "building.2")
                    }
                }
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                
                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Community Action Card

struct CommunityActionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(iconColor)
                    .frame(width: 44)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .shadow(color: isHovered ? .black.opacity(0.1) : .clear, radius: 8, y: 2)
            )
            .scaleEffect(isHovered ? 1.01 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    CommunityView()
        .frame(width: 800, height: 600)
}
