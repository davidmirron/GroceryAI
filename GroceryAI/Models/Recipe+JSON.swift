import Foundation

// JSON Recipe structure for importing from recipe JSON file
struct JSONRecipe: Codable {
    let id: String
    let name: String
    let category: String
    let ingredients: [JSONIngredient]
    let instructions: [String]
    let prepTime: Int // in minutes
    let cookTime: Int // in minutes
    let servings: Int
    let nutritionInfo: NutritionInfoDTO
    let dietaryTags: [String]
    let difficulty: String
    let imageFileName: String
    let source: String?
    
    // Convert to existing Recipe model
    func toRecipe() -> Recipe {
        // Convert JSON ingredients to app Ingredient model
        let appIngredients = ingredients.map { jsonIngredient in
            return Ingredient(
                name: jsonIngredient.name,
                amount: jsonIngredient.amount,
                unit: IngredientUnit(rawValue: jsonIngredient.unit) ?? .pieces,
                category: IngredientCategory(rawValue: jsonIngredient.category) ?? .other,
                isPerishable: jsonIngredient.isPerishable,
                typicalShelfLife: jsonIngredient.shelfLife
            )
        }
        
        // Convert dietary tags to app DietaryTag model
        let appDietaryTags: Set<Recipe.DietaryTag> = Set(
            dietaryTags.compactMap { tagString in
                let normalizedTag = tagString.lowercased()
                switch normalizedTag {
                case "vegetarian":
                    return .vegetarian
                case "vegan":
                    return .vegan
                case "gluten-free", "gluten free":
                    return .glutenFree
                case "dairy-free", "dairy free":
                    return .dairyFree
                case "low-carb", "low carb":
                    return .lowCarb
                case "keto":
                    return .keto
                case "paleo":
                    return .paleo
                default:
                    return nil
                }
            }
        )
        
        // Convert nutrition info
        let appNutritionInfo = NutritionInfo(
            calories: nutritionInfo.calories,
            protein: nutritionInfo.protein,
            carbs: nutritionInfo.carbs,
            fat: nutritionInfo.fat
        )
        
        // Determine recipe category from string
        let recipeCategory = RecipeCategory.allCases.first { $0.rawValue == category } ?? .other
        
        // Determine recipe difficulty from string
        let recipeDifficulty = RecipeDifficulty.allCases.first { $0.rawValue == difficulty } ?? .medium
        
        // Total time in seconds (prep + cook time in minutes * 60)
        let prepTimeInSeconds = TimeInterval(prepTime * 60)
        let cookTimeInSeconds = TimeInterval(cookTime * 60)
        let totalTimeInSeconds = prepTimeInSeconds + cookTimeInSeconds
        
        return Recipe(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            ingredients: appIngredients,
            instructions: instructions,
            estimatedTime: totalTimeInSeconds,
            servings: servings,
            nutritionalInfo: appNutritionInfo,
            missingIngredients: [], // Will be calculated later
            dietaryTags: appDietaryTags,
            imageName: imageFileName,
            matchScore: 0.0, // Will be calculated later
            isCustomRecipe: false,
            category: recipeCategory,
            difficulty: recipeDifficulty,
            prepTime: prepTimeInSeconds,
            cookTime: cookTimeInSeconds,
            source: source
        )
    }
}

// JSON Ingredient structure
struct JSONIngredient: Codable {
    let name: String
    let amount: Double
    let unit: String
    let category: String
    let isPerishable: Bool
    let shelfLife: Int?
}

// Extension to the RecipeListViewModel to load recipes from JSON
extension RecipeListViewModel {
    
    // Load recipes from a local JSON file
    func loadRecipesFromJSON(fileName: String = "recipes") {
        // Get the URL for the JSON file in the app bundle
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("⚠️ Could not find \(fileName).json in the app bundle")
            return
        }
        
        // Set loading state
        self.isLoading = true
        print("🍳 Starting recipe import from \(fileName).json")
        
        // Performance metrics
        let totalStartTime = CFAbsoluteTimeGetCurrent()
        
        // We'll do this in a background thread to avoid freezing the UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Load the JSON data
            let data: Data
            do {
                data = try Data(contentsOf: url)
            } catch {
                DispatchQueue.main.async {
                    print("⚠️ Error reading recipe JSON file: \(error.localizedDescription)")
                    self.isLoading = false
                }
                return
            }
            
            // Calculate file size for diagnostics
            let fileSizeInMB = Double(data.count) / 1_000_000.0
            print("📊 Recipe JSON file size: \(String(format: "%.2f", fileSizeInMB)) MB")
            
            // Decode the JSON into an array of JSONRecipe objects
            let decoder = JSONDecoder()
            let decodingStartTime = CFAbsoluteTimeGetCurrent()
            
            let jsonRecipes: [JSONRecipe]
            do {
                jsonRecipes = try decoder.decode([JSONRecipe].self, from: data)
            } catch {
                DispatchQueue.main.async {
                    print("⚠️ Error decoding recipe JSON: \(error.localizedDescription)")
                    self.isLoading = false
                }
                return
            }
            
            let decodingTime = CFAbsoluteTimeGetCurrent() - decodingStartTime
            
            print("📊 JSON decoding time: \(String(format: "%.2f", decodingTime * 1000)) ms for \(jsonRecipes.count) recipes")
            
            // Get a set of existing recipe IDs to avoid duplicates
            let existingIds = Set(self.recipes.map { $0.id.uuidString })
            
            // Convert JSONRecipe objects to Recipe objects (potentially CPU intensive)
            let conversionStart = CFAbsoluteTimeGetCurrent()
            
