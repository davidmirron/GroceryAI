import Foundation
import SwiftUI

class Recipe: Identifiable, ObservableObject {
    @Published var ingredients: [Ingredient]
    let id: UUID
    let name: String
    let instructions: [String]
    let estimatedTime: TimeInterval // in seconds
    let servings: Int
    let nutritionalInfo: NutritionInfo?  // Renamed to avoid ambiguity
    @Published var missingIngredients: [Ingredient]
    var dietaryTags: Set<DietaryTag> = []
    var imageName: String? // New property for storing image name
    var matchScore: Double = 0.0 // Match score for sorting recipes
    var isCustomRecipe: Bool = false // Track whether this is a user-created recipe
    var category: RecipeCategory = .other // Category of the recipe
    var difficulty: RecipeDifficulty = .medium // Difficulty level of the recipe
    var prepTime: TimeInterval = 0 // Preparation time in seconds
    var cookTime: TimeInterval = 0 // Cooking time in seconds
    var source: String? // Source of the recipe (e.g., cookbook, website, family)
    
    init(id: UUID = UUID(), 
         name: String, 
         ingredients: [Ingredient], 
         instructions: [String], 
         estimatedTime: TimeInterval, 
         servings: Int, 
         nutritionalInfo: NutritionInfo? = nil, 
         missingIngredients: [Ingredient] = [],
         dietaryTags: Set<DietaryTag> = [],
         imageName: String? = nil,
         matchScore: Double = 0.0,
         isCustomRecipe: Bool = false,
         category: RecipeCategory = .other,
         difficulty: RecipeDifficulty = .medium,
         prepTime: TimeInterval = 0,
         cookTime: TimeInterval = 0,
         source: String? = nil) {
        
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
        self.estimatedTime = estimatedTime
        self.servings = servings
        self.nutritionalInfo = nutritionalInfo
        self.missingIngredients = missingIngredients
        self.dietaryTags = dietaryTags
        self.imageName = imageName
        self.matchScore = matchScore
        self.isCustomRecipe = isCustomRecipe
        self.category = category
        self.difficulty = difficulty
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.source = source
    }
    
    enum DietaryTag: String, CaseIterable {
        case vegetarian
        case vegan
        case glutenFree = "Gluten-Free"
        case dairyFree = "Dairy-Free"
        case lowCarb = "Low-Carb"
        case keto
        case paleo
    }
}

// Recipe categories
enum RecipeCategory: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case appetizer = "Appetizer"
    case sideDish = "Side Dish"
    case dessert = "Dessert"
    case snack = "Snack"
    case mainCourse = "Main Course"
    case salad = "Salad"
    case soup = "Soup"
    case beverage = "Beverage"
    case other = "Other"
}

// Recipe difficulty levels
enum RecipeDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

// Filter options for recipe suggestions
enum RecipeFilter: String, CaseIterable {
    // Original filters
    case all = "All"
    case vegetarian = "Vegetarian"
    case quickMeals = "Quick Meals"
    case glutenFree = "Gluten Free"
    case lowCarb = "Low Carb"
    
    // Category-based filters
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case dessert = "Dessert"
    case mainCourse = "Main Course"
    
    // Difficulty filters
    case easyRecipes = "Easy Recipes"
    
    // Time-based filters
    case under30Min = "Under 30 Minutes"
    
    // New dietary filters
    case dairyFree = "Dairy Free"
    case vegan = "Vegan"
    case keto = "Keto"
    
    // Advanced filters
    case favorited = "Favorites"
    case popular = "Popular"
    case seasonal = "Seasonal"
    
    // Discovery filters (curated collections)
    case weeknightDinners = "Weeknight Dinners"
    case comfortFood = "Comfort Food"
    case healthyOptions = "Healthy Options"
    case partyFood = "Party Food"
    
    // Helper property to get icon for each filter
    var iconName: String {
        switch self {
        case .all:
            return "square.grid.2x2"
        case .vegetarian:
            return "leaf"
        case .quickMeals:
            return "timer"
        case .glutenFree:
            return "allergens"
        case .lowCarb:
            return "chart.bar.fill"
        case .breakfast:
            return "sunrise"
        case .lunch:
            return "sun.max"
        case .dinner:
            return "moon.stars"
        case .dessert:
            return "birthday.cake"
        case .mainCourse:
            return "fork.knife"
        case .easyRecipes:
            return "tortoise"
        case .under30Min:
            return "clock"
        case .dairyFree:
            return "drop.triangle"
        case .vegan:
            return "leaf.fill"
        case .keto:
            return "k.circle"
        case .favorited:
            return "heart.fill"
        case .popular:
            return "flame"
        case .seasonal:
            return "calendar"
        case .weeknightDinners:
            return "clock.badge.checkmark"
        case .comfortFood:
            return "house"
        case .healthyOptions:
            return "heart.text.square"
        case .partyFood:
            return "party.popper"
        }
    }
    
    // Helper property to get color for each filter
    var color: Color {
        switch self {
        case .all:
            return .gray
        case .vegetarian, .vegan:
            return .green
        case .quickMeals, .under30Min:
            return .blue
        case .glutenFree, .dairyFree, .keto, .lowCarb:
            return .orange
        case .breakfast:
            return .yellow
        case .lunch:
            return .orange
        case .dinner, .mainCourse:
            return .purple
        case .dessert:
            return .pink
        case .easyRecipes:
            return .mint
        case .favorited:
            return .red
        case .popular:
            return .orange
        case .seasonal:
            return .indigo
        case .weeknightDinners:
            return Color(hex: "#FF9500")
        case .comfortFood:
            return Color(hex: "#BF5AF2")
        case .healthyOptions:
            return Color(hex: "#30D158")
        case .partyFood:
            return Color(hex: "#5E5CE6")
        }
    }
    
