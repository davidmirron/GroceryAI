import Foundation

// Simplified to avoid errors
class NaturalLanguageParser {
    func parseIngredients(from text: String) -> [Ingredient] {
        // Return some sample ingredients
        return [
            Ingredient(name: "Apple", amount: 2, unit: .pieces, category: .produce),
            Ingredient(name: "Milk", amount: 1, unit: .liters, category: .dairy)
        ]
    }
} 