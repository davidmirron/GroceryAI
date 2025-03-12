import SwiftUI

/// A standardized indicator for meal types that provides consistent visual language across the app
struct MealTypeIndicator: View {
    let mealType: MealType
    let style: IndicatorStyle
    let size: CGFloat
    
    enum IndicatorStyle {
        case dot           // Simple colored dot
        case badge         // Pills/capsule with count
        case filledCircle  // Filled circle with optional text
    }
    
    init(mealType: MealType, style: IndicatorStyle = .dot, size: CGFloat = 12) {
        self.mealType = mealType
        self.style = style
        self.size = size
    }
    
    var body: some View {
        switch style {
        case .dot:
            Circle()
                .fill(mealType.themeColor)
                .frame(width: size, height: size)
                .accessibilityHidden(true)
            
        case .badge:
            Text("1")
                .font(.caption2.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(mealType.themeColor))
                .accessibilityLabel("\(mealType.displayName)")
                
        case .filledCircle:
            ZStack {
                Circle()
                    .fill(mealType.themeColor)
                    .frame(width: size, height: size)
                
                // If we have a larger size, we could add an icon or text
                if size > 24 {
                    Image(systemName: mealType.iconName)
                        .font(.system(size: size * 0.5))
                        .foregroundColor(.white)
                }
            }
            .accessibilityHidden(true)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 16) {
            ForEach(MealType.allCases, id: \.self) { type in
                MealTypeIndicator(mealType: type, style: .dot, size: 12)
            }
        }
        
        HStack(spacing: 16) {
            ForEach(MealType.allCases, id: \.self) { type in
                MealTypeIndicator(mealType: type, style: .badge)
            }
        }
        
        HStack(spacing: 16) {
            ForEach(MealType.allCases, id: \.self) { type in
                MealTypeIndicator(mealType: type, style: .filledCircle, size: 40)
            }
        }
    }
    .padding()
    .background(AppTheme.background)
} 