import SwiftUI

struct CategoryHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(AppTheme.primaryDark)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AppTheme.primaryLight.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: AppTheme.primary.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.top, 28)
            .padding(.bottom, 12)
    }
} 