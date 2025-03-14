import Foundation
import Combine
import SwiftUI
import UIKit

class RecipesViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedFilter: RecipeFilter = .all
    
    // Use an injected RecipeListViewModel instead of creating our own
    // Make accessible for recipe deletion
    public var recipeListViewModel: RecipeListViewModel
    
    // Add ShoppingListViewModel as a dependency
    private var shoppingListViewModel: ShoppingListViewModel
    
    // Default initializer that allows injection of ViewModels
    init(recipeListViewModel: RecipeListViewModel = RecipeListViewModel(), 
         shoppingListViewModel: ShoppingListViewModel = ShoppingListViewModel()) {
        self.recipeListViewModel = recipeListViewModel
        self.shoppingListViewModel = shoppingListViewModel
        loadInitialRecipes()
    }
    
    // MARK: - Recipe Categorization
    
    /// Returns recipes with 90%+ match that can be cooked tonight
    func cookTonightRecipes() -> [Recipe] {
        return recipes.filter { $0.matchScore >= 0.9 }
    }
    
    /// Returns recipes with 60-89% match that are almost ready to cook
    func almostThereRecipes() -> [Recipe] {
        return recipes.filter { $0.matchScore >= 0.6 && $0.matchScore < 0.9 }
    }
    
    /// Returns recipes with 30-59% match that are worth exploring
    func worthExploringRecipes() -> [Recipe] {
        return recipes.filter { $0.matchScore >= 0.3 && $0.matchScore < 0.6 }
    }
    
    /// Returns all custom recipes created by the user
    func customRecipes() -> [Recipe] {
        // First try to use the isCustomRecipe flag
        let markedCustomRecipes = recipes.filter { $0.isCustomRecipe }
        
        // If we have custom recipes from the flag, use those
        if !markedCustomRecipes.isEmpty {
            return markedCustomRecipes
        }
        
        // Check in RecipeListViewModel for saved recipes (these are the user's saved recipes)
        // This is the primary source of truth for user's recipes
        let savedRecipes = recipeListViewModel.recipes
        if !savedRecipes.isEmpty {
            return savedRecipes
        }
        
        // We shouldn't reach this point, but as a fallback return an empty array
        // rather than trying to guess which recipes might be custom
        return []
    }
    
    /// Returns filtered recipes based on the selected filter
    func filteredRecipes() -> [Recipe] {
        // Use the extension method for consistent filtering logic
        return recipes.filtered(by: selectedFilter)
    }
    
    /// Apply a filter to the recipes list
    func applyFilter(_ filter: RecipeFilter) {
        self.selectedFilter = filter
        objectWillChange.send()
    }
    
    // MARK: - Shopping List Integration
    
    /// Add a single missing ingredient to the shopping list
    func addMissingIngredient(_ ingredient: Ingredient) {
        shoppingListViewModel.addItem(ingredient)
        
        // Update the recipe matching data
        refreshRecipes()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Add all missing ingredients from a recipe to the shopping list
    func addAllMissingIngredients(from recipe: Recipe) {
        for ingredient in recipe.missingIngredients {
            shoppingListViewModel.addItem(ingredient)
        }
        
        // Update the recipe matching data
        refreshRecipes()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Refresh recipes with latest shopping list data and match scores
    func refreshRecipes() {
        // Start loading
        isLoading = true
        
        // Check if we should load JSON recipes
        let hasLoadedJSON = UserDefaults.standard.bool(forKey: "hasLoadedRecipeJSON")
        let recipeCount = CoreDataManager.shared.getRecipeCount()
        
        if !hasLoadedJSON || recipeCount == 0 {
            print("🍽️ First run or no recipes in CoreData: Loading recipes from JSON...")
            refreshWithJSONRecipes(recipeListViewModel: recipeListViewModel)
            
            // After JSON is loaded, we'll continue with normal refresh
            // This will happen when the refreshWithJSONRecipes completion block is called
            return
        }
        
        // Get current shopping list items
        let currentItems = shoppingListViewModel.items
        
        // Create a local copy of recipes to work with
        let allRecipes = recipeListViewModel.recipes
        
        // Show loading state for better UX
        if recipes.isEmpty {
            isLoading = true
        }
        
        // Add a slight delay for better visual feedback if we're showing loading indicator
        let delay: TimeInterval = isLoading ? 0.5 : 0.1
        
        // Process recipes in background to avoid UI freezes
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            
            // Calculate match scores for recipes
            var updatedRecipes: [Recipe] = []
            
            for recipe in allRecipes {
                recipe.matchScore = self.calculateMatchScore(for: recipe, with: currentItems)
                
                // Update missing ingredients
                recipe.missingIngredients = self.getMissingIngredients(for: recipe, with: currentItems)
                
                updatedRecipes.append(recipe)
            }
            
            // Sort by match score (descending)
            updatedRecipes.sort { $0.matchScore > $1.matchScore }
            
            // Update the recipes
            self.recipes = updatedRecipes
            
            // Finish loading
            self.isLoading = false
            
            // Notify UI that we've changed
            self.objectWillChange.send()
        }
    }
    
    func loadInitialRecipes() {
        // Skip loading if recipes are already loaded
        if !recipes.isEmpty {
            print("Recipes already loaded, skipping initialization")
            return
        }
        
        // Initialize with default recipes for display on first load
        let defaultRecipes = getDefaultRecipes()
        
        // Add debug information
        print("Loading \(defaultRecipes.count) default recipes")
        
        // Ensure we're getting all recipes
        recipes = defaultRecipes
        
        // Make sure we're marking ingredients as missing correctly
        for i in 0..<recipes.count {
            recipes[i].missingIngredients = recipes[i].ingredients
            
            // Set initial match score to zero since no shopping list items
            recipes[i].matchScore = calculateMatchScore(for: recipes[i])
            
            // Log each recipe for debugging
            print("Recipe \(i): \(recipes[i].name) - Match score: \(recipes[i].matchScore)")
        }
        
        // Force UI update
        objectWillChange.send()
    }
    
    // Generate recipe suggestions based on available ingredients
    func generateRecipes(from ingredients: [Ingredient]) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay - in a real app this would be an API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Filter recipes that can be made with current ingredients
            var availableRecipes: [Recipe] = []
            
            // Get all recipes from RecipeListViewModel
            let allRecipes = self.recipeListViewModel.recipes
            
            // If we don't have any user recipes, use some defaults
            let recipesToCheck = allRecipes.isEmpty ? self.getDefaultRecipes() : allRecipes
            
            // Make sure we'll always have recipes to display
            if recipesToCheck.isEmpty {
                // If somehow we still have no recipes to check, force using defaults
                availableRecipes = self.getDefaultRecipes()
            } else {
                // IMPROVED MATCHING ALGORITHM:
                // For each recipe, check if we have the ingredients
                for recipe in recipesToCheck {
                    var missingIngredients: [Ingredient] = []
                    var matchedIngredientCount = 0
                    
                    // For each ingredient in the recipe
                    for ingredient in recipe.ingredients {
                        // Check if we have this ingredient in our shopping list
                        let hasIngredient = ingredients.contains { shoppingListIngredient in
                            // IMPROVED MATCHING - More precise matching by using word boundaries
                            let shoppingName = shoppingListIngredient.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                            let recipeName = ingredient.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Check for exact matches first
                            if shoppingName == recipeName {
                                return true
                            }
                            
                            // Then check for more specific substring matches
                            // Split names into words for better matching
                            let shoppingWords = shoppingName.split(separator: " ")
                            let recipeWords = recipeName.split(separator: " ")
                            
                            // Check if any shopping list word exactly matches any recipe word
                            for shoppingWord in shoppingWords {
                                for recipeWord in recipeWords {
                                    if shoppingWord == recipeWord && shoppingWord.count > 3 {
                                        // Only match on significant words (length > 3)
                                        return true
                                    }
                                }
                            }
                            
                            // Fallback to simple matching for short ingredient names
                            return (shoppingName.contains(recipeName) && recipeName.count > 3) ||
                                   (recipeName.contains(shoppingName) && shoppingName.count > 3)
                        }
                        
                        if !hasIngredient {
                            missingIngredients.append(ingredient)
                        } else {
                            matchedIngredientCount += 1
                        }
                    }
                    
                    // Calculate match score (0.0 to 1.0) based on percentage of matched ingredients
                    let totalIngredients = recipe.ingredients.count
                    let matchScore = totalIngredients > 0 ? Double(matchedIngredientCount) / Double(totalIngredients) : 0.0
                    
                    // Boost match score slightly to make UI look better, but preserve exact 100% matches
                    let adjustedMatchScore: Double
                    if matchScore >= 1.0 {
                        adjustedMatchScore = 1.0  // Keep perfect matches at exactly 1.0
                    } else {
                        adjustedMatchScore = min(0.99, matchScore * 1.2)  // Boost non-perfect matches, but cap at 99%
                    }
                    
                    // Create a copy of the recipe with updated missing ingredients and match score
                    let recipeCopy = Recipe(
                        id: recipe.id,
                        name: recipe.name,
                        ingredients: recipe.ingredients,
                        instructions: recipe.instructions,
                        estimatedTime: recipe.estimatedTime,
                        servings: recipe.servings,
                        nutritionalInfo: recipe.nutritionalInfo,
                        missingIngredients: missingIngredients,
                        dietaryTags: recipe.dietaryTags,
                        imageName: recipe.imageName,
                        matchScore: adjustedMatchScore,
                        isCustomRecipe: recipe.isCustomRecipe
                    )
                    
                    // Add to available recipes
                    availableRecipes.append(recipeCopy)
                }
                
                // Sort recipes by match score (high to low) and then by missing ingredients count (low to high)
                availableRecipes.sort { recipeA, recipeB in
                    // First prioritize by match score (higher is better)
                    if abs(recipeA.matchScore - recipeB.matchScore) > 0.1 {  // Only use match score if significant difference
                        return recipeA.matchScore > recipeB.matchScore
                    }
                    
                    // Then by number of missing ingredients (fewer is better)
                    return recipeA.missingIngredients.count < recipeB.missingIngredients.count
                }
            }
            
            self.recipes = availableRecipes
            self.isLoading = false
        }
    }
    
    // Add a recipe to the persistent storage
    func addToRecipeList(_ recipe: Recipe) {
        // Check if recipe already exists to avoid duplicates
        if !recipeListViewModel.recipes.contains(where: { $0.id == recipe.id }) {
            // Create a clean copy of the recipe without the missing ingredients
            let cleanRecipe = Recipe(
                id: recipe.id,
                name: recipe.name,
                ingredients: recipe.ingredients,
                instructions: recipe.instructions,
                estimatedTime: recipe.estimatedTime,
                servings: recipe.servings,
                nutritionalInfo: recipe.nutritionalInfo,
                dietaryTags: recipe.dietaryTags,
                imageName: recipe.imageName,
                isCustomRecipe: true, // Make sure to mark as a custom recipe
                category: recipe.category,
                difficulty: recipe.difficulty,
                prepTime: recipe.prepTime,
                cookTime: recipe.cookTime,
                source: recipe.source
            )
            
            recipeListViewModel.addRecipe(cleanRecipe)
            
            // Force a refresh of the recipes to update the UI
            // This ensures the saved recipe will appear in the My Recipes section
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.refreshRecipes()
            }
        }
    }
    
    // Get some default recipes if user hasn't created any yet
    private func getDefaultRecipes() -> [Recipe] {
        return [
            // Recipe 1: Classic Pancakes
            Recipe(
                name: "Classic Pancakes",
                ingredients: [
                    Ingredient(name: "All-Purpose Flour", amount: 250.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Milk", amount: 300.0, unit: .milliliters, category: .dairy),
                    Ingredient(name: "Eggs", amount: 2.0, unit: .pieces, category: .dairy),
                    Ingredient(name: "Sugar", amount: 2.0, unit: .tablespoons, category: .pantry),
                    Ingredient(name: "Baking Powder", amount: 1.0, unit: .tablespoons, category: .pantry),
                    Ingredient(name: "Butter", amount: 30.0, unit: .grams, category: .dairy),
                    Ingredient(name: "Vanilla Extract", amount: 1.0, unit: .teaspoons, category: .pantry)
                ],
                instructions: [
                    "Whisk flour, sugar, baking powder, and salt in a large bowl",
                    "In another bowl, whisk milk, eggs, melted butter, and vanilla",
                    "Pour wet ingredients into dry ingredients and stir until just combined",
                    "Heat a lightly oiled griddle or pan over medium-high heat",
                    "Pour batter onto the griddle, using approximately 1/4 cup for each pancake",
                    "Cook until bubbles form on the surface, then flip and cook until golden brown",
                    "Serve with maple syrup and fresh berries"
                ],
                estimatedTime: 25 * 60,
                servings: 4,
                nutritionalInfo: NutritionInfo(calories: 350, protein: 10, carbs: 45, fat: 12),
                dietaryTags: [.vegetarian],
                imageName: "pancakes"
            ),
            
            // Recipe 2: Spaghetti Bolognese
            Recipe(
                name: "Spaghetti Bolognese",
                ingredients: [
                    Ingredient(name: "Spaghetti", amount: 500.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Ground Beef", amount: 500.0, unit: .grams, category: .meat),
                    Ingredient(name: "Onion", amount: 1.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Garlic", amount: 3.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Carrots", amount: 2.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Celery", amount: 2.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Tomato Paste", amount: 2.0, unit: .tablespoons, category: .pantry),
                    Ingredient(name: "Canned Tomatoes", amount: 400.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Beef Broth", amount: 200.0, unit: .milliliters, category: .pantry),
                    Ingredient(name: "Oregano", amount: 1.0, unit: .teaspoons, category: .pantry),
                    Ingredient(name: "Basil", amount: 1.0, unit: .teaspoons, category: .pantry),
                    Ingredient(name: "Parmesan", amount: 50.0, unit: .grams, category: .dairy)
                ],
                instructions: [
                    "Heat oil in a large pot over medium heat",
                    "Add onion, garlic, carrots, and celery; cook until softened",
                    "Add ground beef and cook until browned",
                    "Stir in tomato paste, then add canned tomatoes and beef broth",
                    "Add herbs and seasonings, then simmer for 30 minutes",
                    "Meanwhile, cook spaghetti according to package instructions",
                    "Drain pasta and serve topped with bolognese sauce",
                    "Garnish with freshly grated parmesan"
                ],
                estimatedTime: 45 * 60,
                servings: 6,
                nutritionalInfo: NutritionInfo(calories: 520, protein: 25, carbs: 65, fat: 18),
                imageName: "spaghetti"
            ),
            
            // Recipe 3: Classic Caesar Salad
            Recipe(
                name: "Classic Caesar Salad",
                ingredients: [
                    Ingredient(name: "Romaine Lettuce", amount: 1.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Parmesan Cheese", amount: 50.0, unit: .grams, category: .dairy),
                    Ingredient(name: "Croutons", amount: 100.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Eggs", amount: 1.0, unit: .pieces, category: .dairy),
                    Ingredient(name: "Garlic", amount: 2.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Dijon Mustard", amount: 1.0, unit: .teaspoons, category: .pantry),
                    Ingredient(name: "Anchovy Fillets", amount: 4.0, unit: .pieces, category: .pantry),
                    Ingredient(name: "Olive Oil", amount: 3.0, unit: .tablespoons, category: .pantry),
                    Ingredient(name: "Lemon Juice", amount: 2.0, unit: .tablespoons, category: .produce)
                ],
                instructions: [
                    "Wash and dry the romaine lettuce, then tear into bite-sized pieces",
                    "Mince garlic and anchovy fillets together until they form a paste",
                    "Whisk the garlic-anchovy paste with egg yolk, mustard, and lemon juice",
                    "Slowly drizzle in olive oil while whisking to create an emulsion",
                    "Toss lettuce with the dressing until evenly coated",
                    "Add croutons and grated parmesan, toss again",
                    "Season with black pepper and serve immediately"
                ],
                estimatedTime: 20 * 60,
                servings: 4,
                nutritionalInfo: NutritionInfo(calories: 320, protein: 12, carbs: 14, fat: 24),
                imageName: "caesar_salad"
            ),
            
            // Recipe 4: Vegetable Stir Fry
            Recipe(
                name: "Vegetable Stir Fry",
                ingredients: [
                    Ingredient(name: "Bell Peppers", amount: 2.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Broccoli", amount: 1.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Carrots", amount: 2.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Snow Peas", amount: 100.0, unit: .grams, category: .produce),
                    Ingredient(name: "Mushrooms", amount: 150.0, unit: .grams, category: .produce),
                    Ingredient(name: "Garlic", amount: 3.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Ginger", amount: 1.0, unit: .tablespoons, category: .produce),
                    Ingredient(name: "Soy Sauce", amount: 3.0, unit: .tablespoons, category: .pantry),
                    Ingredient(name: "Sesame Oil", amount: 1.0, unit: .tablespoons, category: .pantry),
                    Ingredient(name: "Rice", amount: 200.0, unit: .grams, category: .pantry)
                ],
                instructions: [
                    "Cook rice according to package instructions",
                    "Chop all vegetables into bite-sized pieces",
                    "Heat vegetable oil in a wok or large frying pan over high heat",
                    "Add garlic and ginger, stir for 30 seconds until fragrant",
                    "Add vegetables in order of cooking time: carrots first, then broccoli, bell peppers, snow peas, and mushrooms last",
                    "Stir-fry for 5-7 minutes until vegetables are crisp-tender",
                    "Add soy sauce and sesame oil, toss to combine",
                    "Serve hot over rice"
                ],
                estimatedTime: 30 * 60,
                servings: 4,
                nutritionalInfo: NutritionInfo(calories: 320, protein: 8, carbs: 60, fat: 5),
                dietaryTags: [.vegetarian, .vegan],
                imageName: "stir_fry"
            ),
            
            // Recipe 5: Chocolate Chip Cookies
            Recipe(
                name: "Chocolate Chip Cookies",
                ingredients: [
                    Ingredient(name: "All-Purpose Flour", amount: 280.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Butter", amount: 225.0, unit: .grams, category: .dairy),
                    Ingredient(name: "Brown Sugar", amount: 200.0, unit: .grams, category: .pantry),
                    Ingredient(name: "White Sugar", amount: 100.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Eggs", amount: 2.0, unit: .pieces, category: .dairy),
                    Ingredient(name: "Vanilla Extract", amount: 2.0, unit: .teaspoons, category: .pantry),
                    Ingredient(name: "Baking Soda", amount: 1.0, unit: .teaspoons, category: .pantry),
                    Ingredient(name: "Salt", amount: 0.5, unit: .teaspoons, category: .pantry),
                    Ingredient(name: "Chocolate Chips", amount: 350.0, unit: .grams, category: .pantry)
                ],
                instructions: [
                    "Preheat oven to 375°F (190°C) and line baking sheets with parchment paper",
                    "Cream together butter, brown sugar, and white sugar until smooth",
                    "Beat in eggs one at a time, then stir in vanilla",
                    "In a separate bowl, combine flour, baking soda, and salt",
                    "Gradually blend the dry ingredients into the wet mixture",
                    "Fold in chocolate chips",
                    "Drop tablespoon-sized portions onto baking sheets",
                    "Bake for 9-11 minutes or until edges are golden brown",
                    "Allow cookies to cool on baking sheet for 2 minutes, then transfer to wire racks"
                ],
                estimatedTime: 40 * 60,
                servings: 24,
                nutritionalInfo: NutritionInfo(calories: 180, protein: 2, carbs: 24, fat: 9),
                dietaryTags: [.vegetarian],
                imageName: "cookies"
            ),
            
            // Recipe 6: Chicken Curry
            Recipe(
                name: "Chicken Curry",
                ingredients: [
                    Ingredient(name: "Chicken Thighs", amount: 750.0, unit: .grams, category: .meat),
                    Ingredient(name: "Onion", amount: 2.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Garlic", amount: 4.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Ginger", amount: 2.0, unit: .tablespoons, category: .produce),
                    Ingredient(name: "Curry Powder", amount: 3.0, unit: .tablespoons, category: .pantry),
                    Ingredient(name: "Turmeric", amount: 1.0, unit: .teaspoons, category: .pantry),
                    Ingredient(name: "Cumin", amount: 1.0, unit: .teaspoons, category: .pantry),
                    Ingredient(name: "Coconut Milk", amount: 400.0, unit: .milliliters, category: .pantry),
                    Ingredient(name: "Tomatoes", amount: 2.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Vegetable Oil", amount: 2.0, unit: .tablespoons, category: .pantry),
                    Ingredient(name: "Rice", amount: 300.0, unit: .grams, category: .pantry)
                ],
                instructions: [
                    "Cut chicken into bite-sized pieces",
                    "Heat oil in a large pan over medium heat",
                    "Add diced onion and cook until translucent",
                    "Add minced garlic and ginger, cook for another minute",
                    "Add curry powder, turmeric, and cumin; stir to coat the onions",
                    "Add chicken and cook until no longer pink on the outside",
                    "Add diced tomatoes and coconut milk, stir well",
                    "Simmer for 20-25 minutes until chicken is fully cooked and sauce thickens",
                    "Serve hot with rice"
                ],
                estimatedTime: 45 * 60,
                servings: 6,
                nutritionalInfo: NutritionInfo(calories: 450, protein: 30, carbs: 35, fat: 22),
                imageName: "curry"
            ),
            
            // Recipe 7: Greek Salad
            Recipe(
                name: "Greek Salad",
                ingredients: [
                    Ingredient(name: "Cucumber", amount: 1.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Tomatoes", amount: 4.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Red Onion", amount: 0.5, unit: .pieces, category: .produce),
                    Ingredient(name: "Bell Pepper", amount: 1.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Feta Cheese", amount: 200.0, unit: .grams, category: .dairy),
                    Ingredient(name: "Kalamata Olives", amount: 100.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Olive Oil", amount: 3.0, unit: .tablespoons, category: .pantry),
                    Ingredient(name: "Lemon Juice", amount: 2.0, unit: .tablespoons, category: .produce),
                    Ingredient(name: "Dried Oregano", amount: 1.0, unit: .teaspoons, category: .pantry)
                ],
                instructions: [
                    "Cut cucumber, tomatoes, and bell pepper into bite-sized chunks",
                    "Thinly slice the red onion",
                    "Combine all vegetables in a large bowl",
                    "Add olives and crumbled feta cheese",
                    "In a small bowl, whisk together olive oil, lemon juice, oregano, salt, and pepper",
                    "Pour dressing over the salad and gently toss",
                    "Let sit for 10 minutes before serving to allow flavors to meld"
                ],
                estimatedTime: 15 * 60,
                servings: 4,
                nutritionalInfo: NutritionInfo(calories: 280, protein: 8, carbs: 10, fat: 22),
                dietaryTags: [.vegetarian, .glutenFree],
                imageName: "greek_salad"
            ),
            
            // Recipe 8: Vegetarian Chili
            Recipe(
                name: "Vegetarian Chili",
                ingredients: [
                    Ingredient(name: "Black Beans", amount: 400.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Kidney Beans", amount: 400.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Chickpeas", amount: 400.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Onion", amount: 1.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Bell Peppers", amount: 2.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Zucchini", amount: 1.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Corn", amount: 200.0, unit: .grams, category: .produce),
                    Ingredient(name: "Crushed Tomatoes", amount: 800.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Vegetable Broth", amount: 250.0, unit: .milliliters, category: .pantry),
                    Ingredient(name: "Chili Powder", amount: 2.0, unit: .tablespoons, category: .pantry),
                    Ingredient(name: "Cumin", amount: 2.0, unit: .teaspoons, category: .pantry),
                    Ingredient(name: "Paprika", amount: 1.0, unit: .teaspoons, category: .pantry)
                ],
                instructions: [
                    "Dice onion and bell peppers, cube the zucchini",
                    "In a large pot, sauté onion until translucent",
                    "Add bell peppers and zucchini, cook for 5 minutes",
                    "Stir in drained and rinsed beans, chickpeas, and corn",
                    "Add crushed tomatoes, vegetable broth, chili powder, cumin, and paprika",
                    "Simmer for 30 minutes, stirring occasionally",
                    "Adjust seasoning as needed",
                    "Serve hot with optional toppings like avocado, sour cream, or cheese"
                ],
                estimatedTime: 50 * 60,
                servings: 8,
                nutritionalInfo: NutritionInfo(calories: 280, protein: 14, carbs: 50, fat: 3),
                dietaryTags: [.vegetarian, .vegan, .glutenFree],
                imageName: "chili"
            ),
            
            // Recipe 9: Beef Tacos
            Recipe(
                name: "Beef Tacos",
                ingredients: [
                    Ingredient(name: "Ground Beef", amount: 500.0, unit: .grams, category: .meat),
                    Ingredient(name: "Taco Shells", amount: 12.0, unit: .pieces, category: .pantry),
                    Ingredient(name: "Onion", amount: 1.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Garlic", amount: 2.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Taco Seasoning", amount: 2.0, unit: .tablespoons, category: .pantry),
                    Ingredient(name: "Lettuce", amount: 0.5, unit: .pieces, category: .produce),
                    Ingredient(name: "Tomato", amount: 2.0, unit: .pieces, category: .produce),
                    Ingredient(name: "Cheddar Cheese", amount: 200.0, unit: .grams, category: .dairy),
                    Ingredient(name: "Sour Cream", amount: 100.0, unit: .grams, category: .dairy),
                    Ingredient(name: "Avocado", amount: 1.0, unit: .pieces, category: .produce)
                ],
                instructions: [
                    "Preheat oven to 325°F (165°C) for warming taco shells",
                    "In a large skillet, brown ground beef over medium heat",
                    "Add chopped onion and garlic, cook until softened",
                    "Stir in taco seasoning and a small amount of water",
                    "Simmer for 5 minutes until the mixture thickens",
                    "Meanwhile, shred lettuce, dice tomatoes, and grate cheese",
                    "Warm taco shells in the oven for 5 minutes",
                    "Assemble tacos with beef mixture, vegetables, cheese, and toppings"
                ],
                estimatedTime: 30 * 60,
                servings: 4,
                nutritionalInfo: NutritionInfo(calories: 420, protein: 25, carbs: 30, fat: 22),
                imageName: "tacos"
            ),
            
            // Recipe 10: Banana Bread
            Recipe(
                name: "Banana Bread",
                ingredients: [
                    Ingredient(name: "Ripe Bananas", amount: 3.0, unit: .pieces, category: .produce),
                    Ingredient(name: "All-Purpose Flour", amount: 250.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Butter", amount: 115.0, unit: .grams, category: .dairy),
                    Ingredient(name: "Brown Sugar", amount: 150.0, unit: .grams, category: .pantry),
                    Ingredient(name: "Eggs", amount: 2.0, unit: .pieces, category: .dairy),
                    Ingredient(name: "Baking Soda", amount: 1.0, unit: .teaspoons, category: .pantry),
                    Ingredient(name: "Salt", amount: 0.5, unit: .teaspoons, category: .pantry),
                    Ingredient(name: "Vanilla Extract", amount: 1.0, unit: .teaspoons, category: .pantry),
                    Ingredient(name: "Walnuts", amount: 100.0, unit: .grams, category: .pantry, isPerishable: true)
                ],
                instructions: [
                    "Preheat oven to 350°F (175°C) and grease a 9x5 inch loaf pan",
                    "In a large bowl, cream together butter and brown sugar",
                    "Beat in eggs, mashed bananas, and vanilla",
                    "In a separate bowl, whisk together flour, baking soda, and salt",
                    "Gradually stir flour mixture into banana mixture until just combined",
                    "Fold in chopped walnuts if using",
                    "Pour batter into prepared loaf pan",
                    "Bake for 60-65 minutes, or until a toothpick inserted into the center comes out clean",
                    "Let bread cool in pan for 10 minutes, then remove to a wire rack"
                ],
                estimatedTime: 80 * 60,
                servings: 10,
                nutritionalInfo: NutritionInfo(calories: 320, protein: 5, carbs: 45, fat: 14),
                dietaryTags: [.vegetarian],
                imageName: "banana_bread"
            )
        ]
    }
    
    // MARK: - Custom Recipe Management
    func addCustomRecipeAndRefresh(_ recipe: Recipe) {
        // Make sure the recipe is marked as a custom recipe
        let customRecipe = Recipe(
            id: recipe.id,
            name: recipe.name,
            ingredients: recipe.ingredients,
            instructions: recipe.instructions,
            estimatedTime: recipe.estimatedTime,
            servings: recipe.servings,
            nutritionalInfo: recipe.nutritionalInfo,
            dietaryTags: recipe.dietaryTags,
            imageName: recipe.imageName,
            isCustomRecipe: true,
            category: recipe.category,
            difficulty: recipe.difficulty,
            prepTime: recipe.prepTime,
            cookTime: recipe.cookTime,
            source: recipe.source
        )
        
        // Add to recipe list
        recipeListViewModel.addRecipe(customRecipe)
        
        // Refresh recipes to update UI
        refreshRecipes()
    }
    
    // MARK: - Recipe Discovery Features
    
    /// Find similar recipes to a given recipe
    func findSimilarRecipes(to recipe: Recipe, limit: Int = 3) -> [Recipe] {
        // Skip the original recipe
        let candidates = recipes.filter { $0.id != recipe.id }
        
        // Calculate similarity scores
        let scoredRecipes = candidates.map { candidate -> (Recipe, Double) in
            let score = calculateSimilarityScore(between: recipe, and: candidate)
            return (candidate, score)
        }
        
        // Sort by score (descending) and take the top results
        return scoredRecipes
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
            .map { $0.0 }
    }
    
    /// Calculate how similar two recipes are (0-1 scale)
    private func calculateSimilarityScore(between recipe1: Recipe, and recipe2: Recipe) -> Double {
        var score = 0.0
        
        // Same category is a strong signal
        if recipe1.category == recipe2.category {
            score += 0.4
        }
        
        // Similar difficulty
        if recipe1.difficulty == recipe2.difficulty {
            score += 0.1
        }
        
        // Ingredient overlap
        let ingredients1 = Set(recipe1.ingredients.map { $0.name.lowercased() })
        let ingredients2 = Set(recipe2.ingredients.map { $0.name.lowercased() })
        
        if !ingredients1.isEmpty && !ingredients2.isEmpty {
            let intersection = ingredients1.intersection(ingredients2)
            let union = ingredients1.union(ingredients2)
            
            // Jaccard similarity for ingredients
            let similarity = Double(intersection.count) / Double(union.count)
            score += similarity * 0.3
        }
        
        // Dietary tag overlap
        let tags1 = recipe1.dietaryTags
        let tags2 = recipe2.dietaryTags
        
        if !tags1.isEmpty && !tags2.isEmpty {
            let commonTags = tags1.intersection(tags2)
            let union = tags1.union(tags2)
            
            if !union.isEmpty {
                // Jaccard similarity for tags
                let similarity = Double(commonTags.count) / Double(union.count)
                score += similarity * 0.2
            }
        }
        
        return min(score, 1.0)  // Cap at 1.0
    }
    
    // MARK: - Match Score Grouping
    
    /// Returns recipes with high match scores (Cook Tonight category)
    func getCookTonight() -> [Recipe] {
        return recipes.filter { $0.matchScore >= 0.7 }
    }
    
    /// Returns recipes with medium match scores (Almost There category)
    func getAlmostThere() -> [Recipe] {
        return recipes.filter { $0.matchScore >= 0.4 && $0.matchScore < 0.7 }
    }
    
    /// Returns recipes with low match scores (Worth Exploring category)
    func getWorthExploring() -> [Recipe] {
        return recipes.filter { $0.matchScore < 0.4 }
    }
}

// MARK: - Recipe Matching Extension
extension RecipesViewModel {
    // Calculate how well the user's current ingredients match a recipe
    func calculateMatchScore(for recipe: Recipe, with userIngredients: [GroceryItem]) -> Double {
        guard !recipe.ingredients.isEmpty else { return 0.0 }
        
        var matchedIngredients = 0
        
        for recipeIngredient in recipe.ingredients {
            // Check if the user has this ingredient
            if userHasIngredient(recipeIngredient, in: userIngredients) {
                matchedIngredients += 1
            }
        }
        
        // Calculate the percentage of ingredients matched
        return Double(matchedIngredients) / Double(recipe.ingredients.count)
    }
    
    // Overloaded version of calculateMatchScore for Ingredient arrays
    func calculateMatchScore(for recipe: Recipe, with userIngredients: [Ingredient]) -> Double {
        let groceryItems = convertToGroceryItems(userIngredients)
        return calculateMatchScore(for: recipe, with: groceryItems)
    }
    
    // Helper to convert Ingredient to GroceryItem for matching
    private func convertToGroceryItems(_ ingredients: [Ingredient]) -> [GroceryItem] {
        return ingredients.map { ingredient in
            GroceryItem(
                id: ingredient.id,
                name: ingredient.name,
                quantity: ingredient.amount,
                unit: ingredient.unit.rawValue,
                category: ingredient.category.rawValue,
                isChecked: false
            )
        }
    }
    
    // Overloaded version to support Ingredient arrays
    func getBestRecipeMatches(with userIngredients: [Ingredient], limit: Int = 3) -> [Recipe] {
        let groceryItems = convertToGroceryItems(userIngredients)
        return getBestRecipeMatches(with: groceryItems, limit: limit)
    }
    
    // Determine if the user has a specific ingredient
    private func userHasIngredient(_ recipeIngredient: Ingredient, in userIngredients: [GroceryItem]) -> Bool {
        // Look for ingredient by name (case-insensitive)
        return userIngredients.contains { userIngredient in
            let shoppingName = userIngredient.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let recipeName = recipeIngredient.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for exact matches first
            if shoppingName == recipeName {
                return true
            }
            
            // Then check for more specific substring matches
            // Split names into words for better matching
            let shoppingWords = shoppingName.split(separator: " ")
            let recipeWords = recipeName.split(separator: " ")
            
            // Check if any shopping list word exactly matches any recipe word
            for shoppingWord in shoppingWords {
                for recipeWord in recipeWords {
                    if shoppingWord == recipeWord && shoppingWord.count > 3 {
                        // Only match on significant words (length > 3)
                        return true
                    }
                }
            }
            
            // Fallback to simple matching for short ingredient names
            return (shoppingName.contains(recipeName) && recipeName.count > 3) ||
                   (recipeName.contains(shoppingName) && shoppingName.count > 3)
        }
    }
    
    // Get list of ingredients needed for a recipe that the user doesn't have
    func getMissingIngredients(for recipe: Recipe, with userIngredients: [GroceryItem]) -> [Ingredient] {
        var missingIngredients: [Ingredient] = []
        
        for recipeIngredient in recipe.ingredients {
            if !userHasIngredient(recipeIngredient, in: userIngredients) {
                missingIngredients.append(recipeIngredient)
            }
        }
        
        return missingIngredients
    }
    
    // Overloaded version of getMissingIngredients for Ingredient arrays
    func getMissingIngredients(for recipe: Recipe, with userIngredients: [Ingredient]) -> [Ingredient] {
        let groceryItems = convertToGroceryItems(userIngredients)
        return getMissingIngredients(for: recipe, with: groceryItems)
    }
    
    // Get the best recipe matches for the user's current ingredients - WITHOUT modifying state
    func getBestRecipeMatches(with userIngredients: [GroceryItem], limit: Int = 3) -> [Recipe] {
        // Calculate match scores for all recipes WITHOUT modifying them
        let matchedRecipes = recipes.map { recipe -> (Recipe, Double) in
            let matchScore = calculateMatchScore(for: recipe, with: userIngredients)
            return (recipe, matchScore)
        }
        
        // Sort by match score (highest first)
        let sortedMatches = matchedRecipes.sorted { $0.1 > $1.1 }
        
        // Return recipes with a reasonable match score
        return sortedMatches
            .filter { $0.1 >= 0.3 } // At least 30% match
            .prefix(limit)
            .map { (recipe, score) -> Recipe in
                // Create a copy with updated match score, but DON'T modify the original
                let updatedRecipe = recipe
                updatedRecipe.matchScore = score
                updatedRecipe.missingIngredients = getMissingIngredients(for: recipe, with: userIngredients)
                return updatedRecipe
            }
    }
    
    // Get best recipe match (if any exist)
    func getBestMatch(from userIngredients: [GroceryItem]) -> Recipe? {
        let topMatches = getBestRecipeMatches(with: userIngredients, limit: 1)
        return topMatches.first
    }
    
    // Overloaded version for Ingredient arrays
    func getBestMatch(from userIngredients: [Ingredient]) -> Recipe? {
        let groceryItems = convertToGroceryItems(userIngredients)
        return getBestMatch(from: groceryItems)
    }
    
    // Get recipe suggestions based on what's in the shopping list - WITHOUT modifying state
    func getRecipeSuggestions(from userIngredients: [GroceryItem]) -> [Recipe] {
        // Just return the best matches without modifying the original recipes array
        return getBestRecipeMatches(with: userIngredients)
    }
    
    // Overloaded version for Ingredient arrays
    func getRecipeSuggestions(from userIngredients: [Ingredient]) -> [Recipe] {
        let groceryItems = convertToGroceryItems(userIngredients)
        return getRecipeSuggestions(from: groceryItems)
    }
    
    // Call this method from a button action, NOT during view updates
    func refreshRecipeScores(with userIngredients: [GroceryItem]) {
        DispatchQueue.main.async {
            // Calculate new scores
            let updatedRecipes = self.recipes.map { recipe -> Recipe in
                let matchScore = self.calculateMatchScore(for: recipe, with: userIngredients)
                let updatedRecipe = recipe
                updatedRecipe.matchScore = matchScore
                updatedRecipe.missingIngredients = self.getMissingIngredients(for: recipe, with: userIngredients)
                return updatedRecipe
            }
            
            // Only update the published property once, outside of view updates
            self.objectWillChange.send()
            self.recipes = updatedRecipes
        }
    }
    
    // Helper function to calculate match score for a recipe with current shopping list
    private func calculateMatchScore(for recipe: Recipe) -> Double {
        return calculateMatchScore(for: recipe, with: shoppingListViewModel.items)
    }
    
    func refreshWithJSONRecipes(recipeListViewModel: RecipeListViewModel) {
        // Set loading state
        isLoading = true
        
        // Check if we have already loaded the JSON recipes and have recipes in CoreData
        let recipeCount = CoreDataManager.shared.getRecipeCount()
        if UserDefaults.standard.bool(forKey: "hasLoadedRecipeJSON") && recipeCount > 0 {
            print("JSON recipes already loaded in CoreData, skipping")
            isLoading = false
            
            // Continue with regular refresh process, which calculates match scores
            refreshRecipes()
            return
        }
        
        // Add some debug info
        print("🔄 Starting JSON recipe loading process...")
        
        // Perform in background to avoid UI freeze
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // First, ensure RecipeListViewModel has loaded initial data
            recipeListViewModel.ensureInitialDataLoaded()
            
            // Load recipes from JSON through the provided recipeListViewModel
            recipeListViewModel.loadRecipesFromJSON()
            
            // Mark as loaded so we don't reload every time
            UserDefaults.standard.set(true, forKey: "hasLoadedRecipeJSON")
            
            // Also store the app version so we can refresh on updates
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                UserDefaults.standard.set(appVersion, forKey: "lastRecipeJSONVersion")
            }
            
            // Return to main thread for UI updates
            DispatchQueue.main.async {
                // Get the loaded recipes for statistics
                let totalRecipeCount = recipeListViewModel.recipes.count
                let coreDataCount = CoreDataManager.shared.getRecipeCount()
                print("✅ JSON recipe loading complete. Total recipes: \(totalRecipeCount), CoreData count: \(coreDataCount)")
                
                // Continue with refreshRecipes to calculate match scores with the loaded data
                self.refreshRecipes()
            }
        }
    }
} 