    // Helper property to get an emoji for each filter
    var emoji: String {
        switch self {
        case .weeknightDinners:
            return "⏱️"
        case .comfortFood:
            return "🍲"
        case .healthyOptions:
            return "🥗"
        case .partyFood:
            return "🎉"
        default:
            return ""
        }
    }
    
    // Helper property to get a description for discovery filters
    var description: String? {
        switch self {
        case .weeknightDinners:
            return "Quick and easy meals for busy weeknights"
        case .comfortFood:
            return "Hearty, satisfying recipes for when you need some comfort"
        case .healthyOptions:
            return "Nutritious and delicious recipes to feel good about"
        case .partyFood:
            return "Crowd-pleasing recipes perfect for entertaining"
        default:
            return nil
        }
    }
}

// Renamed to avoid ambiguity
struct NutritionInfo {
    let calories: Int
    let protein: Int // in grams
    let carbs: Int // in grams
    let fat: Int // in grams
}

struct PantryPrediction {
    let ingredient: Ingredient
    let confidence: Double // 0.0 to 1.0
}

// MARK: - Filtering Extensions
extension Array where Element == Recipe {
    /// Filter recipes by a specific RecipeFilter without affecting their categorization
    func filtered(by filter: RecipeFilter) -> [Recipe] {
        guard filter != .all else { return self }
        
        return self.filter { recipe in
            switch filter {
            // Dietary filters
            case .vegetarian:
                return recipe.dietaryTags.contains(.vegetarian)
            case .quickMeals:
                return recipe.estimatedTime <= 1800
            case .glutenFree:
                return recipe.dietaryTags.contains(.glutenFree)
            case .lowCarb:
                return recipe.dietaryTags.contains(.lowCarb)
            
            // Category-based filters
            case .breakfast:
                return recipe.category == .breakfast
            case .lunch:
                return recipe.category == .lunch
            case .dinner:
                return recipe.category == .dinner
            case .dessert:
                return recipe.category == .dessert
            case .mainCourse:
                return recipe.category == .mainCourse
            
            // Difficulty filters
            case .easyRecipes:
                return recipe.difficulty == .easy
            
            // Time-based filters
            case .under30Min:
                return recipe.estimatedTime <= 1800
            
            // New dietary filters
            case .dairyFree:
                return recipe.dietaryTags.contains(.dairyFree)
            case .vegan:
                return recipe.dietaryTags.contains(.vegan)
            case .keto:
                return recipe.dietaryTags.contains(.keto)
            
            // Advanced filters
            case .favorited:
                return recipe.isCustomRecipe
            case .popular:
                return recipe.matchScore >= 0.8
            case .seasonal:
                return self.prefix(5).contains(where: { $0.id == recipe.id })
                
            // Discovery filters
            case .weeknightDinners:
                let quickTime = recipe.estimatedTime <= 30 * 60
                let dinnerCategory = recipe.category == .dinner || recipe.category == .mainCourse
                return quickTime && dinnerCategory
            
            case .comfortFood:
                let name = recipe.name.lowercased()
                return ["pasta", "soup", "stew", "casserole", "mac", "cheese", "pie", "pizza", 
                        "burger", "pot roast", "chili", "meatloaf", "fried"].contains { 
                    name.contains($0) 
                }
            
            case .healthyOptions:
                let healthyDiet = recipe.dietaryTags.contains { 
                    [.vegetarian, .vegan, .glutenFree, .lowCarb].contains($0) 
                }
                let lowCalorie = recipe.nutritionalInfo?.calories ?? 0 < 500
                let name = recipe.name.lowercased()
                let healthyKeywords = ["salad", "grilled", "roasted", "steamed", "baked", "healthy", 
                                    "veggie", "vegetable", "lean", "light"].contains {
                    name.contains($0)
                }
                return healthyDiet || lowCalorie || healthyKeywords
            
            case .partyFood:
                let partyCategory = recipe.category == .appetizer || recipe.category == .snack
                let name = recipe.name.lowercased()
                let partyKeywords = ["dip", "finger", "bite", "nachos", "wings", "mini", "slider", 
                                "cocktail", "party", "platter", "skewer", "canape"].contains {
                    name.contains($0)
                }
                return partyCategory || partyKeywords
            
            // Default case
            case .all:
                return true
            }
        }
    }
    
    /// Filter recipes by search text
    func filtered(bySearchText searchText: String) -> [Recipe] {
        guard !searchText.isEmpty else { return self }
        
        let searchTerms = searchText.lowercased().split(separator: " ")
        
        return self.filter { recipe in
            // Check if all search terms are found in any of these fields
            let recipeText = "\(recipe.name) \(recipe.category.rawValue) \(recipe.difficulty.rawValue) \(recipe.dietaryTags.map { $0.rawValue }.joined(separator: " "))".lowercased()
            
            // Each search term must be found
            return searchTerms.allSatisfy { term in
                recipeText.contains(term)
            }
        }
    }
} 