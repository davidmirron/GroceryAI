import SwiftUI

struct DarkModeTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .foregroundColor(AppTheme.text)
            .background(AppTheme.textFieldBackground)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(AppTheme.borderColor, lineWidth: 1)
            )
    }
}

extension View {
    func darkModeTextFieldStyle() -> some View {
        self.modifier(DarkModeTextFieldModifier())
    }
} 