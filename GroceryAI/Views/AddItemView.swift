import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: ShoppingListViewModel
    @FocusState private var isItemNameFocused: Bool
    
    // Main item properties
    @State private var itemName = ""
    @State private var selectedCategory: IngredientCategory = .other
    @State private var amount: Double = 1.0
    @State private var unit: IngredientUnit = .pieces
    @State private var notes = ""
    
    // UI State
    @State private var showAdvancedOptions = false
    @State private var showingSuccessMessage = false
    @State private var successMessage = ""
    @State private var suggestedItems: [ShoppingListViewModel.SuggestedItem] = []
    
    // Commonly used items with nice visual icons
    let commonItems: [(name: String, icon: String)] = [
        ("Milk", "🥛"), ("Eggs", "🥚"), ("Bread", "🍞"),
        ("Bananas", "🍌"), ("Apples", "🍎"), ("Cheese", "🧀")
    ]
    
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
                // Background
                Color.dynamicBackground(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Main content
                ScrollView {
                        VStack(spacing: 24) {
                            // Large, focused input field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("What do you need?")
                                    .font(.headline)
                                    .foregroundColor(Color.dynamicText(for: colorScheme))
                                    .padding(.horizontal, 4)
                                
                                HStack {
                                    TextField("Type an item...", text: $itemName)
                                        .focused($isItemNameFocused)
                                        .font(.system(size: 20))
                            .onChange(of: itemName) { oldValue, newValue in
                                            if newValue.count >= 2 {
                                                // Update suggestions and defaults as user types
                                updateUnitBasedOnItem()
                                                suggestedItems = viewModel.searchForItems(matching: newValue)
                                            } else {
                                                suggestedItems = []
                                            }
                                        }
                                        .submitLabel(.done)
                                        .onSubmit {
                                            if !itemName.isEmpty {
                                                quickAddWithDefaults()
                                            }
                                        }
                                    
                                    if !itemName.isEmpty {
                                    Button(action: {
                                            itemName = ""
                                            suggestedItems = []
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.dynamicCardBackground(for: colorScheme))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            .padding(.top, 8)
                            
                            // Auto-suggestion results - appear as user types
                            if !suggestedItems.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(suggestedItems) { suggestion in
                                        Button(action: {
                                            // Apply the suggested item's properties
                                            itemName = suggestion.name
                                            selectedCategory = suggestion.category
                                            unit = suggestion.unit
                                            amount = suggestion.amount
                                            // Clear suggestions after selection
                                            suggestedItems = []
                                        }) {
                                            HStack {
                                                Text(suggestion.name)
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color.dynamicText(for: colorScheme))
                                                
                                                Spacer()
                                                
                                                Text(suggestion.displayQuantity)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(Color.dynamicSecondaryText(for: colorScheme))
                                                
                                                if suggestion.source == .recent {
                                                    Image(systemName: "clock")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(Color.dynamicSecondaryText(for: colorScheme))
                                                        .padding(.leading, 4)
                                                }
                                            }
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)
                                            .background(Color.dynamicCardBackground(for: colorScheme))
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        if suggestion.id != suggestedItems.last?.id {
                                            Divider()
                                                .padding(.horizontal, 16)
                                                .opacity(0.5)
                                        }
                                    }
                                }
                                .background(Color.dynamicCardBackground(for: colorScheme))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                                .padding(.top, 2)
                                .padding(.bottom, 12)
                                .transition(.opacity)
                            }
                            
                            // Quick add tiles with icons
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Quick Add")
                                    .font(.headline)
                                    .foregroundColor(Color.dynamicText(for: colorScheme))
                                    .padding(.horizontal, 4)
                                
                                // Visual grid of common items
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ForEach(commonItems, id: \.name) { item in
                                        Button(action: {
                                            itemName = item.name
                                            selectedCategory = determineCategory(from: item.name)
                                            unit = suggestUnitForItem(item.name)
                                            amount = suggestAmountForItem(item.name)
                                            quickAddWithDefaults()
                                        }) {
                                            VStack(spacing: 6) {
                                                Text(item.icon)
                                                    .font(.system(size: 30))
                                                
                                                Text(item.name)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(Color.dynamicText(for: colorScheme))
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.dynamicCardBackground(for: colorScheme))
                                            .cornerRadius(12)
                                        }
                                        .buttonStyle(ScaleButtonStyle())
                                    }
                                }
                            }
                            
                            // Recent items - horizontally scrolling
                            if !viewModel.recentItems.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recent Items")
                                        .font(.headline)
                                        .foregroundColor(Color.dynamicText(for: colorScheme))
                                        .padding(.horizontal, 4)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(viewModel.recentItems, id: \.id) { item in
                                                Button(action: {
                                                    // Directly add the recent item
                                                    addRecentItem(item)
                                                }) {
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(item.name)
                                                            .font(.system(size: 16, weight: .medium))
                                                            .lineLimit(1)
                                                        
                                                        Text("\(formatAmount(item.amount)) \(item.unit.rawValue)")
                                                            .font(.system(size: 13))
                                                            .foregroundColor(Color.dynamicSecondaryText(for: colorScheme))
                                                    }
                                                    .frame(minWidth: 100)
                                                    .padding()
                                                    .background(Color.dynamicCardBackground(for: colorScheme))
                                                    .cornerRadius(10)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                }
                            }
                            
                            // Advanced options - initially hidden
                            if showAdvancedOptions {
                                VStack(alignment: .leading, spacing: 20) {
                                    // Category selector
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Category")
                                            .font(.headline)
                                            .foregroundColor(Color.dynamicText(for: colorScheme))
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 10) {
                                                ForEach(IngredientCategory.allCases, id: \.self) { category in
                                                    Button(action: {
                                                        selectedCategory = category
                                                    }) {
                                                        Text(category.rawValue.capitalized)
                                                            .padding(.horizontal, 16)
                                                            .padding(.vertical, 8)
                                                            .background(
                                                                selectedCategory == category ? 
                                                                AppTheme.primary : 
                                                                Color.dynamicCardBackground(for: colorScheme)
                                                            )
                                                            .foregroundColor(
                                                                selectedCategory == category ? 
                                                                .white : 
                                                                Color.dynamicText(for: colorScheme)
                                                            )
                                                            .cornerRadius(20)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                    }
                                    
                                    // Quantity control
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Quantity")
                                            .font(.headline)
                                            .foregroundColor(Color.dynamicText(for: colorScheme))
                                        
                                        HStack(spacing: 16) {
                                            // Unit selection
                                            Menu {
                                                ForEach(IngredientUnit.allCases, id: \.self) { unitOption in
                                                    Button(action: {
                                                        unit = unitOption
                                                    }) {
                                                        Text(unitOption.rawValue.capitalized)
                                                    }
                                                }
                                            } label: {
                                                HStack {
                                                    Text(unit.rawValue.capitalized)
                                                        .foregroundColor(Color.dynamicText(for: colorScheme))
                                                    
                                                    Image(systemName: "chevron.down")
                                                        .font(.system(size: 13))
                                                        .foregroundColor(Color.dynamicSecondaryText(for: colorScheme))
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(Color.dynamicCardBackground(for: colorScheme))
                                                .cornerRadius(10)
                                            }
                                            
                                            // Amount control
                                            HStack(spacing: 0) {
                                                Button(action: { decreaseAmount() }) {
                                                    Image(systemName: "minus.circle.fill")
                                                        .font(.system(size: 24))
                                                        .foregroundColor(AppTheme.primary.opacity(0.8))
                                                }
                                                .padding(.leading, 16)
                                                
                                                Text(formatAmount(amount))
                                                    .font(.system(size: 18, weight: .medium))
                                                    .frame(minWidth: 60)
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(Color.dynamicText(for: colorScheme))
                                                
                                                Button(action: { increaseAmount() }) {
                                                    Image(systemName: "plus.circle.fill")
                                                        .font(.system(size: 24))
                                                        .foregroundColor(AppTheme.primary)
                                                }
                                                .padding(.trailing, 16)
                                            }
                                            .padding(.vertical, 8)
                                            .background(Color.dynamicCardBackground(for: colorScheme))
                                            .cornerRadius(10)
                                        }
                                    }
                                    
                                    // Notes field
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Notes")
                                            .font(.headline)
                                            .foregroundColor(Color.dynamicText(for: colorScheme))
                                        
                                        TextField("Optional details...", text: $notes)
                                            .padding()
                                            .background(Color.dynamicCardBackground(for: colorScheme))
                                            .cornerRadius(10)
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    
                    // Bottom action area
                    VStack(spacing: 12) {
                        // Show/hide advanced options button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showAdvancedOptions.toggle()
                            }
                        }) {
                            HStack {
                                Text(showAdvancedOptions ? "Hide Options" : "Show Options")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Image(systemName: showAdvancedOptions ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(AppTheme.primary)
                            .padding(.vertical, 8)
                        }
                        
                        // Main action button
                        Button(action: {
                            if !itemName.isEmpty {
                                addItem()
                            } else {
                                // Prompt user to enter an item name
                                isItemNameFocused = true
                            }
                        }) {
                            Text(!itemName.isEmpty ? "Add \(itemName)" : "Add to Shopping List")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    !itemName.isEmpty ?
                                    AppTheme.primaryGradient :
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.5)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        .disabled(itemName.isEmpty)
                    }
                    .padding()
                    .background(Color.dynamicBackground(for: colorScheme).opacity(0.95))
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.gray.opacity(0.2)),
                        alignment: .top
                    )
                }
                
                // Success message overlay
                if showingSuccessMessage {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                            
                            Text(successMessage)
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(AppTheme.primary)
                        .cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.bottom, 90)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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
            .onAppear {
                // Auto-focus the text field
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isItemNameFocused = true
                }
            }
        }
    }
    
    // MARK: - Actions
    
    // Add item with full details
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
        showSuccessMessage("\(itemName) added")
        
        // Reset for next item
        resetForm(keepFocus: true)
    }
    
    // Quick add with defaults - used by buttons and quick actions
    private func quickAddWithDefaults() {
        guard !itemName.isEmpty else { return }
        
        let newItem = Ingredient(
            name: itemName,
            amount: amount,
            unit: unit,
            category: selectedCategory,
            isPerishable: isPerishable(itemName)
        )
        
        viewModel.addItem(newItem)
        showSuccessMessage("\(itemName) added")
        
        // Reset for next item
        resetForm(keepFocus: false)
    }
    
    // Add recent item directly
    private func addRecentItem(_ item: Ingredient) {
        viewModel.addItem(item)
        showSuccessMessage("\(item.name) added")
    }
    
    // Reset form after adding item
    private func resetForm(keepFocus: Bool) {
        itemName = ""
        notes = ""
        if !keepFocus {
            isItemNameFocused = false
        }
        suggestedItems = []
    }
    
    // Show temporary success message
    private func showSuccessMessage(_ message: String) {
        successMessage = message
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showingSuccessMessage = true
        }
        
        // Hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                showingSuccessMessage = false
            }
        }
    }
    
    // MARK: - Helper Functions
    
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
    
    // Unit suggestion
    private func suggestUnitForItem(_ item: String) -> IngredientUnit {
        let lowerItem = item.lowercased()
        
        if ["milk", "water", "juice", "oil"].contains(where: { lowerItem.contains($0) }) {
            return .liters
        } else if ["sugar", "flour", "rice", "salt"].contains(where: { lowerItem.contains($0) }) {
            return .grams
        } else {
            return .pieces
        }
    }
    
    // Amount suggestion
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
    
    // Amount adjustments
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
        selectedCategory = determineCategory(from: itemName)
        unit = suggestUnitForItem(itemName)
        amount = suggestAmountForItem(itemName)
    }
}
