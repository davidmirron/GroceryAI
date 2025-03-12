import SwiftUI
import UIKit

struct GroceryItemRow: View {
    @EnvironmentObject var viewModel: ShoppingListViewModel
    
    let item: Ingredient
    var isSelected: Bool
    var isFavorite: Bool
    var isEditing: Bool
    var isItemSelected: Bool
    var onToggle: () -> Void
    var onDelete: () -> Void
    var onFavorite: () -> Void
    var onIncreaseQuantity: () -> Void
    var onDecreaseQuantity: () -> Void
    
    @State private var quantity: String = ""
    @State private var showQuantityEditor = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox with improved visual feedback
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? AppTheme.primary : AppTheme.textSecondary, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(AppTheme.primary)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(BorderlessButtonStyle())
            
            // Item details with improved layout
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(isSelected ? AppTheme.textSecondary : .primary)
                        .strikethrough(isSelected)
                    
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                }
                
                // Secondary details with improved information hierarchy
                HStack {
                    Text(categoryDisplayName(item.category))
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("•")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    // Only show "Added today" if not editing
                    if !isEditing {
                        Text("Added today")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if isEditing {
                    onToggle()
                }
            }
            
            Spacer()
            
            // Enhanced quantity controls with better touch targets
            HStack(spacing: 0) {
                Button {
                    // Add subtle haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    // Only decrease if quantity would remain above zero
                    if item.amount > 1 || (item.amount == 1 && item.unit != .pieces) {
                        onDecreaseQuantity()
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 40, height: 40)
                        .foregroundColor(item.amount <= 1 && item.unit == .pieces ? 
                                         (colorScheme == .dark ? .gray : Color.white.opacity(0.6)) : 
                                         .white)
                }
                .disabled(item.amount <= 1 && item.unit == .pieces)
                
                // Quantity display with tap to edit
                Button {
                    quantity = "\(item.amount)"
                    showQuantityEditor = true
                } label: {
                    HStack(spacing: 4) {
                        Text("\(formattedQuantity(item.amount))")
                            .font(.system(size: 15, weight: .medium))
                        
                        Text(unitAbbreviation(for: item.unit))
                            .font(.system(size: 15))
                    }
                    .foregroundColor(.white)
                    .frame(minWidth: 60)
                    .padding(.vertical, 8)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button {
                    // Add subtle haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    onIncreaseQuantity()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? 
                          Color(.systemGray5) : 
                          AppTheme.primary.opacity(0.9))
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.0 : 0.1), radius: 2, x: 0, y: 1)
            )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(isItemSelected && isEditing ? 
                      AppTheme.primary.opacity(0.1) : 
                      colorScheme == .dark ? AppTheme.cardBackground : Color(.systemBackground))
        )
        .contentShape(Rectangle())
        .alert("Edit Quantity", isPresented: $showQuantityEditor) {
            TextField("Quantity", text: $quantity)
                .keyboardType(.decimalPad)
            
            Button("Cancel", role: .cancel) { }
            
            Button("Save") {
                if let newAmount = Double(quantity) {
                    viewModel.setQuantity(item, to: newAmount)
                }
            }
        } message: {
            Text("Enter quantity for \(item.name)")
        }
    }
    
    // Helper function to format quantity (e.g., "1" instead of "1.0")
    private func formattedQuantity(_ amount: Double) -> String {
        return amount.truncatingRemainder(dividingBy: 1) == 0 ? 
            "\(Int(amount))" : 
            String(format: "%.1f", amount)
    }
    
    // Helper to display abbreviated unit
    private func unitAbbreviation(for unit: IngredientUnit) -> String {
        switch unit {
        case .pieces: return "pcs"
        case .grams: return "g"
        case .kilograms: return "kg"
        case .milliliters: return "ml"
        case .liters: return "L"
        case .tablespoons: return "tbsp"
        case .teaspoons: return "tsp"
        case .cups: return "cups"
        case .pounds: return "lb"
        case .ounces: return "oz"
        case .units: return "units"
        }
    }
    
    // Helper to display friendly category names
    private func categoryDisplayName(_ category: IngredientCategory) -> String {
        switch category {
        case .dairy: return "Dairy"
        case .produce: return "Produce"
        case .meat: return "Meat"
        case .pantry: return "Pantry"
        case .frozen: return "Frozen"
        case .other: return "Other"
        case .bakery: return "Bakery"
        case .seafood: return "Seafood"
        case .beverages: return "Beverages"
        }
    }
} 