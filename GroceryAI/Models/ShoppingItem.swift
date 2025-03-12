import Foundation

struct ShoppingItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let quantity: Double
    let unit: IngredientUnit
    let category: IngredientCategory
    var isChecked: Bool
    
    init(id: String = UUID().uuidString, 
         name: String, 
         quantity: Double, 
         unit: IngredientUnit, 
         category: IngredientCategory = .other,
         isChecked: Bool = false) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.isChecked = isChecked
    }
    
    // Create from Ingredient
    init(from ingredient: Ingredient, isChecked: Bool = false) {
        self.id = ingredient.id.uuidString
        self.name = ingredient.name
        self.quantity = ingredient.amount
        self.unit = ingredient.unit
        self.category = ingredient.category
        self.isChecked = isChecked
    }
    
    // Convert to Ingredient
    func toIngredient() -> Ingredient {
        Ingredient(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            amount: quantity,
            unit: unit,
            category: category
        )
    }
} 