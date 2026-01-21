import SwiftUI

// MARK: - Modern View Modifiers

/// Card style with shadow and hover effect
struct ModernCardModifier: ViewModifier {
    @State private var isHovered = false
    var isPressable: Bool = true
    
    func body(content: Content) -> some View {
        content
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.Radius.lg)
            .shadow(
                color: isHovered ? DesignSystem.Shadow.medium.color : DesignSystem.Shadow.low.color,
                radius: isHovered ? DesignSystem.Shadow.medium.radius : DesignSystem.Shadow.low.radius,
                x: isHovered ? DesignSystem.Shadow.medium.x : DesignSystem.Shadow.low.x,
                y: isHovered ? DesignSystem.Shadow.medium.y : DesignSystem.Shadow.low.y
            )
            .scaleEffect(isPressable && isHovered ? 1.02 : 1.0)
            .animation(DesignSystem.Animation.fast, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

/// Glass panel with blur effect
struct GlassPanelModifier: ViewModifier {
    var material: Material = .ultraThinMaterial
    
    func body(content: Content) -> some View {
        content
            .background(material)
            .cornerRadius(DesignSystem.Radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .stroke(DesignSystem.Colors.glassStroke, lineWidth: 1)
            )
    }
}

/// Status badge
struct StatusBadgeModifier: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: DesignSystem.Typography.caption2, weight: DesignSystem.Typography.Weight.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(color)
            .cornerRadius(DesignSystem.Radius.xs)
    }
}

/// Hover scale animation
struct HoverScaleModifier: ViewModifier {
    @State private var isHovered = false
    var scale: CGFloat = 1.05
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? scale : 1.0)
            .animation(DesignSystem.Animation.spring, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

/// Animated status indicator dot
struct StatusIndicatorModifier: ViewModifier {
    var isActive: Bool
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Circle()
                .fill(isActive ? DesignSystem.Colors.success : DesignSystem.Colors.gray400)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .fill(isActive ? DesignSystem.Colors.success : .clear)
                        .scaleEffect(isPulsing ? 1.5 : 1.0)
                        .opacity(isPulsing ? 0 : 0.8)
                )
                .onAppear {
                    if isActive {
                        withAnimation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                        ) {
                            isPulsing = true
                        }
                    }
                }
            
            content
        }
    }
}

/// Section header style
struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: DesignSystem.Typography.title3, weight: DesignSystem.Typography.Weight.semibold))
            .foregroundColor(.primary)
            .padding(.bottom, DesignSystem.Spacing.xs)
    }
}

/// Interactive button style
struct InteractiveButtonModifier: ViewModifier {
    @State private var isHovered = false
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : (isHovered ? 1.02 : 1.0))
            .animation(DesignSystem.Animation.fast, value: isHovered)
            .animation(DesignSystem.Animation.fast, value: isPressed)
            .onHover { hovering in
                isHovered = hovering
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply modern card styling
    func modernCard(isPressable: Bool = true) -> some View {
        modifier(ModernCardModifier(isPressable: isPressable))
    }
    
    /// Apply glass panel effect
    func glassPanel(material: Material = .ultraThinMaterial) -> some View {
        modifier(GlassPanelModifier(material: material))
    }
    
    /// Apply status badge
    func statusBadge(color: Color) -> some View {
        modifier(StatusBadgeModifier(color: color))
    }
    
    /// Apply hover scale animation
    func hoverScale(_ scale: CGFloat = 1.05) -> some View {
        modifier(HoverScaleModifier(scale: scale))
    }
    
    /// Add status indicator
    func statusIndicator(isActive: Bool) -> some View {
        modifier(StatusIndicatorModifier(isActive: isActive))
    }
    
    /// Apply section header style
    func sectionHeader() -> some View {
        modifier(SectionHeaderModifier())
    }
    
    /// Apply interactive button style
    func interactiveButton() -> some View {
        modifier(InteractiveButtonModifier())
    }
}
