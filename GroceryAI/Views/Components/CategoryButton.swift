import SwiftUI

struct CategoryButtonView: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppTheme.primary : Color.white)
                        .frame(width: 60, height: 60)
                        .shadow(color: AppTheme.primary.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Text(icon)
                        .font(.system(size: 24))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? AppTheme.primary : AppTheme.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }
} 