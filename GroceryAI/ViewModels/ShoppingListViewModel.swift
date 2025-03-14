import Foundation
import SwiftUI

class ShoppingListViewModel: ObservableObject {
    @Published var items: [Ingredient] = []
    @Published var selectedItems: Set<UUID> = []
    @Published var favoriteItems: Set<UUID> = []
    @Published var lastDeletedItem: (Ingredient, Int)? = nil
    
    init() {
        loadItems()
        initializeCustomOrderIfNeeded()
    }
    
    func addItem(_ item: Ingredient) {
        if let index = items.firstIndex(where: { $0.name.lowercased() == item.name.lowercased() }) {
            let existingItem = items[index]
            let updatedItem = Ingredient(
                id: existingItem.id,
                name: existingItem.name,
                amount: existingItem.amount + item.amount,
                unit: existingItem.unit,
                category: existingItem.category
            )
            items[index] = updatedItem
        } else {
            items.append(item)
        }
        saveItems()
    }
    
    func removeItem(at indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
        saveItems()
    }
    
    func toggleItem(_ item: Ingredient) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
        saveSelectedItems()
    }
    
    func isSelected(_ item: Ingredient) -> Bool {
        selectedItems.contains(item.id)
    }
    
    func itemsByCategory(_ category: IngredientCategory) -> [Ingredient] {
        items.filter { $0.category == category }
    }
    
    func deleteItem(_ item: Ingredient) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            // Store the deleted item and its index for potential undo
            lastDeletedItem = (item, index)
            
            items.remove(at: index)
        }
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        }
        if favoriteItems.contains(item.id) {
            favoriteItems.remove(item.id)
        }
        saveItems()
        saveSelectedItems()
        saveFavoriteItems()
    }
    
    func undoDelete() {
        guard let (item, index) = lastDeletedItem else { return }
        
        // Insert the item back at its original position
        if index <= items.count {
            items.insert(item, at: index)
        } else {
            items.append(item)
        }
        
        // Restore favorite status if it was a favorite
        if favoriteItems.contains(item.id) {
            favoriteItems.insert(item.id)
        }
        
        // Clear the last deleted item
        lastDeletedItem = nil
        
        // Save changes
        saveItems()
        saveFavoriteItems()
        
        // Add haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func canUndo() -> Bool {
        lastDeletedItem != nil
    }
    
    func clearCompletedItems() {
        // Get all completed items
        let completedItemIds = selectedItems
        
        // Remove them from the items array
        items.removeAll { completedItemIds.contains($0.id) }
        
        // Clear the selected items set
        selectedItems.removeAll()
        
        // Save changes
        saveItems()
        saveSelectedItems()
        
        // Add haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func toggleFavorite(_ item: Ingredient) {
        if favoriteItems.contains(item.id) {
            favoriteItems.remove(item.id)
        } else {
            favoriteItems.insert(item.id)
        }
        saveFavoriteItems()
        objectWillChange.send()
    }
    
    func isFavorite(_ item: Ingredient) -> Bool {
        favoriteItems.contains(item.id)
    }
    
    var favorites: [Ingredient] {
        items.filter { favoriteItems.contains($0.id) }
    }
    
    func increaseQuantity(_ item: Ingredient, by amount: Double = 1.0) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            let updatedItem = Ingredient(
                id: item.id,
                name: item.name,
                amount: item.amount + amount,
                unit: item.unit,
                category: item.category,
                isPerishable: item.isPerishable,
                typicalShelfLife: item.typicalShelfLife
            )
            items[index] = updatedItem
            saveItems()
        }
    }
    
    func decreaseQuantity(_ item: Ingredient, by amount: Double = 1.0) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            guard item.amount > amount else { return }
            let updatedItem = Ingredient(
                id: item.id,
                name: item.name,
                amount: item.amount - amount,
                unit: item.unit,
                category: item.category,
                isPerishable: item.isPerishable,
                typicalShelfLife: item.typicalShelfLife
            )
            items[index] = updatedItem
            saveItems()
        }
    }
    
    func setQuantity(_ item: Ingredient, to amount: Double) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            // Ensure amount is not less than 0.1
            let newAmount = max(0.1, amount)
            let updatedItem = Ingredient(
                id: item.id,
                name: item.name,
                amount: newAmount,
                unit: item.unit,
                category: item.category,
                isPerishable: item.isPerishable,
                typicalShelfLife: item.typicalShelfLife
            )
            items[index] = updatedItem
            saveItems()
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "groceryItems")
        }
    }
    
    func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "groceryItems"),
           let decoded = try? JSONDecoder().decode([Ingredient].self, from: data) {
            items = decoded
        }
        loadSelectedItems()
        loadFavoriteItems()
    }
    
    private func saveSelectedItems() {
        let selectedIDs = Array(selectedItems.map { $0.uuidString })
        UserDefaults.standard.set(selectedIDs, forKey: "selectedItems")
    }
    
    private func loadSelectedItems() {
        if let selectedIDs = UserDefaults.standard.stringArray(forKey: "selectedItems") {
            selectedItems = Set(selectedIDs.compactMap { UUID(uuidString: $0) })
        }
    }
    
    private func saveFavoriteItems() {
        let favoriteIDs = Array(favoriteItems.map { $0.uuidString })
        UserDefaults.standard.set(favoriteIDs, forKey: "favoriteItems")
    }
    
    private func loadFavoriteItems() {
        if let favoriteIDs = UserDefaults.standard.stringArray(forKey: "favoriteItems") {
            favoriteItems = Set(favoriteIDs.compactMap { UUID(uuidString: $0) })
        }
    }
    
    var recentItems: [Ingredient] {
        Array(items.prefix(5)).reversed()
    }
    
    var orderedItems: [Ingredient] {
        items.sorted {
            ($0.customOrder ?? Int.max) < ($1.customOrder ?? Int.max)
        }
    }
    
    func initializeCustomOrderIfNeeded() {
        var needsUpdate = false
        for (index, item) in items.enumerated() {
            if item.customOrder == nil {
                let updatedItem = Ingredient(
                    id: item.id,
                    name: item.name,
                    amount: item.amount,
                    unit: item.unit,
                    category: item.category,
                    isPerishable: item.isPerishable,
                    typicalShelfLife: item.typicalShelfLife,
                    notes: item.notes,
                    customOrder: index
                )
                if let itemIndex = items.firstIndex(where: { $0.id == item.id }) {
                    items[itemIndex] = updatedItem
                    needsUpdate = true
                }
            }
        }
        if needsUpdate {
            saveItems()
        }
    }
    
    func bindingForItem(_ item: Ingredient) -> Binding<Ingredient> {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            // If not found, return a dummy binding that doesn't modify state
            return Binding<Ingredient>(
                get: { item },
                set: { _ in }
            )
        }
        
        // Create a proper binding to the item in the array
        return Binding<Ingredient>(
            get: { self.items[index] },
            set: { newValue in
                self.items[index] = newValue
                self.saveItems() // Save changes when the value is updated
            }
        )
    }
    
    func moveItems(in category: IngredientCategory, from source: IndexSet, to destination: Int) {
        // Get all items in this category
        var categoryItems = itemsByCategory(category)
        
        // Perform the move operation on the array
        categoryItems.move(fromOffsets: source, toOffset: destination)
        
        // Update the customOrder of all affected items
        for (index, item) in categoryItems.enumerated() {
            let updatedItem = Ingredient(
                id: item.id,
                name: item.name,
                amount: item.amount,
                unit: item.unit,
                category: item.category,
                isPerishable: item.isPerishable,
                typicalShelfLife: item.typicalShelfLife,
                notes: item.notes,
                customOrder: index  // Set new order based on position
            )
            
            // Find and update the item in the full items array
            if let itemIndex = items.firstIndex(where: { $0.id == item.id }) {
                items[itemIndex] = updatedItem
            }
        }
        
        // Save changes
        saveItems()
    }
    
    func sortedItems(for category: IngredientCategory) -> [Ingredient] {
        let categoryItems = itemsByCategory(category)
        return categoryItems.sorted { 
            ($0.customOrder ?? Int.max) < ($1.customOrder ?? Int.max) 
        }
    }
    
    func deleteItems(withIds ids: Set<UUID>) {
        // Store the deleted items and their indices for potential undo
        let deletedItems = items.enumerated().filter { ids.contains($0.element.id) }
        if let firstDeleted = deletedItems.first {
            lastDeletedItem = (firstDeleted.element, firstDeleted.offset)
        }
        
        // Remove the items
        items.removeAll { ids.contains($0.id) }
        
        // Remove from selected and favorite sets
        selectedItems.subtract(ids)
        favoriteItems.subtract(ids)
        
        // Save changes
        saveItems()
        saveSelectedItems()
        saveFavoriteItems()
        
        // Add haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Item Suggestion Methods
    // Search for grocery items matching the query
    func searchForItems(matching query: String) -> [SuggestedItem] {
        guard query.count >= 2 else { return [] }
        
        // Get matches from the database
        let matches = GroceryItemsDatabase.findMatches(for: query, limit: 8)
        
        // Convert to suggestion items
        let suggestions = matches.map { (key, itemData) -> SuggestedItem in
            return SuggestedItem(
                name: itemData.name,
                category: itemData.category,
                unit: itemData.unit,
                amount: itemData.defaultAmount,
                source: .database
            )
        }
        
        // Also search recent items
        let recentItems = Array(items.suffix(10)) // Get the 10 most recent items
        let recentMatches = recentItems
            .filter { $0.name.lowercased().contains(query.lowercased()) }
            .prefix(3)
            .map { item -> SuggestedItem in
                return SuggestedItem(
                    name: item.name,
                    category: item.category,
                    unit: item.unit,
                    amount: item.amount,
                    source: .recent
                )
            }
        
        // Combine and limit results
        var results = Array(recentMatches)
        results.append(contentsOf: suggestions)
        return Array(results.prefix(8))
    }
    
    // Model for suggested items
    struct SuggestedItem: Identifiable {
        let id = UUID()
        let name: String
        let category: IngredientCategory
        let unit: IngredientUnit
        let amount: Double
        let source: SuggestionSource
        
        var displayQuantity: String {
            if amount == floor(amount) {
                return "\(Int(amount)) \(unit.rawValue)"
            } else {
                return String(format: "%.1f \(unit.rawValue)", amount)
            }
        }
    }
    
    // Source of suggestion
    enum SuggestionSource {
        case recent
        case database
    }
    
    // MARK: - Enhanced methods for MealPlanView integration
    // Add a shopping item directly
    func addItem(id: String = UUID().uuidString, 
                 name: String, 
                 quantity: Double,
                 unit: IngredientUnit, 
                 category: IngredientCategory = .other) {
        
        let ingredient = Ingredient(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            amount: quantity,
            unit: unit,
            category: category
        )
        
        addItem(ingredient)
    }
    
    // Overload for adding items from recipes with string-based parameters
    func addItem(name: String, 
                 quantity: Double,
                 unit: String, 
                 category: String,
                 recipe: String? = nil) {
        
        // Convert string parameters to enums
        let unitEnum = IngredientUnit(rawValue: unit) ?? .pieces
        let categoryEnum = IngredientCategory(rawValue: category) ?? .other
        
        // Create the ingredient
        let ingredient = Ingredient(
            id: UUID(),
            name: name,
            amount: quantity,
            unit: unitEnum,
            category: categoryEnum,
            notes: recipe != nil ? "From recipe: \(recipe!)" : nil
        )
        
        // Add to shopping list
        addItem(ingredient)
    }
    
    // Clear the entire shopping list
    func clearList() {
        items.removeAll()
        selectedItems.removeAll()
        saveItems()
        saveSelectedItems()
    }
}
