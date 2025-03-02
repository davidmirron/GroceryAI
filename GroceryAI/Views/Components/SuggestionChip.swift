import SwiftUI

struct SuggestionChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.primaryDark)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.7))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppTheme.primaryLight, lineWidth: 1)
                )
                .shadow(color: AppTheme.primary.opacity(0.1), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
} 