            // Process in batches for large datasets
            let batchSize = min(50, max(10, jsonRecipes.count / 4)) // Dynamic batch size
            var newRecipes: [Recipe] = []
            var duplicateCount = 0
            var validationIssues = 0
            
            // Progress tracking for large datasets
            let totalBatches = Int(ceil(Double(jsonRecipes.count) / Double(batchSize)))
            
            for i in stride(from: 0, to: jsonRecipes.count, by: batchSize) {
                let batchStartTime = CFAbsoluteTimeGetCurrent()
                let endIndex = min(i + batchSize, jsonRecipes.count)
                let batch = jsonRecipes[i..<endIndex]
                let currentBatch = (i / batchSize) + 1
                
                print("🔄 Processing batch \(currentBatch)/\(totalBatches) (\(batch.count) recipes)")
                
                // Convert batch and filter out duplicates
                for jsonRecipe in batch {
                    // Skip if this recipe already exists
                    if existingIds.contains(jsonRecipe.id) {
                        duplicateCount += 1
                        continue
                    }
                    
                    // Validate recipe data
                    guard !jsonRecipe.name.isEmpty,
                          !jsonRecipe.ingredients.isEmpty,
                          !jsonRecipe.instructions.isEmpty else {
                        validationIssues += 1
                        continue
                    }
                    
                    let recipe = jsonRecipe.toRecipe()
                    newRecipes.append(recipe)
                }
                
                let batchTime = CFAbsoluteTimeGetCurrent() - batchStartTime
                print("  ✓ Batch \(currentBatch) processed in \(String(format: "%.2f", batchTime * 1000)) ms")
            }
            
            let conversionTime = CFAbsoluteTimeGetCurrent() - conversionStart
            print("📊 Model conversion time: \(String(format: "%.2f", conversionTime * 1000)) ms")
            
            // Return to main thread for UI updates
            DispatchQueue.main.async {
                // Track which categories we've loaded
                var categoryStats: [String: Int] = [:]
                var dietaryStats: [String: Int] = [:]
                var difficultyStats: [String: Int] = [:]
                
                // Add the recipes to our collection if they're not duplicates
                if !newRecipes.isEmpty {
                    // Track statistics
                    for recipe in newRecipes {
                        // Category stats
                        let category = recipe.category.rawValue
                        categoryStats[category] = (categoryStats[category] ?? 0) + 1
                        
                        // Dietary stats
                        for tag in recipe.dietaryTags {
                            let tagName = tag.rawValue
                            dietaryStats[tagName] = (dietaryStats[tagName] ?? 0) + 1
                        }
                        
                        // Difficulty stats
                        let difficulty = recipe.difficulty.rawValue
                        difficultyStats[difficulty] = (difficultyStats[difficulty] ?? 0) + 1
                    }
                    
                    // Add to our collection
                    self.recipes.append(contentsOf: newRecipes)
                    
                    // Save the recipes to CoreData
                    self.saveRecipesToCoreData(newRecipes)
                    
                    // Calculate total processing time
                    let totalTime = CFAbsoluteTimeGetCurrent() - totalStartTime
                    
                    print("✅ Added \(newRecipes.count) new recipes from JSON in \(String(format: "%.2f", totalTime)) seconds")
                    print("📝 Skipped \(duplicateCount) duplicate recipes")
                    
                    if validationIssues > 0 {
                        print("⚠️ \(validationIssues) recipes had validation issues and were skipped")
                    }
                    
                    // Print category stats
                    print("\n📊 Recipe Categories:")
                    for (category, count) in categoryStats.sorted(by: { $0.value > $1.value }) {
                        print("  - \(category): \(count) recipes")
                    }
                    
                    // Print dietary stats
                    if !dietaryStats.isEmpty {
                        print("\n📊 Dietary Tags:")
                        for (tag, count) in dietaryStats.sorted(by: { $0.value > $1.value }) {
                            print("  - \(tag): \(count) recipes")
                        }
                    }
                    
                    // Print difficulty stats
                    print("\n📊 Difficulty Levels:")
                    for (diff, count) in difficultyStats.sorted(by: { $0.value > $1.value }) {
                        print("  - \(diff): \(count) recipes")
                    }
                } else {
                    print("📝 No new recipes to add (all were duplicates or invalid)")
                }
                
                // Update loading state
                self.isLoading = false
                
                // Store recipe count in UserDefaults for diagnostics
                UserDefaults.standard.set(self.recipes.count, forKey: "totalRecipeCount")
                
                // Mark that we've loaded recipes from JSON
                UserDefaults.standard.set(true, forKey: "hasLoadedRecipeJSON")
                
                // Notify observers that data has changed
                self.objectWillChange.send()
            }
        }
    }
    
    // Helper method to save recipes to CoreData
    private func saveRecipesToCoreData(_ recipes: [Recipe]) {
        // Use a background context for better performance
        CoreDataManager.shared.performBackgroundTask { context in
            // Save each recipe to CoreData
            for recipe in recipes {
                _ = recipe.toCoreData(in: context)
            }
            
            // Context is automatically saved by performBackgroundTask
            print("💾 Saved \(recipes.count) recipes to CoreData")
        }
    }
    
    // Helper method to check if JSON recipes are loaded properly
    func verifyRecipeJSONIntegrity() -> Bool {
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            print("⚠️ Recipe JSON file not found")
            return false
        }
        
        do {
            // Just try to decode without storing
            let data = try Data(contentsOf: url)
            let _ = try JSONDecoder().decode([JSONRecipe].self, from: data)
            return true
        } catch {
            print("⚠️ Recipe JSON integrity check failed: \(error.localizedDescription)")
            return false
        }
    }
} 