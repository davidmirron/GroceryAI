import SwiftUI

struct EmptyStateView: View {
    let category: String
    let iconName: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 36))
                .foregroundColor(AppTheme.primary.opacity(0.8))
            
            Text("No items in \(category)")
                .font(.headline)
                .foregroundColor(AppTheme.text)
            
            Text("Add items with the + button below")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.borderColor, lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// Preview provider
struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmptyStateView(category: "Meat & Seafood", iconName: "cart")
                .preferredColorScheme(.dark)
            
            EmptyStateView(category: "Frozen", iconName: "cart")
                .preferredColorScheme(.light)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 