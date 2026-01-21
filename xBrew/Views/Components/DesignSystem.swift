import SwiftUI

// MARK: - Modern Design System for xBrew

/// Design tokens following macOS Ventura/Sonoma design language
enum DesignSystem {
    
    // MARK: - Colors
    
    enum Colors {
        // Primary/Accent - Vibrant gradient blues
        static let primary = Color(red: 0.0, green: 0.48, blue: 1.0) // #007AFF (iOS blue)
        static let primaryLight = Color(red: 0.2, green: 0.56, blue: 1.0)
        static let primaryDark = Color(red: 0.0, green: 0.38, blue: 0.9)
        
        // Semantic Colors
        static let success = Color(red: 0.2, green: 0.78, blue: 0.35) // #34C759
        static let warning = Color(red: 1.0, green: 0.58, blue: 0.0) // #FF9500
        static let error = Color(red: 1.0, green: 0.23, blue: 0.19) // #FF3B30
        static let info = Color(red: 0.35, green: 0.78, blue: 0.98) // #5AC8FA
        
        // Neutral Grays (adaptive for light/dark mode)
        static let gray50 = Color(nsColor: .controlBackgroundColor)
        static let gray100 = Color(nsColor: .controlColor)
        static let gray200 = Color(nsColor: .separatorColor)
        static let gray300 = Color(nsColor: .quaternaryLabelColor)
        static let gray400 = Color(nsColor: .tertiaryLabelColor)
        static let gray500 = Color(nsColor: .secondaryLabelColor)
        static let gray600 = Color(nsColor: .labelColor)
        static let gray900 = Color(nsColor: .textColor)
        
        // Background
        static let background = Color(nsColor: .windowBackgroundColor)
        static let cardBackground = Color(nsColor: .controlBackgroundColor)
        static let sidebarBackground = Color(nsColor: .controlBackgroundColor)
        
        // Card colors (for hover effects)
        static let card = Color(nsColor: .controlBackgroundColor)
        static let cardHover = Color(nsColor: .controlColor)
        
        // Special Effects
        static let glass = Color.white.opacity(0.05)
        static let glassStroke = Color.white.opacity(0.1)
    }
    
    // MARK: - Typography
    
    enum Typography {
        // Font Sizes
        static let largeTitle: CGFloat = 28
        static let title1: CGFloat = 22
        static let title2: CGFloat = 17
        static let title3: CGFloat = 15
        static let headline: CGFloat = 13
        static let body: CGFloat = 13
        static let callout: CGFloat = 12
        static let caption1: CGFloat = 11
        static let caption2: CGFloat = 10
        
        // Font Weights
        enum Weight {
            static let black = Font.Weight.black
            static let heavy = Font.Weight.heavy
            static let bold = Font.Weight.bold
            static let semibold = Font.Weight.semibold
            static let medium = Font.Weight.medium
            static let regular = Font.Weight.regular
            static let light = Font.Weight.light
            static let thin = Font.Weight.thin
        }
    }
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    
    enum Radius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let medium: CGFloat = 8  // Alias for md
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 20
        static let xxxl: CGFloat = 24
        static let full: CGFloat = 9999
    }
    
    // Alias for compatibility
    typealias CornerRadius = Radius
    
    // MARK: - Shadows
    
    enum Shadow {
        static let low = (color: Color.black.opacity(0.08), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.12), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let high = (color: Color.black.opacity(0.16), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let fast: SwiftUI.Animation = .easeInOut(duration: 0.15)
        static let medium: SwiftUI.Animation = .easeInOut(duration: 0.25)
        static let slow: SwiftUI.Animation = .easeInOut(duration: 0.35)
        static let spring: SwiftUI.Animation = .spring(response: 0.3, dampingFraction: 0.7)
    }
    
    // MARK: - Layout
    
    enum Layout {
        static let sidebarWidth: CGFloat = 220
        static let cardMinWidth: CGFloat = 280
        static let cardMaxWidth: CGFloat = 380
        static let detailPanelWidth: CGFloat = 320
    }
}

// MARK: - Convenience Extensions

extension Color {
    static let ds = DesignSystem.Colors.self
}

extension CGFloat {
    static let ds = DesignSystem.Spacing.self
}
