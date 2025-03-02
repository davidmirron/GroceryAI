import SwiftUI

struct CardViewModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(colorScheme == .dark ? AppTheme.borderColor : Color.clear, lineWidth: 1)
            )
            .shadow(
                color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.1),
                radius: 6,
                x: 0,
                y: 2
            )
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardViewModifier())
    }
} 