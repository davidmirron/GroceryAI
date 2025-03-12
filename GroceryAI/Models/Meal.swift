import Foundation

/// Model representing a meal in the meal plan
/// - Can be either a recipe-based meal or a custom meal
/// - Includes ID, name, date, meal type, and optional calories and emoji
struct Meal: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let recipeId: UUID?  // Nil for custom meals
    let date: Date
    let calories: Int?
    let mealType: MealType
    let emoji: String?   // Only used for custom meals
    
    var isCustomMeal: Bool {
        recipeId == nil
    }
    
    init(id: UUID = UUID(), name: String, recipeId: UUID?, date: Date, calories: Int?, mealType: MealType, emoji: String?) {
        self.id = id
        self.name = name
        self.recipeId = recipeId
        self.date = date
        self.calories = calories
        self.mealType = mealType
        self.emoji = emoji
    }
}

// MARK: - Sample Data

extension Meal {
    static let sampleBreakfast: [Meal] = [
        Meal(
            name: "Oatmeal with Berries",
            recipeId: UUID(),
            date: Date(),
            calories: 320,
            mealType: .breakfast,
            emoji: nil
        ),
        Meal(
            name: "Coffee",
            recipeId: nil,
            date: Date(),
            calories: 5,
            mealType: .breakfast,
            emoji: "☕️"
        )
    ]
    
    static let sampleLunch: [Meal] = [
        Meal(
            name: "Turkey Sandwich",
            recipeId: UUID(),
            date: Date(),
            calories: 450,
            mealType: .lunch,
            emoji: nil
        ),
        Meal(
            name: "Apple",
            recipeId: nil,
            date: Date(),
            calories: 95,
            mealType: .lunch,
            emoji: "🍎"
        )
    ]
    
    static let sampleDinner: [Meal] = [
        Meal(
            name: "Salmon with Roasted Vegetables",
            recipeId: UUID(),
            date: Date(),
            calories: 550,
            mealType: .dinner,
            emoji: nil
        )
    ]
    
    static let sampleSnacks: [Meal] = [
        Meal(
            name: "Greek Yogurt",
            recipeId: nil,
            date: Date(),
            calories: 150,
            mealType: .snack,
            emoji: "🥣"
        )
    ]
    
    static var sampleMeals: [Meal] {
        sampleBreakfast + sampleLunch + sampleDinner + sampleSnacks
    }
} 