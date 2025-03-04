import Foundation
import SwiftUI

class RecipeListViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    
    init() {
        loadRecipes()
    }
    
    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        saveRecipes()
    }
    
    func removeRecipe(at indexSet: IndexSet) {
        recipes.remove(atOffsets: indexSet)
        saveRecipes()
    }
    
    // Clean slate method - resets to defaults
    func resetToDefaults() {
        // Clear saved recipes in UserDefaults
        UserDefaults.standard.removeObject(forKey: "savedRecipes")
        
        // Reset in-memory recipes to a clean state
        loadRecipes()
    }
    
    func saveRecipes() {
        // We need to convert Recipe objects to a Codable format since Recipe is not Codable
        let recipeDTOs = recipes.map { recipe in
            RecipeDTO(
                id: recipe.id.uuidString,
                name: recipe.name,
                ingredients: recipe.ingredients,
                instructions: recipe.instructions,
                estimatedTime: recipe.estimatedTime,
                servings: recipe.servings,
                dietaryTags: Array(recipe.dietaryTags).map { $0.rawValue },
                imageName: recipe.imageName,
                isCustomRecipe: recipe.isCustomRecipe
            )
        }
        
        if let encoded = try? JSONEncoder().encode(recipeDTOs) {
            UserDefaults.standard.set(encoded, forKey: "savedRecipes")
        }
    }
    
    func loadRecipes() {
        if let data = UserDefaults.standard.data(forKey: "savedRecipes"),
           let decodedDTOs = try? JSONDecoder().decode([RecipeDTO].self, from: data) {
            // Convert DTOs back to Recipe objects
            self.recipes = decodedDTOs.map { dto in
                let recipe = Recipe(
                    id: UUID(uuidString: dto.id) ?? UUID(),
                    name: dto.name,
                    ingredients: dto.ingredients,
                    instructions: dto.instructions,
                    estimatedTime: dto.estimatedTime,
                    servings: dto.servings,
                    imageName: dto.imageName,
                    isCustomRecipe: dto.isCustomRecipe
                )
                
                // Add dietary tags if present
                if !dto.dietaryTags.isEmpty {
                    recipe.dietaryTags = Set(dto.dietaryTags.compactMap { tagString in
                        Recipe.DietaryTag.allCases.first { $0.rawValue == tagString }
                    })
                }
                
                return recipe
            }
        } else {
            // Load a sample recipe if no saved recipes exist
            self.recipes = [
                Recipe(
                    name: "Pancakes",
                    ingredients: [
                        Ingredient(name: "Flour", amount: 250.0, unit: .grams, category: .pantry),
                        Ingredient(name: "Milk", amount: 300.0, unit: .milliliters, category: .dairy),
                        Ingredient(name: "Eggs", amount: 2.0, unit: .pieces, category: .dairy),
                        Ingredient(name: "Sugar", amount: 2.0, unit: .tablespoons, category: .pantry)
                    ],
                    instructions: [
                        "Mix flour, milk, and eggs in a bowl",
                        "Heat a pan with a little oil",
                        "Pour batter into the pan",
                        "Cook until bubbles form, then flip",
                        "Serve with maple syrup"
                    ],
                    estimatedTime: 25 * 60,
                    servings: 4,
                    nutritionalInfo: NutritionInfo(calories: 350, protein: 10, carbs: 45, fat: 12)
                )
            ]
        }
    }
}

// Data Transfer Object for Recipe to make it Codable
struct RecipeDTO: Codable {
    let id: String
    let name: String
    let ingredients: [Ingredient]
    let instructions: [String]
    let estimatedTime: TimeInterval
    let servings: Int
    let dietaryTags: [String]
    let imageName: String?
    let isCustomRecipe: Bool
} 