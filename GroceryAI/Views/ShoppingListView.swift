import SwiftUI
import UIKit // Add this for UIActivityViewController

struct ShoppingListView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    @ObservedObject var recipesViewModel: RecipesViewModel
    @State private var searchText = ""
    @State private var showingAddItem = false
    @State private var editMode: EditMode = .inactive
    @State private var selectedItems = Set<UUID>()
    @State private var showingRecipeDetail = false
    @State private var selectedRecipe: Recipe?
    @Environment(\.colorScheme) private var colorScheme
    
    // Add state for recipe matches to avoid computing during view updates
    @State private var recipeMatches: [Recipe] = []
    
    // Quick add items
    let quickAddItems = ["Milk", "Eggs", "Bread", "Bananas"]
    
    // Add a state variable to track the currently selected category
    @State private var selectedCategory: IngredientCategory? = nil
    
    // Default initializer that creates its own ViewModels (for previews and standalone use)
    init() {
        let shoppingListVM = ShoppingListViewModel()
        let recipesVM = RecipesViewModel(shoppingListViewModel: shoppingListVM)
        self.viewModel = shoppingListVM
        self.recipesViewModel = recipesVM
    }
    
    // Initializer that accepts a shared ShoppingListViewModel
    init(viewModel: ShoppingListViewModel) {
        self.viewModel = viewModel
        self.recipesViewModel = RecipesViewModel(shoppingListViewModel: viewModel)
    }
    
    // Initializer that accepts both view models
    init(viewModel: ShoppingListViewModel, recipesViewModel: RecipesViewModel) {
        self.viewModel = viewModel
        self.recipesViewModel = recipesViewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Soften the background color in light mode for better contrast
                AppTheme.backgroundGreen.opacity(colorScheme == .dark ? 1.0 : 0.7)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Quick add buttons
                    if editMode == .inactive {
                        QuickAddRow(
                            viewModel: viewModel,
                            canUndo: viewModel.canUndo(),
                            onUndo: {
                                viewModel.undoDelete()
                            }
                        )
                        
                        // Smart Suggestions
                        smartSuggestionsSection
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
                        .padding(.bottom, 100) // Extra padding for tab bar and completion view
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
                
                // Fixed positioning for the meal completion view
                if editMode == .inactive {
                    VStack(spacing: 0) {
                        // Add the meal completion view in its own container
                        // with fixed positioning at the bottom
                        MealCompletionView(
                            viewModel: viewModel,
                            recipesViewModel: recipesViewModel
                        )
                        .padding(.bottom, 100) // Increased space for the floating add button
                    }
                }
                
                // Floating add button
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
                                        .shadow(color: AppTheme.primary.opacity(0.4), radius: 6, x: 0, y: 3)
                                    
                                    Text("+")
                                        .font(.system(size: 30, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 30)
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
            .sheet(isPresented: $showingRecipeDetail) {
                if let recipe = selectedRecipe {
                    NavigationView {
                        RecipeDetailView(
                            recipe: recipe,
                            viewModel: viewModel,
                            recipesViewModel: recipesViewModel
                        )
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .onAppear {
                // Initialize recipe matches ONCE when the view appears
                loadRecipeMatches()
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
                                AppTheme.cardBackground.opacity(colorScheme == .dark ? 0.8 : 1.0)
                        )
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.0 : 0.1), radius: 2, x: 0, y: 1)
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
                            .background(AppTheme.cardBackground.opacity(colorScheme == .dark ? 0.8 : 1.0))
                            .cornerRadius(4)
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.0 : 0.05), radius: 1, x: 0, y: 1)
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
    
    // Load recipe matches safely outside of view updates
    private func loadRecipeMatches() {
        DispatchQueue.main.async {
            self.recipeMatches = recipesViewModel.getBestRecipeMatches(with: viewModel.items)
        }
    }
    
    // Smart suggestions section
    private var smartSuggestionsSection: some View {
        // Use the cached recipe matches instead of computing during view updates
        return Group {
            if !recipeMatches.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recipe Matches")
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(recipeMatches) { recipe in
                                recipeMatchCard(recipe: recipe)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
                .background(
                    AppTheme.cardBackground
                        .opacity(colorScheme == .dark ? 0.5 : 0.95)
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.0 : 0.07), radius: 3, x: 0, y: 2)
                )
                .padding(.bottom, 8)
            }
        }
        .onChange(of: viewModel.items) {
            // When items change, recalculate recipe matches OUTSIDE of view update cycle
            loadRecipeMatches()
        }
    }
    
    // Recipe match card that doesn't modify state during view updates
    private func recipeMatchCard(recipe: Recipe) -> some View {
        // All values are calculated from the recipe parameter without modifying state
        let matchPercentage: Int
        if recipe.matchScore >= 0.999 { // Account for floating point precision
            matchPercentage = 100
        } else {
            matchPercentage = Int(recipe.matchScore * 100)
        }
        
        let missingIngredients = recipe.missingIngredients
        
        return Button {
            selectedRecipe = recipe
            showingRecipeDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(recipe.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.text)
                    
                    Spacer()
                    
                    Text("\(matchPercentage)%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    matchPercentage >= 70 ? Color.green :
                                    matchPercentage >= 40 ? Color.orange : Color.red
                                )
                        )
                }
                
                Text("\(recipe.ingredients.count - missingIngredients.count) of \(recipe.ingredients.count) ingredients")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(12)
            .frame(width: 200)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.1 : 0.15), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(colorScheme == .dark ? 0.1 : 0.2), lineWidth: 0.5)
                    )
            )
        }
        .contextMenu {
            Button {
                addMissingIngredients(from: recipe)
            } label: {
                Label("Add Missing Items", systemImage: "cart.badge.plus")
            }
            
            Button {
                selectedRecipe = recipe
                showingRecipeDetail = true
            } label: {
                Label("View Recipe", systemImage: "doc.text")
            }
        }
    }
    
    // Updated helper method that safely adds missing ingredients
    private func addMissingIngredients(from recipe: Recipe) {
        // Use the pre-calculated missing ingredients rather than calculating during view update
        for ingredient in recipe.missingIngredients {
            viewModel.addItem(ingredient)
        }
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// Helper to erase type
extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
} 
