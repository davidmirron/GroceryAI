import Foundation

struct MealPlan: Identifiable {
    let id: UUID
    let dayTitle: String
    let date: Date
    let meals: [Meal]
    
    init(id: UUID = UUID(), dayTitle: String, date: Date, meals: [Meal]) {
        self.id = id
        self.dayTitle = dayTitle
        self.date = date
        self.meals = meals
    }
}

struct Meal: Identifiable {
    let id: UUID
    let name: String
    let type: MealType
    let recipe: RecipeReference?
    
    init(id: UUID = UUID(), name: String, type: MealType, recipe: RecipeReference? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.recipe = recipe
    }
    
    enum MealType: String {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
    }
}

// Simple reference to a recipe to avoid ambiguity
struct RecipeReference: Identifiable {
    var id: UUID
    var name: String
} 