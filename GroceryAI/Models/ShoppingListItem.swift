import Foundation

struct ShoppingListItem: Identifiable {
    let id: UUID
    let ingredient: Ingredient
    var isChecked: Bool
    
    init(ingredient: Ingredient, isChecked: Bool = false) {
        self.id = ingredient.id
        self.ingredient = ingredient
        self.isChecked = isChecked
    }
} 