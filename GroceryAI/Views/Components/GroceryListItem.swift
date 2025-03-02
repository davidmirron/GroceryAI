import SwiftUI

struct GroceryListItem: View {
    @Binding var item: ShoppingListItem
    let onToggle: () -> Void
    let isSelected: Bool
    
    init(item: Binding<ShoppingListItem>, isSelected: Bool = false, onToggle: @escaping () -> Void) {
        self._item = item
        self.isSelected = isSelected
        self.onToggle = onToggle
    }
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(item.isChecked ? AppTheme.primary : AppTheme.primaryLight, lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(
                            item.isChecked ? 
                            AppTheme.primaryGradient.clipShape(RoundedRectangle(cornerRadius: 8)) as! Color : 
                                Color.clear
                        )
                    
                    if item.isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.trailing, 16)
            
            Text(item.ingredient.name)
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.text)
                .strikethrough(item.isChecked)
                .opacity(item.isChecked ? 0.5 : 1)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(isSelected ? Color(AppTheme.primary) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: AppTheme.cardShadowColor, radius: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.primary.opacity(0.08), lineWidth: 1)
        )
        .padding(.bottom, 10)
    }
} 
