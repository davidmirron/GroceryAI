import Foundation
import SwiftUI

// MARK: - Type Resolution for Ambiguity
// These typealiases help resolve ambiguity with Recipe and Ingredient types
// If these models are in the main module, uncomment these lines:
// typealias RecipeModel = Recipe
// typealias IngredientModel = Ingredient
// If they're in another module, specify the correct module path

struct MealPlan: Identifiable, Codable {
    let id: String
    let dayTitle: String
    let date: Date
    var meals: [PlanMeal]
    
    init(id: String = UUID().uuidString, dayTitle: String, date: Date, meals: [PlanMeal]) {
        self.id = id
        self.dayTitle = dayTitle
        self.date = date
        self.meals = meals
    }
}

// Renamed from Meal to PlanMeal to avoid conflict with the primary Meal model
struct PlanMeal: Identifiable, Codable {
    let id: String
    let name: String
    let type: MealTypeValue
    let recipe: RecipeReference?
    
    // Avoid direct dependency on Recipe type
    init(id: String = UUID().uuidString, name: String, type: MealTypeValue, recipeReference: RecipeReference? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.recipe = recipeReference
    }
    
    // Renamed to MealTypeValue to avoid conflict with the primary MealType enum
    enum MealTypeValue: String, Codable, CaseIterable, Identifiable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
        
        var id: String { self.rawValue }
    }
}

// MARK: - Recipe Value Object
/**
 RecipeReference is a value object that decouples the MealPlan model from the Recipe model.
 This approach allows us to avoid type ambiguity issues with multiple Recipe definitions.
 */
struct RecipeReference: Identifiable, Codable {
    var id: String
    var name: String
    var estimatedTime: TimeInterval
    var servings: Int
    var difficulty: String
    var ingredients: [IngredientReference]
    
    // Create constructors with individual parameters
    init(id: String, name: String, estimatedTime: TimeInterval, servings: Int, 
         difficulty: String, ingredients: [IngredientReference]) {
        self.id = id
        self.name = name
        self.estimatedTime = estimatedTime
        self.servings = servings
        self.difficulty = difficulty
        self.ingredients = ingredients
    }
    
    // Factory method for creating from recipe information
    static func create(fromRecipeWithId id: UUID, name: String, estimatedTime: TimeInterval, 
                     servings: Int, difficulty: String) -> RecipeReference {
        return RecipeReference(
            id: id.uuidString,
            name: name,
            estimatedTime: estimatedTime,
            servings: servings,
            difficulty: difficulty,
            ingredients: []
        )
    }
}

// MARK: - Ingredient Value Object
/**
 IngredientReference serves as a value object to avoid direct dependencies on Ingredient.
 */
struct IngredientReference: Identifiable, Codable {
    var id: String
    var name: String
    var quantity: Double
    var unit: String
    var category: String
    
    // Direct constructor
    init(id: String, name: String, quantity: Double, unit: String, category: String) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
    }
} 