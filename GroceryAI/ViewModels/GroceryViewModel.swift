import Foundation
import SwiftUI
import Combine

class GroceryViewModel: ObservableObject {
    @Published var groceryItems: [GroceryItem] = []
    
    var categories: [String] {
        Array(Set(groceryItems.map { $0.category })).sorted()
    }
    
    func itemsByCategory(_ category: String) -> [GroceryItem] {
        groceryItems.filter { $0.category == category }
    }
    
    func toggleItem(_ item: GroceryItem) {
        if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
            groceryItems[index].isChecked.toggle()
        }
    }
    
    func incrementQuantity(for item: GroceryItem) {
        if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
            groceryItems[index].quantity += 1.0
        }
    }
    
    func decrementQuantity(for item: GroceryItem) {
        if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
            if groceryItems[index].quantity > 1.0 {
                groceryItems[index].quantity -= 1.0
            } else {
                // Optional: Show confirmation before deleting
                deleteItem(item)
            }
        }
    }
    
    func deleteItem(_ item: GroceryItem) {
        groceryItems.removeAll { $0.id == item.id }
    }
    
    func addItem(_ item: GroceryItem) {
        groceryItems.append(item)
    }
} 