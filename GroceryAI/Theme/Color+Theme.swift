import SwiftUI

/// A set of color definitions for both light and dark themes, inspired by the provided HTML design.
/// You can reference these colors in your SwiftUI views based on the current colorScheme.
extension Color {
    // MARK: - Light Mode Colors
    static let lightBackground = Color(red: 245/255, green: 255/255, blue: 250/255)
    static let lightCardBg = Color.white
    static let lightHeaderBg = Color(red: 16/255, green: 185/255, blue: 129/255)   // #10B981
    static let lightHeaderDark = Color(red: 5/255, green: 150/255, blue: 105/255) // #059669
    static let lightChipBg = Color(red: 209/255, green: 250/255, blue: 229/255)   // #D1FAE5
    static let lightChipText = Color(red: 5/255, green: 150/255, blue: 105/255)   // #059669
    static let lightText = Color(red: 31/255, green: 41/255, blue: 55/255)        // #1F2937
    static let lightTextSecondary = Color(red: 107/255, green: 114/255, blue: 128/255) // #6B7280
    static let lightBorder = Color.black.opacity(0.1)
    static let lightCheckboxBorder = Color(red: 16/255, green: 185/255, blue: 129/255)
    static let lightCheckboxBg = Color(red: 16/255, green: 185/255, blue: 129/255)
    static let lightShadow = Color.black.opacity(0.1)
    
    // MARK: - Dark Mode Colors
    static let darkBackground = Color(red: 18/255, green: 18/255, blue: 18/255)  // #121212
    static let darkCardBg = Color(red: 28/255, green: 28/255, blue: 30/255)      // #1C1C1E
    static let darkHeaderBg = Color(red: 13/255, green: 143/255, blue: 108/255)  // #0D8F6C
    static let darkHeaderDark = Color(red: 10/255, green: 112/255, blue: 90/255) // #0A705A
    static let darkChipBg = Color(red: 30/255, green: 58/255, blue: 49/255)      // #1E3A31
    static let darkChipText = Color(red: 126/255, green: 206/255, blue: 169/255) // #7ECEA9
    static let darkText = Color(red: 243/255, green: 244/255, blue: 246/255)     // #F3F4F6
    static let darkTextSecondary = Color(red: 156/255, green: 163/255, blue: 175/255) // #9CA3AF
    static let darkBorder = Color.white.opacity(0.1)
    static let darkCheckboxBorder = Color(red: 13/255, green: 143/255, blue: 108/255)
    static let darkCheckboxBg = Color(red: 13/255, green: 143/255, blue: 108/255)
    static let darkShadow = Color.black.opacity(0.3)
    
    // MARK: - Shared Colors
    static let accent = Color(red: 1.0, green: 149/255, blue: 0)     // #FF9500
    static let error = Color(red: 1.0, green: 59/255,  blue: 48/255) // #FF3B30
    static let success = Color(red: 48/255, green: 209/255, blue: 88/255) // #30D158
} 