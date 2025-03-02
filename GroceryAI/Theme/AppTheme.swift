import SwiftUI

struct AppTheme {
    // MARK: - Primary Colors
    static var primary: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(red: 13/255, green: 143/255, blue: 108/255, alpha: 1) : // #0D8F6C
              UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1)   // #10B981
        })
    }
    
    static var primaryDark: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(red: 10/255, green: 112/255, blue: 90/255, alpha: 1) : // #0A705A
              UIColor(red: 5/255, green: 150/255, blue: 105/255, alpha: 1)   // #059669
        })
    }
    
    static var primaryLight: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(red: 30/255, green: 58/255, blue: 49/255, alpha: 1) : // #1E3A31
              UIColor(red: 209/255, green: 250/255, blue: 229/255, alpha: 1) // #D1FAE5
        })
    }
    
    // MARK: - Secondary Colors
    static var secondary: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(red: 245/255, green: 158/255, blue: 11/255, alpha: 1) : // #F59E0B
              UIColor(red: 249/255, green: 115/255, blue: 22/255, alpha: 1)   // #F97316
        })
    }
    
    static var secondaryLight: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(red: 45/255, green: 40/255, blue: 30/255, alpha: 1) : // #2D281E
              UIColor(red: 254/255, green: 243/255, blue: 199/255, alpha: 1) // #FEF3C7
        })
    }
    
    // MARK: - Background Colors
    static var background: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#121212") : // Dark background
              UIColor(hex: "#F5FFFA")   // Light background
        })
    }
    
    static var backgroundGreen: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1) : // #121212
              UIColor(red: 240/255, green: 253/255, blue: 244/255, alpha: 1) // #F0FDF4
        })
    }
    
    static var backgroundLight: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(red: 30/255, green: 30/255, blue: 32/255, alpha: 1) : // #1E1E20 (slightly lighter than dark background)
              UIColor(red: 250/255, green: 255/255, blue: 252/255, alpha: 1) // #FAFFFC (slightly lighter than light background)
        })
    }
    
    static var cardBackground: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#1C1C1E") : // Dark card background
              UIColor(hex: "#FFFFFF")   // Light card background
        })
    }
    
    static var cardShadowColor: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(red: 0, green: 0, blue: 0, alpha: 0.3) :
              UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        })
    }
    
    // MARK: - Text Colors
    static var text: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#F3F4F6") : // Dark primary text
              UIColor(hex: "#1F2937")   // Light primary text
        })
    }
    
    static var textSecondary: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#9CA3AF") : // Dark secondary text
              UIColor(hex: "#6B7280")   // Light secondary text
        })
    }
    
    // MARK: - Gradients
    static var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primary, primaryDark]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Border Colors
    static var borderColor: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(white: 1, alpha: 0.1) : // Dark border
              UIColor(white: 0, alpha: 0.1)   // Light border
        })
    }
    
    // MARK: - System Colors
    static var error: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#FF6B6B") : // Softer red for dark mode
              UIColor(hex: "#FF3B30")   // Standard red for light mode
        })
    }
    
    static var success: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#4ADE80") : // Softer green for dark mode
              UIColor(hex: "#30D158")   // Standard green for light mode
        })
    }
    
    static var warning: Color {
        Color.yellow
    }
    
    // MARK: - Typography
    static let titleStyle = Font.system(size: 22, weight: .bold)
    static let headlineStyle = Font.system(size: 18, weight: .semibold)
    static let bodyStyle = Font.system(size: 16)
    static let captionStyle = Font.system(size: 14)
    static let smallStyle = Font.system(size: 12)

    // Font definitions
    static let titleFont = Font.system(size: 22, weight: .bold)
    static let headlineFont = Font.system(size: 18, weight: .semibold)
    static let bodyFont = Font.system(size: 16)
    static let smallFont = Font.system(size: 14)
    static let captionFont = Font.system(size: 12)

    // MARK: - Layout Constants
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 20

    // Padding
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 12
    static let paddingLarge: CGFloat = 16
    static let paddingXL: CGFloat = 24

    // Add a new color for text field backgrounds in dark mode
    static var textFieldBackground: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#2C2C2E") : // Dark text field background
              UIColor.white              // Light text field background
        })
    }

    // Add a new color for quick add buttons in dark mode
    static var quickAddButtonBackground: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(red: 25/255, green: 85/255, blue: 65/255, alpha: 1) : // #195541
              UIColor(red: 209/255, green: 250/255, blue: 229/255, alpha: 1) // #D1FAE5
        })
    }

    // Add a new color for recently added items in dark mode
    static var recentItemBackground: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(red: 25/255, green: 85/255, blue: 65/255, alpha: 1) : // #195541
              UIColor(red: 209/255, green: 250/255, blue: 229/255, alpha: 1) // #D1FAE5
        })
    }

    // Add a new color for text on dark backgrounds
    static var textOnDark: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(red: 220/255, green: 255/255, blue: 235/255, alpha: 1) : // #DCFFEB
              UIColor(red: 13/255, green: 143/255, blue: 108/255, alpha: 1) // #0D8F6C
        })
    }

    // MARK: - Header Gradient Colors
    static var headerStart: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#0D8F6C") : // Dark header start
              UIColor(hex: "#10B981")   // Light header start
        })
    }
    
    static var headerEnd: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#0A705A") : // Dark header end
              UIColor(hex: "#059669")   // Light header end
        })
    }

    // MARK: - UI Element Colors
    static var chipBackground: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#1E3A31") : // Dark chip background
              UIColor(hex: "#D1FAE5")   // Light chip background
        })
    }
    
    static var chipText: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#7ECEA9") : // Dark chip text
              UIColor(hex: "#059669")   // Light chip text
        })
    }

    // MARK: - Quantity Control Background
    static var quantityControlBackground: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(white: 1, alpha: 0.1) : // Dark quantity control
              UIColor(white: 0, alpha: 0.05)  // Light quantity control
        })
    }

    // Add teal accent color for interactive elements in dark mode
    static var accentTeal: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#7ECEA9") : // Teal accent for dark mode
              UIColor(hex: "#059669")   // Standard teal for light mode
        })
    }

    // Update tab bar background
    static var tabBarBackground: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(hex: "#1C1C1E") : // Dark gray for dark mode
              UIColor.systemBackground   // Standard background for light mode
        })
    }

    // Update tab bar border color
    static var tabBarBorder: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? 
              UIColor(white: 1, alpha: 0.1) : // Subtle white border for dark mode
              UIColor(white: 0, alpha: 0.1)   // Subtle black border for light mode
        })
    }
}

// Updated Color extension to support light/dark variants
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
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Initialize with different colors for light and dark mode
    init(light lightHex: String, dark darkHex: String) {
        self.init(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(Color(hex: darkHex))
            } else {
                return UIColor(Color(hex: lightHex))
            }
        })
    }
}

// MARK: - UIColor Extension for Hex Support
extension UIColor {
    convenience init(hex: String) {
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
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
} 