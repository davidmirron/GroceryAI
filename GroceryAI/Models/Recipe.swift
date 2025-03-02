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
    
    init(id: UUID = UUID(), 
         name: String, 
         ingredients: [Ingredient], 
         instructions: [String], 
         estimatedTime: TimeInterval, 
         servings: Int, 
         nutritionalInfo: NutritionInfo? = nil, 
         missingIngredients: [Ingredient] = [],
         dietaryTags: Set<DietaryTag> = []) {
        
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
        self.estimatedTime = estimatedTime
        self.servings = servings
        self.nutritionalInfo = nutritionalInfo
        self.missingIngredients = missingIngredients
        self.dietaryTags = dietaryTags
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