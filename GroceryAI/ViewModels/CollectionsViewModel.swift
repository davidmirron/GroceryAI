import Foundation
import SwiftUI
import Combine

/// ViewModel for managing recipe collections
class CollectionsViewModel: ObservableObject {
    /// The recipe collections
    @Published var collections: [RecipeCollection] = []
    
    /// All populated collections with their recipes
    @Published var populatedCollections: [PopulatedCollection] = []
    
    /// Flag indicating if data is loading
    @Published var isLoading = false
    
    /// Reference to the recipe list view model
    private let recipeListViewModel: RecipeListViewModel
    
    /// Cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Initialize with a recipe list view model
    init(recipeListViewModel: RecipeListViewModel) {
        self.recipeListViewModel = recipeListViewModel
        
        // Load the initial collections
        setupCollections()
        
        // Subscribe to recipe changes
        recipeListViewModel.$recipes
            .sink { [weak self] _ in
                self?.populateCollections()
            }
            .store(in: &cancellables)
    }
    
    /// Set up initial collections from sample data
    private func setupCollections() {
        collections = RecipeCollection.sampleCollections()
        populateCollections()
    }
    
    /// Populate collections with recipes
    func populateCollections() {
        isLoading = true
        
        // Convert the collections to populated collections
        populatedCollections = collections.map { collection in
            // Find recipes that should be in this collection
            let recipes = findRecipesForCollection(collection)
            return PopulatedCollection(collection: collection, recipes: recipes)
        }
        
        isLoading = false
    }
    
    /// Find recipes that should be in a specific collection
    private func findRecipesForCollection(_ collection: RecipeCollection) -> [Recipe] {
        let allRecipes = recipeListViewModel.recipes
        
        // If there are specific recipe IDs, use those
        if !collection.recipeIds.isEmpty {
            return allRecipes.filter { collection.recipeIds.contains($0.id) }
        }
        
        // Otherwise, use collection-specific logic
        switch collection.name {
        case "Quick Weeknight Meals":
            // Recipes that take less than 30 minutes
            return allRecipes.filter { $0.estimatedTime <= 30 * 60 }
            
        case "Healthy Options":
            // Low-calorie recipes or those with certain dietary tags
            return allRecipes.filter { recipe in
                let isLowCalorie = recipe.nutritionalInfo?.calories ?? 0 < 500
                let hasHealthyTag = recipe.dietaryTags.contains { tag in
                    ["vegetarian", "vegan", "glutenFree", "lowCarb"].contains(tag.rawValue)
                }
                return isLowCalorie || hasHealthyTag
            }
            
        case "Breakfast Favorites":
            // Breakfast category or breakfast-related names
            return allRecipes.filter { recipe in
                recipe.category == .breakfast || 
                ["breakfast", "pancake", "waffle", "egg", "muffin", "toast"].contains { 
                    recipe.name.lowercased().contains($0) 
                }
            }
            
        case "Vegetarian Dishes":
            // Vegetarian or vegan recipes
            return allRecipes.filter { recipe in
                recipe.dietaryTags.contains { $0 == .vegetarian || $0 == .vegan }
            }
            
        case "Comfort Food":
            // Comfort food categories
            return allRecipes.filter { recipe in
                ["pasta", "soup", "stew", "casserole", "mac", "cheese", "pot pie", "pizza"].contains { 
                    recipe.name.lowercased().contains($0) 
                }
            }
            
        case "Desserts & Treats":
            // Dessert category or dessert keywords
            return allRecipes.filter { recipe in
                recipe.category == .dessert || 
                ["dessert", "cake", "cookie", "pie", "ice cream", "sweet", "chocolate"].contains { 
                    recipe.name.lowercased().contains($0) 
                }
            }
            
        case "Party Favorites":
            // Appetizers or party snacks
            return allRecipes.filter { recipe in
                recipe.category == .appetizer || recipe.category == .snack ||
                ["dip", "finger food", "nachos", "wings", "bite"].contains { 
                    recipe.name.lowercased().contains($0) 
                }
            }
            
        default:
            // For unknown collections, return an empty array
            return []
        }
    }
    
    /// Find similar recipes to a given recipe
    func findSimilarRecipes(to recipe: Recipe, limit: Int = 5) -> [Recipe] {
        let allRecipes = recipeListViewModel.recipes
        
        // Skip the original recipe
        let candidates = allRecipes.filter { $0.id != recipe.id }
        
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
}

/// A recipe collection populated with its recipes
struct PopulatedCollection: Identifiable {
    let collection: RecipeCollection
    let recipes: [Recipe]
    
    var id: UUID { collection.id }
    var name: String { collection.name }
    var description: String { collection.description }
    var featured: Bool { collection.featured }
    var emoji: String { collection.emoji }
    var color: Color { collection.color }
} 