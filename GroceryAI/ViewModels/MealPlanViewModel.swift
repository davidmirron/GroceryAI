import Foundation
import SwiftUI
import Combine

// MARK: - Date Extensions (needed for MealPlanViewModel)
extension Date {
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let firstWeekday = calendar.firstWeekday
        
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let startOfWeek = calendar.date(from: components)!
        
        // If user's first day of week isn't Sunday, adjust accordingly
        if firstWeekday != 1 {
            let daysToSubtract = firstWeekday - 1
            return calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfWeek)!
        }
        
        return startOfWeek
    }
}

/// ViewModel for the meal planning feature
/// - Optimized performance with caching strategies
/// - Provides data and actions for the meal plan view
/// - Implements quick fill functionality
class MealPlanViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var meals: [Meal] = []
    @Published var recipes: [ViewRecipe] = []
    
    // Add caching for performance
    private var weekDatesCache: [Date: [Date]] = [:]
    private var mealsGroupedByDateAndType: [Date: [MealType: [Meal]]] = [:]
    
    // MARK: - Initialization
    
    init() {
        loadData()
    }
    
    // MARK: - Public Methods
    
    /// Load initial data including meals and recipes
    func loadData() {
        // Load recipes
        self.recipes = ViewRecipe.sampleRecipes
        
        // Load sample meals (in a real app this would be from persistent storage)
        self.meals = Meal.sampleMeals
        
        // Update the cache
        updateMealsCache()
    }
    
    /// Add a meal to the plan
    /// - Parameter meal: The meal to add
    func addMeal(_ meal: Meal) {
        meals.append(meal)
        
        // Update cache
        let dateKey = startOfDay(for: meal.date)
        if mealsGroupedByDateAndType[dateKey] == nil {
            mealsGroupedByDateAndType[dateKey] = [:]
        }
        if mealsGroupedByDateAndType[dateKey]?[meal.mealType] == nil {
            mealsGroupedByDateAndType[dateKey]?[meal.mealType] = []
        }
        mealsGroupedByDateAndType[dateKey]?[meal.mealType]?.append(meal)
    }
    
    /// Remove a meal from the plan
    /// - Parameter meal: The meal to remove
    func removeMeal(_ meal: Meal) {
        if let index = meals.firstIndex(where: { $0.id == meal.id }) {
            meals.remove(at: index)
            
            // Update cache
            updateMealsCache()
        }
    }
    
    /// Get all meals for a specific date and meal type
    /// - Parameters:
    ///   - date: The date
    ///   - type: The meal type (breakfast, lunch, etc)
    /// - Returns: Array of meals for that date and type
    func meals(for date: Date, type: MealType) -> [Meal] {
        let dateKey = startOfDay(for: date)
        return mealsGroupedByDateAndType[dateKey]?[type] ?? []
    }
    
    /// Clear all meals for a specific date
    /// - Parameter date: The date to clear
    func clearMeals(for date: Date) {
        let dateKey = startOfDay(for: date)
        let mealIdsToRemove = meals.filter { 
            Calendar.current.isDate($0.date, inSameDayAs: date) 
        }.map { $0.id }
        
        meals.removeAll { meal in
            mealIdsToRemove.contains(meal.id)
        }
        
        // Update cache
        mealsGroupedByDateAndType[dateKey] = nil
    }
    
    /// Quickly fill the week with suggested meals
    /// - Parameter startDate: The starting date for the week
    func quickFillWeek(for date: Date) {
        let weekDates = getWeekDates(from: date.startOfWeek())
        
        // Add meals for each day of the week if they don't already have meals
        for day in weekDates {
            // For each meal type
            for mealType in MealType.allCases {
                // Check if this meal type is empty for this day
                if meals(for: day, type: mealType).isEmpty {
                    // Try to find a suggested recipe
                    if let recipe = suggestedRecipe(for: mealType).first {
                        // Add meal for this recipe
                        let newMeal = Meal(
                            name: recipe.name,
                            recipeId: recipe.id,
                            date: day,
                            calories: recipe.calories,
                            mealType: mealType,
                            emoji: nil
                        )
                        
                        addMeal(newMeal)
                    }
                }
            }
        }
    }
    
    /// Get suggested recipes for a meal type
    /// - Parameter mealType: The meal type to suggest recipes for
    /// - Parameter limit: Maximum number of recipes to return
    /// - Returns: Array of suggested recipes
    func suggestedRecipe(for mealType: MealType, limit: Int = 1) -> [ViewRecipe] {
        // Filter recipes based on meal type
        let filteredRecipes = recipes.filter { recipe in
            // Check if recipe name contains any of the meal type keywords
            let nameMatches = mealType.associatedKeywords.contains { keyword in
                recipe.name.localizedCaseInsensitiveContains(keyword)
            }
            
            // Check if recipe categories match meal type
            let categoryMatches = recipe.categories.contains { category in
                category.localizedCaseInsensitiveContains(mealType.displayName)
            }
            
            return nameMatches || categoryMatches
        }
        
        // If we found matches, return them (limited by the limit parameter)
        if !filteredRecipes.isEmpty {
            return Array(filteredRecipes.prefix(limit))
        }
        
        // If no specific matches, just return random recipes
        return Array(recipes.shuffled().prefix(limit))
    }
    
    // MARK: - Helper Methods
    
    /// Generate an array of dates for a week
    /// - Parameter startDate: The starting date for the week
    /// - Returns: Array of dates for the week
    func getWeekDates(from startDate: Date) -> [Date] {
        // Check cache first
        if let cachedDates = weekDatesCache[startDate] {
            return cachedDates
        }
        
        // Not in cache, calculate dates
        let calendar = Calendar.current
        var weekDates: [Date] = []
        
        for day in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: day, to: startDate) {
                weekDates.append(date)
            }
        }
        
        // Cache for future use
        weekDatesCache[startDate] = weekDates
        
        return weekDates
    }
    
    /// Update the meals cache for better performance
    private func updateMealsCache() {
        // Clear existing cache
        mealsGroupedByDateAndType = [:]
        
        // Group meals by date and type
        for meal in meals {
            let dateKey = startOfDay(for: meal.date)
            
            if mealsGroupedByDateAndType[dateKey] == nil {
                mealsGroupedByDateAndType[dateKey] = [:]
            }
            
            if mealsGroupedByDateAndType[dateKey]?[meal.mealType] == nil {
                mealsGroupedByDateAndType[dateKey]?[meal.mealType] = []
            }
            
            mealsGroupedByDateAndType[dateKey]?[meal.mealType]?.append(meal)
        }
    }
    
    /// Get the start of the day for a date (to use as dictionary key)
    /// - Parameter date: The date
    /// - Returns: The start of the day
    private func startOfDay(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components)!
    }
}

