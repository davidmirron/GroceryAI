import Foundation

/// Model representing a custom meal created by the user
/// - A standardized data structure for user-created meals
/// - Includes ID, name, emoji and optional calorie count
struct CustomMeal: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let emoji: String
    let calories: Int?
    let mealType: MealType
    let createdDate: Date
    
    init(id: UUID = UUID(), name: String, emoji: String, calories: Int? = nil, mealType: MealType, createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.calories = calories
        self.mealType = mealType
        self.createdDate = createdDate
    }
}

// MARK: - Sample Data

extension CustomMeal {
    static let sampleData: [CustomMeal] = [
        CustomMeal(
            name: "Protein Shake",
            emoji: "🥤",
            calories: 180,
            mealType: .breakfast
        ),
        CustomMeal(
            name: "Coffee",
            emoji: "☕️",
            calories: 5,
            mealType: .breakfast
        ),
        CustomMeal(
            name: "Greek Yogurt",
            emoji: "🥣",
            calories: 150,
            mealType: .snack
        ),
        CustomMeal(
            name: "Turkey Sandwich",
            emoji: "🥪",
            calories: 350,
            mealType: .lunch
        ),
        CustomMeal(
            name: "Mixed Salad",
            emoji: "🥗",
            calories: 120,
            mealType: .dinner
        )
    ]
} 