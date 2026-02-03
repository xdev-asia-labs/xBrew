import SwiftUI

/// Support View - Encourage users to support the developer
struct SupportView: View {
    @State private var isHovering = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                Spacer(minLength: 40)
                
                // Heart Icon with animation
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isHovering ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isHovering)
                    .onAppear { isHovering = true }
                
                // Title
                Text("Hỗ trợ xBrew")
                    .font(.system(size: 32, weight: .bold))
                
                // Message
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("Cảm ơn bạn đã sử dụng xBrew!")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text(supportMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .frame(maxWidth: 500)
                }
                .padding(.horizontal, 40)
                
                // Buy Me a Coffee Button
                Link(destination: URL(string: "https://buymeacoffee.com/tdduydev")!) {
                    HStack(spacing: 12) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.title2)
                        Text("Buy Me a Coffee")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "FF813F"), Color(hex: "FF5F5F")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
                }
                .buttonStyle(.plain)
                .padding(.top, 10)
                
                // Alternative support options
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Hoặc bạn có thể hỗ trợ bằng cách:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: DesignSystem.Spacing.lg) {
                        supportOption(icon: "star.fill", text: "Đánh giá 5 sao", color: .yellow)
                        supportOption(icon: "square.and.arrow.up", text: "Chia sẻ app", color: .blue)
                        supportOption(icon: "ladybug.fill", text: "Báo lỗi", color: .red)
                    }
                }
                .padding(.top, 20)
                
                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
    
    private var supportMessage: String {
        """
        xBrew được phát triển bởi một developer độc lập với tình yêu dành cho cộng đồng macOS.
        
        Mỗi ly cà phê bạn mua sẽ giúp mình có thêm động lực để:
        • 🐛 Sửa lỗi nhanh hơn
        • ✨ Phát triển tính năng mới
        • 🚀 Cải thiện hiệu suất
        • 💪 Tiếp tục duy trì dự án miễn phí
        
        Sự hỗ trợ của bạn, dù lớn hay nhỏ, đều có ý nghĩa rất lớn với mình!
        """
    }
    
    private func supportOption(icon: String, text: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 100)
        .padding()
        .background(Color(nsColor: .textBackgroundColor))
        .cornerRadius(12)
    }
}

// Color extension for hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    SupportView()
        .frame(width: 800, height: 600)
}
