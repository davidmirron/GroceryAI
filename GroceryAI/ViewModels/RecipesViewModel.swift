import Foundation
import Combine
import SwiftUI

class RecipesViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Sample recipes database - in a real app, this would be loaded from persistent storage
    private var allRecipes: [Recipe] = []
    
    init() {
        loadInitialRecipes()
    }
    
    func loadInitialRecipes() {
        // Populate allRecipes with some sample recipes
        allRecipes = [
            Recipe(
                name: "Pancakes",
                ingredients: [
                    Ingredient(name: "Flour", amount: 250.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Milk", amount: 300.0, unit: .liters, category: .dairy),
                    Ingredient(name: "Eggs", amount: 2.0, unit: .pieces, category: .dairy),
                    Ingredient(name: "Sugar", amount: 2.0, unit: .cups, category: .pantry)
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
                nutritionalInfo: NutritionInfo(calories: 350, protein: 10, carbs: 45, fat: 12),
                missingIngredients: []
            ),
            Recipe(
                name: "Spaghetti Carbonara",
                ingredients: [
                    Ingredient(name: "Spaghetti", amount: 500.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Bacon", amount: 200.0, unit: .grams, category: .meat),
                    Ingredient(name: "Eggs", amount: 4.0, unit: .pieces, category: .dairy),
                    Ingredient(name: "Parmesan", amount: 100.0, unit: .grams, category: .dairy)
                ],
                instructions: [
                    "Cook pasta according to package instructions",
                    "Fry bacon until crispy",
                    "Beat eggs and mix with grated cheese",
                    "Mix everything together while pasta is hot",
                    "Season with black pepper"
                ],
                estimatedTime: 30 * 60,
                servings: 4,
                nutritionalInfo: NutritionInfo(calories: 650, protein: 30, carbs: 60, fat: 25),
                missingIngredients: []
            ),
            Recipe(
                name: "Garden Salad",
                ingredients: [
                    Ingredient(name: "Lettuce", amount: 1.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Tomatoes", amount: 2.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Cucumber", amount: 1.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Olive Oil", amount: 2.0, unit: .cups, category: .pantry)
                ],
                instructions: [
                    "Wash all vegetables",
                    "Chop into bite-sized pieces",
                    "Mix in a large bowl",
                    "Dress with olive oil and seasonings"
                ],
                estimatedTime: 15 * 60,
                servings: 2,
                nutritionalInfo: NutritionInfo(calories: 120, protein: 2, carbs: 8, fat: 8),
                missingIngredients: []
            )
        ]
        
        // Set dietary tags for the recipes
        allRecipes[0].dietaryTags = [.vegetarian]
        allRecipes[2].dietaryTags = [.vegetarian, .vegan, .glutenFree]
        
        // Generate initial suggestions
        generateRecipes(from: [])
    }
    
    func generateRecipes(from ingredients: [Ingredient]) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay - in a real app this would be an API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Filter recipes that can be made with current ingredients
            var availableRecipes: [Recipe] = []
            
            // For each recipe, check which ingredients are missing based on the shopping list
            for recipe in self.allRecipes {
                var recipeCopy = recipe
                var missingIngredients: [Ingredient] = []
                
                // Check each recipe ingredient against the provided shopping list
                for recipeIngredient in recipe.ingredients {
                    // Check if the shopping list contains this ingredient
                    let hasIngredient = ingredients.contains { shoppingItem in
                        // Simple name-based matching (could be improved with fuzzy matching)
                        return shoppingItem.name.lowercased() == recipeIngredient.name.lowercased()
                    }
                    
                    if !hasIngredient {
                        missingIngredients.append(recipeIngredient)
                    }
                }
                
                recipeCopy.missingIngredients = missingIngredients
                availableRecipes.append(recipeCopy)
            }
            
            // Sort recipes by number of missing ingredients (fewest first)
            self.recipes = availableRecipes.sorted {
                $0.missingIngredients.count < $1.missingIngredients.count
            }
            
            self.isLoading = false
        }
    }
    
    // Method to add any missing recipe to the RecipeListViewModel
    func addToRecipeList(_ recipe: Recipe) {
        // In a real app, this would update a shared instance of RecipeListViewModel
        // For demo purposes, we just create a new one
        let recipeListViewModel = RecipeListViewModel()
        
        // Check if recipe already exists to avoid duplicates
        if !recipeListViewModel.recipes.contains(where: { $0.id == recipe.id }) {
            recipeListViewModel.recipes.append(recipe)
        }
    }
} 