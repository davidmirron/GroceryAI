import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ShoppingListViewModel
    
    @State private var itemName = ""
    @State private var selectedCategory: IngredientCategory = .other
    @State private var amount: Double = 1.0
    @State private var unit: Ingredient.Unit = .grams
    @State private var notes = ""
    
    // Quick add items
    let quickAddItems = ["Milk", "Eggs", "Bread", "Bananas", "Apples"]
    
    // Simplified formatter
    private let quantityFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    // Simple initializer
    init(viewModel: ShoppingListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Item name field
                        TextField("Item name", text: $itemName)
                            .onChange(of: itemName) { _ in
                                updateUnitBasedOnItem()
                            }
                            .modifier(DarkModeTextFieldModifier())
                            .padding(.top)
                        
                        // Quick add buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(quickAddItems, id: \.self) { item in
                                    Button(action: {
                                        itemName = item
                                        selectedCategory = determineCategory(from: item)
                                        // Use Ingredient.Unit directly
                                        unit = suggestUnitForItem(item)
                                        amount = suggestAmountForItem(item)
                                    }) {
                                        Text(item)
                                            .foregroundColor(AppTheme.textOnDark)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(AppTheme.quickAddButtonBackground)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        
                        // Category picker
                        VStack(alignment: .leading) {
                            Text("Category")
                                .font(AppTheme.headlineFont)
                                .foregroundColor(AppTheme.text)
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(IngredientCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category)
                                }
                            }
                            .onChange(of: selectedCategory) { _ in
                                updateUnitBasedOnItem()
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.vertical, 8)
                        }
                        
                        // Unit picker - simplified to use Ingredient.Unit directly
                        Picker("Unit", selection: $unit) {
                            Text("grams").tag(Ingredient.Unit.grams)
                            Text("pieces").tag(Ingredient.Unit.pieces)
                            Text("liters").tag(Ingredient.Unit.liters)
                            Text("cups").tag(Ingredient.Unit.cups)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // Amount and unit - simplified controls
                        HStack {
                            Button(action: { decreaseAmount() }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(AppTheme.primary)
                                    .font(.system(size: 24))
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Text(formatAmount(amount))
                                .font(AppTheme.bodyFont)
                                .foregroundColor(AppTheme.text)
                                .frame(width: 80)
                                .multilineTextAlignment(.center)
                            
                            Button(action: { increaseAmount() }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(AppTheme.primary)
                                    .font(.system(size: 24))
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .quantityControlStyle()
                        
                        // Notes
                        VStack(alignment: .leading) {
                            Text("Notes (Optional)")
                                .font(AppTheme.headlineFont)
                                .foregroundColor(AppTheme.text)
                            
                            TextField("Notes", text: $notes)
                                .modifier(DarkModeTextFieldModifier())
                        }
                        
                        // Recently Added section - simplified
                        if !viewModel.items.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Recently Added")
                                    .font(AppTheme.headlineFont)
                                    .foregroundColor(AppTheme.text)
                                    .padding(.bottom, 8)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                    ForEach(viewModel.items.prefix(5)) { item in
                                        Button(action: {
                                            itemName = item.name
                                            selectedCategory = item.category
                                            unit = item.unit  // Now directly compatible
                                            amount = item.amount
                                        }) {
                                            VStack(spacing: 4) {
                                                Text(item.name)
                                                    .font(AppTheme.bodyFont)
                                                    .foregroundColor(AppTheme.text)
                                                
                                                Text(item.category.rawValue)
                                                    .font(AppTheme.captionFont)
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 8)
                                            .background(AppTheme.recentItemBackground)
                                            .cornerRadius(AppTheme.cornerRadiusMedium)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Add to List button
                        Button(action: addItem) {
                            Text("Add to List")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.primaryGradient)
                                .cornerRadius(14)
                                .shadow(radius: 4)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addItem() {
        guard !itemName.isEmpty else { return }
        
        let newItem = Ingredient(
            name: itemName,
            amount: amount,
            unit: unit,
            category: selectedCategory,
            isPerishable: isPerishable(itemName),
            typicalShelfLife: 7,
            notes: notes.isEmpty ? nil : notes
        )
        
        viewModel.addItem(newItem)
        dismiss()
    }
    
    // Helper functions
    private func isPerishable(_ itemName: String) -> Bool {
        let perishableItems = ["milk", "eggs", "cheese", "meat", "fish", "yogurt", 
                              "berries", "lettuce", "spinach", "tomato"]
        return perishableItems.contains { itemName.lowercased().contains($0) }
    }
    
    private func determineCategory(from name: String) -> IngredientCategory {
        let lowercasedName = name.lowercased()
        
        if ["milk", "yogurt", "cheese", "butter", "cream"].contains(where: { lowercasedName.contains($0) }) {
            return .dairy
        } else if ["apple", "banana", "orange", "lettuce", "tomato", "cucumber", "carrot"].contains(where: { lowercasedName.contains($0) }) {
            return .produce
        } else if ["chicken", "beef", "pork", "fish", "salmon", "shrimp"].contains(where: { lowercasedName.contains($0) }) {
            return .meat
        } else if ["rice", "pasta", "flour", "sugar", "oil", "spice"].contains(where: { lowercasedName.contains($0) }) {
            return .pantry
        } else if ["ice", "frozen", "pizza"].contains(where: { lowercasedName.contains($0) }) {
            return .frozen
        }
        
        return .other
    }
    
    // Simplified amount formatting
    private func formatAmount(_ value: Double) -> String {
        if value == floor(value) {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    // Simplified unit suggestion
    private func suggestUnitForItem(_ item: String) -> Ingredient.Unit {
        let lowerItem = item.lowercased()
        
        if ["milk", "water", "juice", "oil"].contains(where: { lowerItem.contains($0) }) {
            return .liters
        } else if ["sugar", "flour", "rice", "salt"].contains(where: { lowerItem.contains($0) }) {
            return .grams
        } else {
            return .pieces
        }
    }
    
    // Simplified amount suggestion
    private func suggestAmountForItem(_ item: String) -> Double {
        let lowerItem = item.lowercased()
        
        if ["milk", "juice"].contains(where: { lowerItem.contains($0) }) {
            return 1.0  // 1 liter
        } else if ["sugar", "flour", "rice"].contains(where: { lowerItem.contains($0) }) {
            return 500.0  // 500 grams
        } else {
            return 1.0  // 1 piece
        }
    }
    
    // Simplified increment/decrement
    private func increaseAmount() {
        switch unit {
        case .grams:
            if amount < 10 {
                amount += 1
            } else if amount < 100 {
                amount += 10
            } else {
                amount += 50
            }
        case .liters:
            if amount < 1 {
                amount += 0.1
            } else {
                amount += 0.5
            }
        default:
            amount += 1
        }
    }
    
    private func decreaseAmount() {
        switch unit {
        case .grams:
            if amount > 100 {
                amount -= 50
            } else if amount > 10 {
                amount -= 10
            } else if amount > 1 {
                amount -= 1
            }
        case .liters:
            if amount > 1 {
                amount -= 0.5
            } else if amount > 0.1 {
                amount -= 0.1
            }
        default:
            if amount > 1 {
                amount -= 1
            }
        }
    }
    
    // Update unit based on item name and category
    private func updateUnitBasedOnItem() {
        unit = suggestUnitForItem(itemName)
    }
}
