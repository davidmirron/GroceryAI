import SwiftUI

struct QuantityControlStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(AppTheme.quantityControlBackground)
            .cornerRadius(AppTheme.cornerRadiusMedium)
    }
}

extension View {
    func quantityControlStyle() -> some View {
        self.modifier(QuantityControlStyle())
    }
} 