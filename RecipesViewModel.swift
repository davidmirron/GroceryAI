import Foundation
import Combine

class RecipesViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []

    init() {
        loadInitialRecipes()
    }

    func loadInitialRecipes() {
        let initialRecipe = Recipe(
            id: UUID(),
            name: "Beef Stew",
            ingredients: [],
            instructions: [],
            estimatedTime: 120 * 60,
            servings: 6,
            nutritionalInfo: NutritionInfo(calories: 800, protein: 50, carbs: 60, fat: 40),
            dietaryTags: [.keto],
            missingItems: [],
            seasonalNote: "Ideal for cold weather."
        )
        recipes.append(initialRecipe)
    }

    // Add other recipe-related functions here
} 