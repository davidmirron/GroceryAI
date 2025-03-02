import SwiftUI

struct DarkModeTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
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