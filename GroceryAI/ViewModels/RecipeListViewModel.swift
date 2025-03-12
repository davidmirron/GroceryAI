import Foundation
import SwiftUI
import CoreData

class RecipeListViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedCategory: RecipeCategory?
    
    // Cache for efficient recipe queries
    private var cachedRecipesByCategory: [RecipeCategory: [Recipe]] = [:]
    private var hasLoadedInitialData = false
    
    init() {
        loadRecipes()
    }
    
    // MARK: - Recipe CRUD Operations
    
    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        saveRecipes()
        
        // Clear cache after modifying data
        clearCaches()
    }
    
    func removeRecipe(at indexSet: IndexSet) {
        // Safely handle empty arrays
        guard !recipes.isEmpty else {
            print("Attempted to delete from an empty recipe array, ignoring")
            return
        }
        
        // Safety check to prevent index out of range
        let safeIndexSet = IndexSet(indexSet.filter { $0 < recipes.count })
        if safeIndexSet.count != indexSet.count {
            print("⚠️ Some indices were out of range and will be ignored")
        }
        
        // Get the recipes to remove
        let recipesToRemove = safeIndexSet.map { recipes[$0] }
        
        // Remove from memory
        recipes.remove(atOffsets: safeIndexSet)
        
        // Edge case: If this was the last recipe, also clear the cache
        if recipes.isEmpty {
            print("🧹 Removed last recipe, clearing caches")
            clearCaches()
            
            // Consider reloading defaults if needed
            if UserDefaults.standard.bool(forKey: "shouldLoadDefaultsOnEmpty") {
                print("⚙️ Reloading defaults as configured in settings")
                ensureInitialDataLoaded()
            }
        }
        
        // Remove from CoreData with better error handling
        CoreDataManager.shared.performBackgroundTask { context in
            var errorOccurred = false
            
            for recipe in recipesToRemove {
                // Find the corresponding CoreData object
                let fetchRequest: NSFetchRequest<CDRecipe> = CDRecipe.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", recipe.id as CVarArg)
                
                do {
                    let results = try context.fetch(fetchRequest)
                    for cdRecipe in results {
                        context.delete(cdRecipe)
                    }
                } catch {
                    errorOccurred = true
                    print("❌ Failed to delete recipe from CoreData: \(error)")
                }
            }
            
            // Only try to save if we haven't encountered errors
            if !errorOccurred {
                do {
                    try context.save()
                    print("✅ Successfully deleted \(recipesToRemove.count) recipes from CoreData")
                    
                    // Update UserDefaults with new count
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(self.recipes.count, forKey: "totalRecipeCount")
                    }
                    
                } catch {
                    print("❌ Failed to save context after deletion: \(error)")
                }
            }
        }
        
        // Clear cache after modifying data
        clearCaches()
    }
    
    func updateRecipe(_ updatedRecipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == updatedRecipe.id }) {
            recipes[index] = updatedRecipe
            saveRecipes()
            
            // Clear cache after modifying data
            clearCaches()
        }
    }
    
    // MARK: - Recipe Management
    
    // Clean slate method - resets to defaults
    func resetToDefaults() {
        // Clear all recipes from CoreData
        CoreDataManager.shared.deleteAllRecipes {
            // Reset in-memory recipes to a clean state
            self.loadRecipes()
            
            // Clear cache
            self.clearCaches()
        }
    }
    
    // MARK: - Recipe Persistence
    
    func saveRecipes() {
        // Use a background context for better performance
        CoreDataManager.shared.performBackgroundTask { context in
            // First, delete all existing recipes to avoid duplicates
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDRecipe.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("❌ Failed to delete existing recipes: \(error)")
                return
            }
            
            // Now save all recipes
            for recipe in self.recipes {
                _ = recipe.toCoreData(in: context)
            }
            
            // Context is automatically saved by performBackgroundTask
        }
        
        // Store recipe count in UserDefaults for diagnostics
        UserDefaults.standard.set(self.recipes.count, forKey: "totalRecipeCount")
    }
    
    func loadRecipes() {
        self.isLoading = true
        
        // Check if we have recipes in CoreData
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CDRecipe> = CDRecipe.fetchRequest()
        
        do {
            let cdRecipes = try context.fetch(fetchRequest)
            
            if !cdRecipes.isEmpty {
                // Convert CoreData recipes to our model
                self.recipes = cdRecipes.map { Recipe.fromCoreData($0) }
                
                // Validate and fix image references
                validateRecipeImages()
                
                print("📦 Loaded \(self.recipes.count) recipes from CoreData")
                self.isLoading = false
                return
            }
        } catch {
            print("❌ Failed to fetch recipes from CoreData: \(error)")
        }
        
        // If we couldn't load from CoreData, load a sample recipe
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
                nutritionalInfo: NutritionInfo(calories: 350, protein: 10, carbs: 45, fat: 12),
                category: .breakfast,
                difficulty: .easy,
                prepTime: 10 * 60,
                cookTime: 15 * 60
            )
        ]
        
        print("📝 Loaded default sample recipe")
        self.isLoading = false
    }
    
    // Validate recipe image references to ensure they're valid
    private func validateRecipeImages() {
        for i in 0..<recipes.count {
            guard let imageName = recipes[i].imageName else { continue }
            
            // Check if image exists in bundle
            if UIImage(named: imageName) != nil {
                // Valid bundle image, no action needed
                continue
            }
            
            // Check if URL is valid
            if let url = URL(string: imageName), (url.scheme == "http" || url.scheme == "https") {
                // Valid URL, but we'll check if it exists in the cache
                if let diskCachePath = ImageLoader.shared.getCachePathForKey(imageName),
                   FileManager.default.fileExists(atPath: diskCachePath.path) {
                    // Image exists in disk cache, no action needed
                    continue
                }
                
                // URL is valid but not cached, we'll keep it for normal loading
                continue
            }
            
            // Check if it's a file path that exists
            if let url = URL(string: imageName), FileManager.default.fileExists(atPath: url.path) {
                // Valid file path, no action needed
                continue
            }
            
            // If we got here, the image reference is invalid; use a category-based fallback
            print("⚠️ Invalid image reference detected: \(imageName). Using category fallback.")
            recipes[i].imageName = getCategoryPlaceholderImage(for: recipes[i].category)
        }
        
        // After validation, update CoreData if needed
        saveRecipes()
    }
    
    // Get a category-appropriate placeholder image name
    private func getCategoryPlaceholderImage(for category: RecipeCategory) -> String {
        switch category {
        case .breakfast: return "breakfast"
        case .lunch: return "lunch"
        case .dinner: return "dinner"
        case .dessert: return "dessert"
        case .appetizer: return "appetizer"
        case .salad: return "salad"
        case .soup: return "soup"
        case .mainCourse: return "main-course"
        case .sideDish: return "side-dish"
        case .beverage: return "beverage"
        case .snack: return "snack"
        case .other: return "recipe-placeholder"
        }
    }
    
    // MARK: - Recipe Filtering & Searching
    
    /// Returns recipes filtered by the current search text and selected category
    func filteredRecipes() -> [Recipe] {
        var result = recipes
        
        // Filter by category if one is selected
        if let category = selectedCategory {
            // Use the cached version if available
            if let cached = cachedRecipesByCategory[category] {
                result = cached
            } else {
                result = recipes.filter { $0.category == category }
                // Cache the result
                cachedRecipesByCategory[category] = result
            }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            let searchTerms = searchText.lowercased().split(separator: " ")
            
            result = result.filter { recipe in
                // Check if all search terms are found in any of these fields
                let recipeText = "\(recipe.name) \(recipe.category.rawValue) \(recipe.difficulty.rawValue) \(recipe.dietaryTags.map { $0.rawValue }.joined(separator: " "))".lowercased()
                
                // Each search term must be found
                return searchTerms.allSatisfy { term in
                    recipeText.contains(term)
                }
            }
        }
        
        return result
    }
    
    /// Returns recipes in the specified category
    func recipes(for category: RecipeCategory) -> [Recipe] {
        if let cached = cachedRecipesByCategory[category] {
            return cached
        }
        
        let result = recipes.filter { $0.category == category }
        cachedRecipesByCategory[category] = result
        return result
    }
    
    /// Returns all custom recipes created by the user
    func customRecipes() -> [Recipe] {
        return recipes.filter { $0.isCustomRecipe }
    }
    
    /// Returns recipes that match the given dietary preferences
    func recipes(matching dietaryTags: Set<Recipe.DietaryTag>) -> [Recipe] {
        return recipes.filter { recipe in
            !dietaryTags.isDisjoint(with: recipe.dietaryTags)
        }
    }
    
    /// Returns recipes that can be made within the specified time (in minutes)
    func quickRecipes(withinMinutes minutes: Int) -> [Recipe] {
        let seconds = TimeInterval(minutes * 60)
        return recipes.filter { $0.estimatedTime <= seconds }
    }
    
    // MARK: - Recipe Analytics
    
    /// Returns the count of recipes in each category
    func recipeCategoryCounts() -> [RecipeCategory: Int] {
        var counts: [RecipeCategory: Int] = [:]
        
        for recipe in recipes {
            counts[recipe.category, default: 0] += 1
        }
        
        return counts
    }
    
    /// Returns the count of recipes with each dietary tag
    func recipeDietaryTagCounts() -> [Recipe.DietaryTag: Int] {
        var counts: [Recipe.DietaryTag: Int] = [:]
        
        for recipe in recipes {
            for tag in recipe.dietaryTags {
                counts[tag, default: 0] += 1
            }
        }
        
        return counts
    }
    
    /// Returns the count of recipes by difficulty
    func recipeDifficultyCounts() -> [RecipeDifficulty: Int] {
        var counts: [RecipeDifficulty: Int] = [:]
        
        for recipe in recipes {
            counts[recipe.difficulty, default: 0] += 1
        }
        
        return counts
    }
    
    /// Returns statistics about the recipe database
    func recipeStatistics() -> [String: Any] {
        // Base stats
        var stats: [String: Any] = [
            "totalCount": recipes.count,
            "avgPrepTime": recipes.isEmpty ? 0 : recipes.reduce(0) { $0 + $1.prepTime } / Double(recipes.count) / 60, // in minutes
            "avgCookTime": recipes.isEmpty ? 0 : recipes.reduce(0) { $0 + $1.cookTime } / Double(recipes.count) / 60, // in minutes
            "avgTotalTime": recipes.isEmpty ? 0 : recipes.reduce(0) { $0 + $1.estimatedTime } / Double(recipes.count) / 60, // in minutes
            "avgServings": recipes.isEmpty ? 0 : recipes.reduce(0) { $0 + $1.servings } / recipes.count
        ]
        
        // Add category breakdown
        stats["categories"] = recipeCategoryCounts()
        
        // Add dietary tag breakdown
        stats["dietaryTags"] = recipeDietaryTagCounts()
        
        // Add difficulty breakdown
        stats["difficulties"] = recipeDifficultyCounts()
        
        // Ingredient stats
        let allIngredients = recipes.flatMap { $0.ingredients }
        let uniqueIngredientNames = Set(allIngredients.map { $0.name.lowercased() })
        stats["uniqueIngredientCount"] = uniqueIngredientNames.count
        stats["avgIngredientsPerRecipe"] = recipes.isEmpty ? 0 : allIngredients.count / recipes.count
        
        return stats
    }
    
    // Helper method to print a report of recipe statistics to the console
    func printRecipeStats() {
        let stats = recipeStatistics()
        
        print("\n=== Recipe Database Statistics ===")
        print("Total Recipes: \(stats["totalCount"] as? Int ?? 0)")
        print("Average Times:")
        print("  - Prep: \(String(format: "%.1f", stats["avgPrepTime"] as? Double ?? 0)) minutes")
        print("  - Cook: \(String(format: "%.1f", stats["avgCookTime"] as? Double ?? 0)) minutes")
        print("  - Total: \(String(format: "%.1f", stats["avgTotalTime"] as? Double ?? 0)) minutes")
        print("Average Servings: \(String(format: "%.1f", stats["avgServings"] as? Double ?? 0))")
        
        print("\nTop Categories:")
        if let categories = stats["categories"] as? [RecipeCategory: Int] {
            for (category, count) in categories.sorted(by: { $0.value > $1.value }).prefix(5) {
                print("  - \(category.rawValue): \(count) recipes")
            }
        }
        
        print("\nTop Dietary Tags:")
        if let dietaryTags = stats["dietaryTags"] as? [Recipe.DietaryTag: Int] {
            for (tag, count) in dietaryTags.sorted(by: { $0.value > $1.value }).prefix(5) {
                print("  - \(tag.rawValue): \(count) recipes")
            }
        }
        
        print("\nDifficulty Breakdown:")
        if let difficulties = stats["difficulties"] as? [RecipeDifficulty: Int] {
            for (difficulty, count) in difficulties.sorted(by: { $0.value > $1.value }) {
                print("  - \(difficulty.rawValue): \(count) recipes")
            }
        }
        
        print("\nIngredient Stats:")
        print("  - Unique Ingredients: \(stats["uniqueIngredientCount"] as? Int ?? 0)")
        print("  - Avg Ingredients Per Recipe: \(String(format: "%.1f", stats["avgIngredientsPerRecipe"] as? Double ?? 0))")
    }
    
    // MARK: - Image Management
    
    /// Preload images for all recipes to improve browsing experience
    func preloadRecipeImages() {
        guard !recipes.isEmpty else { return }
        
        print("🖼️ Starting recipe image preloading...")
        
        // Create a dispatch group to track completion
        let group = DispatchGroup()
        
        // Track statistics
        var preloadedCount = 0
        var cachedCount = 0
        var failedCount = 0
        
        // Process in chunks to avoid overwhelming the system
        let recipeChunks = recipes.chunked(into: 10)
        
        for (chunkIndex, recipeChunk) in recipeChunks.enumerated() {
            // Add a delay between chunks to prevent CPU spikes
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + Double(chunkIndex) * 0.2) {
                for recipe in recipeChunk {
                    guard let imageName = recipe.imageName, !imageName.isEmpty else { 
                        failedCount += 1
                        continue 
                    }
                    
                    group.enter()
                    
                    // Use thumbnail size for preloading to save memory
                    let thumbnailSize = CGSize(width: 200, height: 200)
                    
                    // Check if image is already cached
                    let cacheKey = NSString(string: imageName)
                    if ImageLoader.shared.cache.object(forKey: cacheKey) != nil {
                        // Already cached
                        cachedCount += 1
                        group.leave()
                    } else {
                        // Preload the image
                        ImageLoader.shared.loadImage(named: imageName, size: thumbnailSize) { _ in
                            preloadedCount += 1
                            group.leave()
                        }
                    }
                }
            }
        }
        
        // When all preloading is complete
        group.notify(queue: .main) {
            let totalRecipes = self.recipes.count
            let percentage = Double(preloadedCount + cachedCount) / Double(totalRecipes) * 100.0
            
            print("✅ Image preloading complete:")
            print("  - Total recipes: \(totalRecipes)")
            print("  - Images preloaded: \(preloadedCount)")
            print("  - Already cached: \(cachedCount)")
            print("  - No image available: \(failedCount)")
            print("  - Coverage: \(String(format: "%.1f", percentage))%")
            
            // Print cache statistics
            ImageLoader.shared.printCacheStatistics()
        }
    }
    
    // MARK: - Recipe Image Enhancement
    
    /// Enhance recipes with web image URLs for better visuals
    func enhanceRecipeImages() {
        // Only enhance recipes that don't already have valid image URLs
        var enhancedCount = 0
        
        for i in 0..<recipes.count {
            let recipe = recipes[i]
            
            // Skip if recipe already has a URL as image name
            if let imageName = recipe.imageName, 
               (imageName.hasPrefix("http://") || imageName.hasPrefix("https://")) {
                continue
            }
            
            // Add high-quality image URL based on recipe type/name
            let category = recipe.category
            let recipeName = recipe.name.lowercased()
            var imageURL: String? = nil
            
            // Assign appropriate image URL based on recipe characteristics
            if recipeName.contains("pancake") {
                imageURL = "https://images.unsplash.com/photo-1528207776546-365bb710ee93?q=80&w=1000"
            } else if recipeName.contains("spaghetti") || recipeName.contains("pasta") || recipeName.contains("noodle") {
                imageURL = "https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=1000"
            } else if recipeName.contains("salad") {
                imageURL = "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=1000"
            } else if recipeName.contains("stir fry") || recipeName.contains("vegetable") {
                imageURL = "https://images.unsplash.com/photo-1512058564366-18510be2db19?q=80&w=1000"
            } else if recipeName.contains("cookie") {
                imageURL = "https://images.unsplash.com/photo-1499636136210-6f4ee915583e?q=80&w=1000"
            } else if recipeName.contains("curry") {
                imageURL = "https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?q=80&w=1000"
            } else if recipeName.contains("greek") && recipeName.contains("salad") {
                imageURL = "https://images.unsplash.com/photo-1551248429-40975aa4de74?q=80&w=1000"
            } else if recipeName.contains("chili") {
                imageURL = "https://images.unsplash.com/photo-1564671546498-aa158112eee9?q=80&w=1000"
            } else if recipeName.contains("taco") {
                imageURL = "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?q=80&w=1000"
            } else if recipeName.contains("bread") {
                imageURL = "https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=1000"
            } else if recipeName.contains("banana") && recipeName.contains("bread") {
                imageURL = "https://images.unsplash.com/photo-1606101273945-e9eba91c0574?q=80&w=1000"
            } else {
                // Assign default image based on category if recipe-specific image not found
                switch category {
                case .breakfast:
                    imageURL = "https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?q=80&w=1000"
                case .lunch, .dinner, .mainCourse:
                    imageURL = "https://images.unsplash.com/photo-1547592180-85f173990554?q=80&w=1000"
                case .appetizer:
                    imageURL = "https://images.unsplash.com/photo-1541529086526-db283c563170?q=80&w=1000"
                case .sideDish:
                    imageURL = "https://images.unsplash.com/photo-1534938665420-4193effeacc4?q=80&w=1000"
                case .dessert:
                    imageURL = "https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?q=80&w=1000"
                case .snack:
                    imageURL = "https://images.unsplash.com/photo-1621939514649-280e2ee25f60?q=80&w=1000"
                case .soup:
                    imageURL = "https://images.unsplash.com/photo-1547592166-23ac45744acd?q=80&w=1000"
                case .salad:
                    imageURL = "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=1000"
                case .beverage:
                    imageURL = "https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?q=80&w=1000"
                case .other:
                    imageURL = "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000"
                }
            }
            
            // Update the recipe with the new image URL
            if let imageURL = imageURL {
                recipes[i].imageName = imageURL
                enhancedCount += 1
            }
        }
        
        print("🖼️ Enhanced \(enhancedCount) recipes with web image URLs")
        
        // Save the updated recipes to CoreData if needed
        saveRecipes()
    }
    
    // MARK: - Cache Management
    
    func clearCaches() {
        cachedRecipesByCategory.removeAll()
    }
    
    // Ensure consistent initialization
    func ensureInitialDataLoaded() {
        if !hasLoadedInitialData {
            // Check if we have recipes in CoreData first
            let recipeCount = CoreDataManager.shared.getRecipeCount()
            if recipeCount == 0 {
                // No recipes in CoreData, try to load JSON recipes
                print("No recipes found in CoreData. Loading from JSON...")
                loadRecipesFromJSON()
            } else {
                print("Found \(recipeCount) recipes in CoreData. Using existing data.")
                // Make sure recipes are loaded into memory
                loadRecipes()
            }
            
            // Add web image URLs to recipes that lack proper images
            enhanceRecipeImages()
            
            // Mark as initialized
            hasLoadedInitialData = true
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
    let category: String
    let difficulty: String
    let prepTime: TimeInterval
    let cookTime: TimeInterval
    let source: String?
    let nutritionInfo: NutritionInfoDTO?
}

// Nutrition info DTO for Codable support
struct NutritionInfoDTO: Codable {
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
} 