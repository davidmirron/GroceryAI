import Foundation

class IngredientMatcher {
    func calculateMatchScore(recipe: Recipe, available: [Ingredient]) -> Double {
        // Handle edge cases
        if recipe.ingredients.isEmpty {
            return 0.0
        }
        
        if available.isEmpty {
            return 0.0
        }
        
        let requiredIngredients = Set(recipe.ingredients.map { $0.name.lowercased() })
        let availableIngredients = Set(available.map { $0.name.lowercased() })
        
        let matchedIngredients = requiredIngredients.intersection(availableIngredients)
        let matchScore = Double(matchedIngredients.count) / Double(requiredIngredients.count)
        
        // For perfect matches (100%), preserve the exact score
        if matchedIngredients.count == requiredIngredients.count {
            return 1.0
        }
        
        // Bonus points for using more of the available ingredients
        let utilizationScore = Double(matchedIngredients.count) / Double(availableIngredients.count)
        
        // Calculate raw score
        let rawScore = (matchScore * 0.7) + (utilizationScore * 0.3)
        
        // Round to 2 decimal places to avoid precision issues
        return (rawScore * 100).rounded() / 100
    }
    
    func getMissingIngredients(recipe: Recipe, available: [Ingredient]) -> [Ingredient] {
        let availableSet = Set(available.map { $0.name.lowercased() })
        return recipe.ingredients.filter { !availableSet.contains($0.name.lowercased()) }
    }
} 