// MARK: - ViewRecipe Struct (Used only in MealPlanViewModel)

/// Model representing a recipe in the meal planning view
struct ViewRecipe: Identifiable, Codable {
    let id: UUID
    let name: String
    let calories: Int?
    let categories: [String]
    let prepTime: Int? // In minutes
    
    init(id: UUID = UUID(), name: String, calories: Int? = nil, categories: [String] = [], prepTime: Int? = nil) {
        self.id = id
        self.name = name
        self.calories = calories
        self.categories = categories
        self.prepTime = prepTime
    }
}

// MARK: - Sample Data

extension ViewRecipe {
    static let sampleRecipes: [ViewRecipe] = [
        // Breakfast recipes
        ViewRecipe(name: "Avocado Toast", calories: 350, categories: ["Breakfast", "Quick", "Healthy"], prepTime: 10),
        ViewRecipe(name: "Greek Yogurt Parfait", calories: 280, categories: ["Breakfast", "Snack", "Healthy"], prepTime: 5),
        ViewRecipe(name: "Veggie Omelette", calories: 320, categories: ["Breakfast", "Protein", "Low Carb"], prepTime: 15),
        ViewRecipe(name: "Oatmeal with Berries", calories: 290, categories: ["Breakfast", "Fiber", "Heart Healthy"], prepTime: 10),
        ViewRecipe(name: "Banana Pancakes", calories: 420, categories: ["Breakfast", "Sweet", "Weekend"], prepTime: 20),
        
        // Lunch recipes
        ViewRecipe(name: "Chicken Caesar Salad", calories: 380, categories: ["Lunch", "Salad", "High Protein"], prepTime: 15),
        ViewRecipe(name: "Quinoa Bowl", calories: 410, categories: ["Lunch", "Dinner", "Vegetarian"], prepTime: 25),
        ViewRecipe(name: "Tuna Sandwich", calories: 340, categories: ["Lunch", "Sandwich", "Quick"], prepTime: 10),
        ViewRecipe(name: "Mediterranean Wrap", calories: 380, categories: ["Lunch", "Wraps", "Healthy"], prepTime: 12),
        ViewRecipe(name: "Lentil Soup", calories: 310, categories: ["Lunch", "Soup", "Vegetarian"], prepTime: 30),
        
        // Dinner recipes
        ViewRecipe(name: "Grilled Salmon", calories: 450, categories: ["Dinner", "Seafood", "High Protein"], prepTime: 25),
        ViewRecipe(name: "Vegetable Stir Fry", calories: 380, categories: ["Dinner", "Asian", "Vegetarian"], prepTime: 30),
        ViewRecipe(name: "Spaghetti Bolognese", calories: 520, categories: ["Dinner", "Pasta", "Family"], prepTime: 40),
        ViewRecipe(name: "Chicken Curry", calories: 490, categories: ["Dinner", "Spicy", "International"], prepTime: 45),
        ViewRecipe(name: "Beef Tacos", calories: 480, categories: ["Dinner", "Mexican", "Family"], prepTime: 30),
        
        // Snack recipes
        ViewRecipe(name: "Fruit Smoothie", calories: 220, categories: ["Snack", "Breakfast", "Quick"], prepTime: 5),
        ViewRecipe(name: "Hummus with Vegetables", calories: 180, categories: ["Snack", "Healthy", "Vegetarian"], prepTime: 5),
        ViewRecipe(name: "Trail Mix", calories: 250, categories: ["Snack", "Nuts", "Energy"], prepTime: 2),
        ViewRecipe(name: "Apple with Peanut Butter", calories: 200, categories: ["Snack", "Fruit", "Quick"], prepTime: 2),
        ViewRecipe(name: "Protein Bar", calories: 230, categories: ["Snack", "Protein", "On-the-go"], prepTime: 0)
    ]
} 