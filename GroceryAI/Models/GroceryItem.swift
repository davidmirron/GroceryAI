import Foundation

struct GroceryItem: Identifiable {
    let id: UUID
    let name: String
    var quantity: Double
    let unit: String
    let category: String
    var isChecked: Bool
    
    init(id: UUID = UUID(), name: String, quantity: Double = 1.0, unit: String = "grams", category: String, isChecked: Bool = false) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.isChecked = isChecked
    }
} 