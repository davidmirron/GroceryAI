import Foundation

class IngredientMatcher {
    func calculateMatchScore(recipe: Recipe, available: [Ingredient]) -> Double {
        let requiredIngredients = Set(recipe.ingredients.map { $0.name.lowercased() })
        let availableIngredients = Set(available.map { $0.name.lowercased() })
        
        let matchedIngredients = requiredIngredients.intersection(availableIngredients)
        let matchScore = Double(matchedIngredients.count) / Double(requiredIngredients.count)
        
        // Bonus points for using more of the available ingredients
        let utilizationScore = Double(matchedIngredients.count) / Double(availableIngredients.count)
        
        return (matchScore * 0.7) + (utilizationScore * 0.3)
    }
    
    func getMissingIngredients(recipe: Recipe, available: [Ingredient]) -> [Ingredient] {
        let availableSet = Set(available.map { $0.name.lowercased() })
        return recipe.ingredients.filter { !availableSet.contains($0.name.lowercased()) }
    }
} 