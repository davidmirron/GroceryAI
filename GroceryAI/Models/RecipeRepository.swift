import Foundation
import Combine
import CoreData
import SwiftUI

/// Error types for recipe loading
enum RecipeLoadError: Error {
    case coreDataFailed(Error)
    case jsonParsingFailed(Error)
    case noRecipesAvailable
    
    var localizedDescription: String {
        switch self {
        case .coreDataFailed(let error):
            return "Failed to load recipes from storage: \(error.localizedDescription)"
        case .jsonParsingFailed(let error):
            return "Failed to load recipes from built-in data: \(error.localizedDescription)"
        case .noRecipesAvailable:
            return "No recipes are available. Please check your connection and try again."
        }
    }
}

/// Central repository for accessing recipe data throughout the app
/// Provides a single source of truth for all recipe-related operations
class RecipeRepository: ObservableObject {
    static let shared = RecipeRepository()
    
    @Published var recipes: [Recipe] = []
    @Published var loadError: RecipeLoadError?
    
    // Cache for efficient recipe queries
    private var recipeCache: [UUID: Recipe] = [:]
    private var categoryCache: [RecipeCategory: [Recipe]] = [:]
    private var difficultyCache: [RecipeDifficulty: [Recipe]] = [:]
    
    // CoreData manager for persistence
    private let coreDataManager = CoreDataManager.shared
    
    // Initialization
    init() {
        // Load recipes from CoreData on initialization
        loadRecipesFromCoreData()
    }
    
    /// Load recipes from CoreData
    func loadRecipesFromCoreData() {
        do {
            // Fetch CDRecipe objects from CoreData
            let fetchRequest: NSFetchRequest<CDRecipe> = CDRecipe.fetchRequest()
            let cdRecipes = try coreDataManager.persistentContainer.viewContext.fetch(fetchRequest)
            
            // Convert CDRecipe objects to Recipe objects
            let appRecipes = cdRecipes.compactMap { Recipe.fromCoreData($0) }
            
            // Update the recipes array
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.recipes = appRecipes
                self.buildCaches()
                self.loadError = nil
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.loadError = .coreDataFailed(error)
            }
        }
    }
    
    /// Save a recipe to Core Data
    func saveRecipe(_ recipe: Recipe) {
        // Use the CoreData manager to save the recipe
        coreDataManager.performBackgroundTask { context in
            _ = recipe.toCoreData(in: context)
            // Context is automatically saved by performBackgroundTask
        }
        
        // If the recipe isn't already in our collection, add it
        if !recipes.contains(where: { $0.id == recipe.id }) {
            recipes.append(recipe)
            
            // Update caches
            recipeCache[recipe.id] = recipe
            categoryCache[recipe.category, default: []].append(recipe)
            difficultyCache[recipe.difficulty, default: []].append(recipe)
        }
    }
    
    /// Add multiple recipes to the repository
    func addRecipes(_ newRecipes: [Recipe]) {
        // Filter out recipes that already exist
        let existingIds = Set(recipes.map { $0.id })
        let uniqueRecipes = newRecipes.filter { !existingIds.contains($0.id) }
        
        // Save to CoreData
        if !uniqueRecipes.isEmpty {
            coreDataManager.performBackgroundTask { context in
                for recipe in uniqueRecipes {
                    _ = recipe.toCoreData(in: context)
                }
                // Context is automatically saved by performBackgroundTask
            }
            
            // Add to our collection
            recipes.append(contentsOf: uniqueRecipes)
            
            // Update caches
            for recipe in uniqueRecipes {
                recipeCache[recipe.id] = recipe
                categoryCache[recipe.category, default: []].append(recipe)
                difficultyCache[recipe.difficulty, default: []].append(recipe)
            }
        }
    }
    
    /// Remove a recipe from Core Data
    func removeRecipe(_ recipe: Recipe) {
        // Delete from CoreData
        coreDataManager.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<CDRecipe> = CDRecipe.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", recipe.id as CVarArg)
            
            do {
                let results = try context.fetch(fetchRequest)
                for object in results {
                    context.delete(object)
                }
                // Context is automatically saved by performBackgroundTask
            } catch {
                print("❌ Error deleting recipe: \(error)")
            }
        }
        
        // Remove from our collection
        recipes.removeAll { $0.id == recipe.id }
        
        // Update caches
        recipeCache.removeValue(forKey: recipe.id)
        categoryCache[recipe.category]?.removeAll { $0.id == recipe.id }
        difficultyCache[recipe.difficulty]?.removeAll { $0.id == recipe.id }
    }
    
    /// Get a recipe by ID
    func recipe(withID id: UUID) -> Recipe? {
        // Check cache first for efficiency
        if let cachedRecipe = recipeCache[id] {
            return cachedRecipe
        }
        
        // If not in cache, search the array
        return recipes.first { $0.id == id }
    }
    
    /// Get recipes by category
    func recipes(inCategory category: RecipeCategory) -> [Recipe] {
        // Check cache first for efficiency
        if let cachedRecipes = categoryCache[category] {
            return cachedRecipes
        }
        
        // If not in cache, filter the array
        return recipes.filter { $0.category == category }
    }
    
    /// Get recipes by difficulty
    func recipes(withDifficulty difficulty: RecipeDifficulty) -> [Recipe] {
        // Check cache first for efficiency
        if let cachedRecipes = difficultyCache[difficulty] {
            return cachedRecipes
        }
        
        // If not in cache, filter the array
        return recipes.filter { $0.difficulty == difficulty }
    }
    
    /// Search recipes by name
    func searchRecipes(matching query: String) -> [Recipe] {
        guard !query.isEmpty else { return recipes }
        
        let lowercasedQuery = query.lowercased()
        return recipes.filter { recipe in
            recipe.name.lowercased().contains(lowercasedQuery) ||
            recipe.ingredients.contains { $0.name.lowercased().contains(lowercasedQuery) }
        }
    }
    
    /// Build caches for efficient querying
    private func buildCaches() {
        // Clear existing caches
        recipeCache.removeAll()
        categoryCache.removeAll()
        difficultyCache.removeAll()
        
        // Build new caches
        for recipe in recipes {
            recipeCache[recipe.id] = recipe
            categoryCache[recipe.category, default: []].append(recipe)
            difficultyCache[recipe.difficulty, default: []].append(recipe)
        }
    }
    
    /// Clear all caches
    func clearCache() {
        recipeCache.removeAll()
        categoryCache.removeAll()
        difficultyCache.removeAll()
    }
} 