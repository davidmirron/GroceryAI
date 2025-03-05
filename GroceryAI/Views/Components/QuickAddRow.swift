import SwiftUI

// Enhanced Quick Add Row for better usability
struct QuickAddRow: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    var canUndo: Bool
    var onUndo: () -> Void
    
    // Enhanced quick add items with smarter defaults
    let quickAddItems: [(name: String, emoji: String)] = [
        ("Milk", "🥛"),
        ("Eggs", "🥚"),
        ("Bread", "🍞"),
        ("Bananas", "🍌"),
        ("Chicken", "🍗")
    ]
    
    @State private var isShowingWeeklyEssentials = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Undo button with animation
                if canUndo {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            onUndo()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 14))
                            Text("Undo")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(AppTheme.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(AppTheme.secondaryLight.opacity(0.2))
                        )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Weekly essentials button
                Button {
                    isShowingWeeklyEssentials = true
                } label: {
                    HStack(spacing: 6) {
                        Text("Weekly Essentials")
                            .font(.system(size: 15))
                        
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(AppTheme.primaryLight.opacity(0.2))
                    )
                }
                .actionSheet(isPresented: $isShowingWeeklyEssentials) {
                    ActionSheet(
                        title: Text("Add Weekly Essentials"),
                        message: Text("Add all your regular weekly items with one tap"),
                        buttons: [
                            .default(Text("🥛 Milk")) { addQuickItem(name: "Milk") },
                            .default(Text("🥚 Eggs")) { addQuickItem(name: "Eggs") },
                            .default(Text("🍞 Bread")) { addQuickItem(name: "Bread") },
                            .default(Text("🍌 Bananas")) { addQuickItem(name: "Bananas") },
                            .default(Text("Add All")) { addAllWeeklyEssentials() },
                            .cancel()
                        ]
                    )
                }
                
                // Individual quick add items
                ForEach(quickAddItems, id: \.name) { item in
                    Button {
                        addQuickItem(name: item.name)
                    } label: {
                        HStack(spacing: 6) {
                            Text("\(item.emoji) \(item.name)")
                                .font(.system(size: 15))
                            
                            Image(systemName: "plus")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(AppTheme.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppTheme.primaryLight.opacity(0.2))
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    private func addQuickItem(name: String) {
        // Get smart defaults based on item name
        let (defaultAmount, defaultUnit) = getSmartDefaults(for: name)
        
        let item = Ingredient(
            id: UUID(),
            name: name,
            amount: defaultAmount,
            unit: defaultUnit,
            category: determineCategory(from: name),
            isPerishable: isPerishable(name)
        )
        
        withAnimation {
            viewModel.addItem(item)
        }
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func addAllWeeklyEssentials() {
        // Add all standard weekly items
        let weeklyItems = [
            ("Milk", 1.0, IngredientUnit.liters),
            ("Eggs", 12.0, IngredientUnit.pieces),
            ("Bread", 1.0, IngredientUnit.pieces),
            ("Bananas", 6.0, IngredientUnit.pieces),
            ("Coffee", 1.0, IngredientUnit.pieces)
        ]
        
        for (name, amount, unit) in weeklyItems {
            let item = Ingredient(
                id: UUID(),
                name: name,
                amount: amount,
                unit: unit,
                category: determineCategory(from: name),
                isPerishable: isPerishable(name)
            )
            
            viewModel.addItem(item)
        }
        
        // Add haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // Helper function to get smart defaults
    private func getSmartDefaults(for itemName: String) -> (amount: Double, unit: IngredientUnit) {
        let lowercasedName = itemName.lowercased()
        
        switch lowercasedName {
        case "milk":
            return (1, .liters)
        case "eggs":
            return (12, .pieces)
        case "bread":
            return (1, .pieces)
        case "bananas":
            return (6, .pieces)
        case "chicken":
            return (1, .pounds)
        case "apples":
            return (6, .pieces)
        case "tomatoes":
            return (6, .pieces)
        case "onions":
            return (3, .pieces)
        case "potatoes":
            return (1, .kilograms)
        case "rice":
            return (1, .kilograms)
        case "flour":
            return (1, .kilograms)
        case "sugar":
            return (1, .kilograms)
        default:
            return (1, .pieces)
        }
    }
    
    // Helper function to determine if an item is perishable
    private func isPerishable(_ name: String) -> Bool {
        let lowercasedName = name.lowercased()
        
        // Most dairy, produce, and meat are perishable
        if ["milk", "cheese", "yogurt", "cream", "butter"].contains(where: lowercasedName.contains) {
            return true
        }
        
        if ["apple", "banana", "orange", "lettuce", "tomato", "carrot", "onion", "pepper"].contains(where: lowercasedName.contains) {
            return true
        }
        
        if ["chicken", "beef", "pork", "fish", "salmon", "shrimp", "meat"].contains(where: lowercasedName.contains) {
            return true
        }
        
        return false
    }
    
    // Helper function to determine category from name
    private func determineCategory(from name: String) -> IngredientCategory {
        let lowercasedName = name.lowercased()
        
        // Dairy
        if ["milk", "cheese", "yogurt", "cream", "butter"].contains(where: lowercasedName.contains) {
            return .dairy
        }
        
        // Produce
        if ["apple", "banana", "orange", "lettuce", "tomato", "carrot", "onion", "pepper", "vegetable", "fruit"].contains(where: lowercasedName.contains) {
            return .produce
        }
        
        // Meat
        if ["chicken", "beef", "pork", "fish", "salmon", "shrimp", "meat"].contains(where: lowercasedName.contains) {
            return .meat
        }
        
        // Pantry
        if ["rice", "pasta", "flour", "sugar", "oil", "spice", "can", "sauce"].contains(where: lowercasedName.contains) {
            return .pantry
        }
        
        // Frozen
        if ["frozen", "ice cream", "pizza"].contains(where: lowercasedName.contains) {
            return .frozen
        }
        
        // Other for bakery items
        if ["bread", "muffin", "cake", "pastry", "cookie"].contains(where: lowercasedName.contains) {
            return .other
        }
        
        return .other
    }
} 