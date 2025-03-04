import Foundation

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
    let imageName: String? // New property for storing image name
    var matchScore: Double = 0.0 // Match score for sorting recipes
    var isCustomRecipe: Bool = false // Track whether this is a user-created recipe
    
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
         isCustomRecipe: Bool = false) {
        
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