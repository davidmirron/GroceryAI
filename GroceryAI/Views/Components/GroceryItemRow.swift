import SwiftUI

struct GroceryItemRow: View {
    let item: Ingredient
    let isSelected: Bool
    let isFavorite: Bool
    let isEditing: Bool
    let isItemSelected: Bool
    
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onFavorite: () -> Void
    let onIncreaseQuantity: () -> Void
    let onDecreaseQuantity: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    @State private var isEditingQuantity = false
    @State private var customQuantity = ""
    @EnvironmentObject var viewModel: ShoppingListViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox with improved animation
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isEditing ? (isItemSelected ? AppTheme.primary : AppTheme.borderColor) : 
                               (isSelected ? AppTheme.primary : AppTheme.borderColor), lineWidth: 2)
                        .frame(width: 26, height: 26)
                        .background(
                            (isEditing ? isItemSelected : isSelected) ? AppTheme.primary : Color.clear,
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                    
                    if isEditing ? isItemSelected : isSelected {
                        Image(systemName: isEditing ? "checkmark" : "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.2, dampingFraction: 0.7), 
                                     value: isEditing ? isItemSelected : isSelected)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Item info with favorite indicator and notes
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.text)
                        .strikethrough(isSelected && !isEditing)
                        .opacity((isSelected && !isEditing) ? 0.5 : 1)
                    
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                    }
                    
                    if item.isPerishable {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.primaryLight)
                    }
                }
                
                if let notes = item.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if !isEditing {
                // Quantity controls with improved styling
                if isEditingQuantity {
                    // Custom quantity input
                    HStack(spacing: 8) {
                        TextField("", text: $customQuantity)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 60)
                            .padding(.vertical, 8)
                            .background(AppTheme.quantityControlBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.borderColor, lineWidth: 1)
                            )
                        
                        Text(item.unit.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.text)
                        
                        Button {
                            if let value = Double(customQuantity), value > 0 {
                                viewModel.setQuantity(item, to: value)
                            }
                            isEditingQuantity = false
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.primary)
                                .font(.system(size: 24))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } else {
                    // Standard quantity controls
                    HStack(spacing: 0) {
                        Button(action: onDecreaseQuantity) {
                            Image(systemName: "minus")
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .foregroundColor(AppTheme.primary)
                        }
                        .contentShape(Rectangle())
                        .buttonStyle(PlainButtonStyle())
                        .opacity(item.amount > 1 ? 1 : 0.5)
                        .disabled(item.amount <= 1)
                        
                        Text("\(Int(item.amount)) \(item.unit.rawValue)")
                            .font(.system(size: 15, weight: .medium))
                            .padding(.horizontal, 10)
                            .foregroundColor(AppTheme.text)
                            .frame(minWidth: 60)
                            .onTapGesture {
                                customQuantity = "\(Int(item.amount))"
                                isEditingQuantity = true
                            }
                        
                        Button(action: onIncreaseQuantity) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .foregroundColor(AppTheme.primary)
                        }
                        .contentShape(Rectangle())
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(AppTheme.quantityControlBackground)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppTheme.borderColor, lineWidth: 1)
                    )
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(colorScheme == .dark ? AppTheme.cardBackground.opacity(0.8) : AppTheme.cardBackground)
                .shadow(color: isPressed ? .clear : (colorScheme == .dark ? Color.clear : AppTheme.cardShadowColor), 
                        radius: isPressed ? 0 : 4,
                        x: 0, y: isPressed ? 0 : 2)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
            }
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            // Toggle after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onToggle()
                withAnimation {
                    isPressed = false
                }
            }
        }
        .contentShape(Rectangle())
    }
} 