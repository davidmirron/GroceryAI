import SwiftUI
import UIKit // Add this for UIActivityViewController

struct ShoppingListView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    @State private var searchText = ""
    @State private var showingAddItem = false
    
    // Quick add items
    let quickAddItems = ["Milk", "Eggs", "Bread", "Bananas"]
    
    // Add a state variable to track the currently selected category
    @State private var selectedCategory: IngredientCategory? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGreen
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Quick add buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(quickAddItems, id: \.self) { itemName in
                                Button {
                                    addQuickItem(name: itemName)
                                } label: {
                                    Text(itemName)
                                        .font(.system(size: 16))
                                        .foregroundColor(AppTheme.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(AppTheme.primaryLight)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(AppTheme.primary.opacity(0.2), lineWidth: 1)
                                        )
                                }
                            }
                            
                            NavigationLink(destination: RecipesView(ingredients: viewModel.items)) {
                                Text("What can I make?")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.secondaryLight)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(AppTheme.secondary.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                    
                    // Category-based list with drag to reorder
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            // Show favorites section if there are any
                            if !viewModel.favorites.isEmpty {
                                grocerySection(title: "Favorites", items: viewModel.favorites)
                            }
                            
                            grocerySection(title: "Dairy", items: viewModel.sortedItems(for: .dairy))
                            grocerySection(title: "Produce", items: viewModel.sortedItems(for: .produce))
                            grocerySection(title: "Pantry", items: viewModel.sortedItems(for: .pantry))
                            grocerySection(title: "Meat & Seafood", items: viewModel.sortedItems(for: .meat))
                            grocerySection(title: "Frozen", items: viewModel.sortedItems(for: .frozen))
                            grocerySection(title: "Other", items: viewModel.sortedItems(for: .other))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100) // Extra padding for tab bar
                    }
                    .refreshable {
                        // Simulate refreshing data - add a slight delay to make feedback more noticeable
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        
                        // Add haptic feedback for refresh
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        // Load fresh data
                        viewModel.loadItems()
                    }
                }
                
                // Add button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingAddItem = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 5, x: 0, y: 3)
                                
                                Text("+")
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationTitle("GroceryAI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("GroceryAI")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            // Refresh action
                            viewModel.loadItems()
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        
                    Button {
                            shareList()
                        } label: {
                            Label("Share List", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(
                LinearGradient(
                    gradient: Gradient(colors: [AppTheme.primaryDark, AppTheme.primary]),
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingAddItem) {
                AddItemView(viewModel: viewModel)
            }
        }
    }
    
    private func grocerySection(title: String, items: [Ingredient]) -> some View {
        // Only display sections with items
        if items.isEmpty {
            return AnyView(EmptyView())
        }
        
        // Determine if this section is currently selected
        let category = categoryFromTitle(title)
        let isSelected = selectedCategory == category
        
        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                // Make the header button tappable to select the category
                Button(action: {
                    withAnimation {
                        selectedCategory = category
                    }
                }) {
                    Text(title)
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .foregroundColor(isSelected ? .white : AppTheme.text)
                        .background(isSelected ? AppTheme.primary : Color.clear)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.clear : AppTheme.borderColor, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Wrap ForEach in a drag-and-drop context
                ForEach(items) { item in
                    // Item row with binding
                    GroceryItemRow(
                        item: item,
                        isSelected: viewModel.isSelected(item),
                        isFavorite: viewModel.isFavorite(item),
                        onToggle: {
                            viewModel.toggleItem(item)
                        },
                        onDelete: { viewModel.deleteItem(item) },
                        onFavorite: { viewModel.toggleFavorite(item) },
                        onIncreaseQuantity: { viewModel.increaseQuantity(item) },
                        onDecreaseQuantity: { viewModel.decreaseQuantity(item) }
                    )
                    .environmentObject(viewModel)
                    .onDrag {
                        // Return a drag item with the ID as a string
                        return NSItemProvider(object: item.id.uuidString as NSString)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            viewModel.toggleFavorite(item)
                        } label: {
                            Label(
                                viewModel.isFavorite(item) ? "Remove Favorite" : "Favorite",
                                systemImage: viewModel.isFavorite(item) ? "star.slash" : "star.fill"
                            )
                        }
                        .tint(.yellow)
                    }
                }
                .onMove { from, to in
                    // Handle the reordering
                    viewModel.moveItems(in: category, from: from, to: to)
                }
            }
        )
    }
    
    // Helper function to convert title string to category
    private func categoryFromTitle(_ title: String) -> IngredientCategory {
        switch title {
        case "Dairy": return .dairy
        case "Produce": return .produce
        case "Pantry": return .pantry
        case "Meat & Seafood": return .meat
        case "Frozen": return .frozen
        case "Other": return .other
        case "Favorites": return .dairy // Just a placeholder, not a real category
        default: return .other
        }
    }
    
    private func addQuickItem(name: String) {
        // Using grams as the measurement unit
        let item = Ingredient(
            id: UUID(),
            name: name,
            amount: 1,
            unit: .grams,
            category: determineCategory(from: name),
            isPerishable: isPerishable(name),
            typicalShelfLife: 7
        )
        viewModel.addItem(item)
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
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
        
        // Changed from .grains to .other for bakery items
        if ["bread", "muffin", "cake", "pastry", "cookie"].contains(where: lowercasedName.contains) {
            return .other  // Using .other instead of .grains which doesn't exist
        }
        
        return .other
    }
    
    // Add this method to share the grocery list
    private func shareList() {
        // Create a text representation of the grocery list
        var listText = "My GroceryAI Shopping List:\n\n"
        
        // Add items by category
        let categories: [(String, IngredientCategory)] = [
            ("Dairy", .dairy),
            ("Produce", .produce),
            ("Pantry", .pantry),
            ("Meat & Seafood", .meat),
            ("Frozen", .frozen),
            ("Other", .other)
        ]
        
        for (title, category) in categories {
            let items = viewModel.itemsByCategory(category)
            if !items.isEmpty {
                listText += "--- \(title) ---\n"
                for item in items {
                    listText += "• \(item.name)\n"
                }
                listText += "\n"
            }
        }
        
        // Create and present activity view controller for sharing
        let activityVC = UIActivityViewController(
            activityItems: [listText],
            applicationActivities: nil
        )
        
        // Present the activity view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

// Replace the existing GroceryItemRow implementation (around line 489) with this improved version
struct GroceryItemRow: View {
    let item: Ingredient
    let isSelected: Bool
    let isFavorite: Bool
    
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
                        .stroke(isSelected ? AppTheme.primary : AppTheme.borderColor, lineWidth: 2)
                        .frame(width: 26, height: 26)
                        .background(
                            isSelected ? AppTheme.primary : Color.clear,
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
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
                        .strikethrough(isSelected)
                        .opacity(isSelected ? 0.5 : 1)
                    
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
                    
                    // Make quantity text tappable to edit
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

// Helper to erase type
extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
} 
