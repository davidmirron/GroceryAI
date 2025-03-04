import SwiftUI
import UIKit // Add this for UIActivityViewController

struct ShoppingListView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var searchText = ""
    @State private var showingAddItem = false
    @State private var editMode: EditMode = .inactive
    @State private var selectedItems = Set<UUID>()
    
    // Quick add items
    let quickAddItems = ["Milk", "Eggs", "Bread", "Bananas"]
    
    // Add a state variable to track the currently selected category
    @State private var selectedCategory: IngredientCategory? = nil
    
    // Default initializer that creates its own ViewModel (for previews and standalone use)
    init() {
        self.viewModel = ShoppingListViewModel()
    }
    
    // Initializer that accepts a shared ViewModel
    init(viewModel: ShoppingListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGreen
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Quick add buttons
                    if editMode == .inactive {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Show undo button if there's a deleted item
                                if viewModel.canUndo() {
                                    Button {
                                        withAnimation {
                                            viewModel.undoDelete()
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
                                        .padding(.vertical, 6)
                                        .background(AppTheme.secondaryLight.opacity(0.2))
                                        .clipShape(Capsule())
                                    }
                                    .transition(.scale.combined(with: .opacity))
                                }
                                
                                ForEach(quickAddItems, id: \.self) { itemName in
                                    Button {
                                        addQuickItem(name: itemName)
                                    } label: {
                                        HStack(spacing: 6) {
                                            Text(itemName)
                                                .font(.system(size: 16))
                                                .foregroundColor(AppTheme.primary)
                                            
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(AppTheme.primary)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(AppTheme.primaryLight.opacity(0.2))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        }
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
                
                // Add button (only show when not in edit mode)
                if editMode == .inactive {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                showingAddItem = true
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primary)
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
            }
            .navigationTitle("GroceryAI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("GroceryAI")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if editMode == .active {
                            Button(role: .destructive) {
                                // Delete selected items
                                viewModel.deleteItems(withIds: selectedItems)
                                selectedItems.removeAll()
                                editMode = .inactive
                            } label: {
                                Label("Delete Selected", systemImage: "trash")
                            }
                        }
                        
                        Button {
                            // Clear completed items
                            viewModel.clearCompletedItems()
                        } label: {
                            Label("Clear Completed", systemImage: "trash")
                        }
                        
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
            .environment(\.editMode, $editMode)
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
                // Category header with count
                HStack {
                    Button(action: {
                        withAnimation {
                            selectedCategory = category
                        }
                    }) {
                        HStack {
                            Text(title)
                                .font(.headline)
                                .foregroundColor(isSelected ? .white : AppTheme.text)
                            
                            Text("(\(items.count))")
                                .font(.subheadline)
                                .foregroundColor(isSelected ? .white.opacity(0.8) : AppTheme.textSecondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            isSelected ? 
                                AppTheme.primary : 
                                AppTheme.cardBackground.opacity(0.8)
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Show completed count if any items are checked
                    let completedCount = items.filter { viewModel.isSelected($0) }.count
                    if completedCount > 0 {
                        Text("\(completedCount) completed")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.cardBackground.opacity(0.8))
                            .cornerRadius(4)
                    }
                }
                .padding(.top, 8)
                
                // Items list
                ForEach(items) { item in
                    GroceryItemRow(
                        item: item,
                        isSelected: viewModel.isSelected(item),
                        isFavorite: viewModel.isFavorite(item),
                        isEditing: editMode == .active,
                        isItemSelected: selectedItems.contains(item.id),
                        onToggle: {
                            if editMode == .active {
                                if selectedItems.contains(item.id) {
                                    selectedItems.remove(item.id)
                                } else {
                                    selectedItems.insert(item.id)
                                }
                            } else {
                                viewModel.toggleItem(item)
                            }
                        },
                        onDelete: { viewModel.deleteItem(item) },
                        onFavorite: { viewModel.toggleFavorite(item) },
                        onIncreaseQuantity: { viewModel.increaseQuantity(item) },
                        onDecreaseQuantity: { viewModel.decreaseQuantity(item) }
                    )
                    .environmentObject(viewModel)
                    .transition(.opacity.combined(with: .slide))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.deleteItem(item)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            viewModel.toggleFavorite(item)
                        } label: {
                            Label(viewModel.isFavorite(item) ? "Unfavorite" : "Favorite", 
                                  systemImage: viewModel.isFavorite(item) ? "star.slash" : "star")
                        }
                        .tint(.yellow)
                    }
                }
                .onMove { from, to in
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
        // Get smart defaults based on item name
        let (defaultAmount, defaultUnit) = getSmartDefaults(for: name)
        
        let item = Ingredient(
            id: UUID(),
            name: name,
            amount: defaultAmount,
            unit: defaultUnit,
            category: determineCategory(from: name),
            isPerishable: isPerishable(name),
            typicalShelfLife: 7
        )
        viewModel.addItem(item)
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
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

// Helper to erase type
extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
} 
