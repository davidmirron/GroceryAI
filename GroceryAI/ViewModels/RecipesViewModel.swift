import Foundation
import Combine
import SwiftUI

class RecipesViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Use an injected RecipeListViewModel instead of creating our own
    private var recipeListViewModel: RecipeListViewModel
    
    // Add ShoppingListViewModel as a dependency
    private var shoppingListViewModel: ShoppingListViewModel
    
    // Default initializer that allows injection of ViewModels
    init(recipeListViewModel: RecipeListViewModel = RecipeListViewModel(), 
         shoppingListViewModel: ShoppingListViewModel = ShoppingListViewModel()) {
        self.recipeListViewModel = recipeListViewModel
        self.shoppingListViewModel = shoppingListViewModel
        loadInitialRecipes()
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
                    
                    // Boost match score slightly to make UI look better
                    // This helps prevent too many recipes showing very low scores
                    let adjustedMatchScore = min(1.0, matchScore * 1.2)
                    
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
                        matchScore: adjustedMatchScore
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
                imageName: recipe.imageName
            )
            
            recipeListViewModel.addRecipe(cleanRecipe)
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
    
    // Add a function to verify recipes are loaded
    func verifyRecipesLoaded() -> Bool {
        // This will check if recipes are properly loaded
        let count = recipes.count
        print("Current recipe count: \(count)")
        return count > 0
    }
    
    // Helper function to round match scores to avoid floating point precision issues
    private func roundMatchScore(_ score: Double) -> Double {
        // Round to 2 decimal places to avoid precision issues
        return (score * 100).rounded() / 100
    }
    
    // Use this in your calculateMatchScore function
    private func calculateMatchScore(for recipe: Recipe) -> Double {
        // If there are no ingredients in the shopping list, return 0
        if shoppingListViewModel.items.isEmpty {
            return 0.0
        }
        
        // Count matching ingredients
        var matchedIngredientCount = 0
        
        // For each ingredient in the recipe
        for ingredient in recipe.ingredients {
            // Check if we have this ingredient in our shopping list
            let hasIngredient = shoppingListViewModel.items.contains { shoppingListIngredient in
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
            
            if hasIngredient {
                matchedIngredientCount += 1
            }
        }
        
        // Calculate score based on percentage of matched ingredients
        let totalIngredients = recipe.ingredients.count
        let rawScore = totalIngredients > 0 ? Double(matchedIngredientCount) / Double(totalIngredients) : 0.0
        
        // Apply a slight boost to make the UI look better (matching the algorithm in generateRecipes)
        let adjustedScore = min(1.0, rawScore * 1.2)
        
        // Round to avoid floating point precision issues
        return roundMatchScore(adjustedScore)
    }
    
    // MARK: - Custom Recipe Management
    func addCustomRecipeAndRefresh(_ recipe: Recipe) {
        // Create a clean copy with isCustomRecipe set to true
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
            matchScore: 0.95, // High match score for user's own recipes
            isCustomRecipe: true // Explicitly mark as custom
        )
        
        // 1. Add to recipe list for persistence
        recipeListViewModel.addRecipe(customRecipe)
        
        // 2. Remove if already in the suggestions list
        if let index = recipes.firstIndex(where: { $0.id == customRecipe.id }) {
            recipes.remove(at: index)
        }
        
        // 3. Insert at the top of suggestions
        recipes.insert(customRecipe, at: 0)
        
        // 4. Trigger UI update
        objectWillChange.send()
        
        // 5. Debug output
        print("Added custom recipe: \(customRecipe.name), isCustom: \(customRecipe.isCustomRecipe)")
    }
    
    // MARK: - Custom Recipe Filter
    func customRecipes() -> [Recipe] {
        // First try to use the isCustomRecipe flag
        let markedCustomRecipes = recipeListViewModel.recipes.filter { $0.isCustomRecipe }
        
        // If we have custom recipes from the flag, use those
        if !markedCustomRecipes.isEmpty {
            return markedCustomRecipes
        }
        
        // Otherwise fall back to the old method - identify custom recipes as those not in defaults
        let defaultRecipeNames = getDefaultRecipes().map { $0.name }
        return recipeListViewModel.recipes.filter { !defaultRecipeNames.contains($0.name) }
    }
} 