import Foundation
import SwiftUI
import Combine

// MARK: - Shopping List Feedback

/// Feedback for when ingredients are added to the shopping list
struct ShoppingListFeedback: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let recipeIngredientCount: Int
}

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
    @Published var recipes: [Recipe] = []
    @Published var shoppingListFeedback: ShoppingListFeedback? = nil
    
    // Add caching for performance
    private var weekDatesCache: [Date: [Date]] = [:]
    private var mealsGroupedByDateAndType: [Date: [MealType: [Meal]]] = [:]
    
    // Reference to shopping list view model for ingredient integration
    private var shoppingListViewModel: ShoppingListViewModel?
    
    // MARK: - Initialization
    
    init(shoppingListViewModel: ShoppingListViewModel? = nil) {
        self.shoppingListViewModel = shoppingListViewModel
        loadData()
    }
    
    // MARK: - Public Methods
    
    /// Load initial data including meals and recipes
    func loadData() {
        // Load recipes - in a real app, this would pull from a RecipeStore or CoreData
        self.recipes = Recipe.sampleRecipes
        
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
                            calories: recipe.nutritionalInfo?.calories,
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
    func suggestedRecipe(for mealType: MealType, limit: Int = 1) -> [Recipe] {
        // Filter recipes based on meal type
        let filteredRecipes = recipes.filter { recipe in
            // Check if recipe name contains any of the meal type keywords
            let nameMatches = mealType.associatedKeywords.contains { keyword in
                recipe.name.localizedCaseInsensitiveContains(keyword)
            }
            
            // Check if recipe category matches meal type
            let categoryMatches: Bool
            switch mealType {
            case .breakfast:
                categoryMatches = recipe.category == .breakfast
            case .lunch:
                categoryMatches = recipe.category == .lunch || recipe.category == .mainCourse
            case .dinner:
                categoryMatches = recipe.category == .dinner || recipe.category == .mainCourse
            case .snack:
                categoryMatches = recipe.category == .snack || recipe.category == .appetizer
            }
            
            return nameMatches || categoryMatches
        }
        
        // If no specific matches found, fall back to any recipes
        if filteredRecipes.isEmpty {
            return Array(recipes.prefix(limit))
        }
        
        // Return up to the limit number of recipes
        return Array(filteredRecipes.prefix(limit))
    }
    
    /// Add ingredients from a meal to the shopping list
    func addIngredientsToShoppingList(for meal: Meal) {
        guard let recipeId = meal.recipeId,
              let recipe = recipes.first(where: { $0.id == recipeId }) else { 
                return
            }
            
        let ingredientCount = recipe.ingredients.count
        
        // Check if we have a shopping list view model
        if let shoppingListViewModel = shoppingListViewModel {
            // Add each ingredient to the shopping list
            for ingredient in recipe.ingredients {
                shoppingListViewModel.addItem(
                    name: ingredient.name,
                    quantity: ingredient.amount,
                    unit: ingredient.unit.rawValue,
                    category: ingredient.category.rawValue,
                    recipe: recipe.name
                )
            }
            
            // Set feedback
            DispatchQueue.main.async {
                self.shoppingListFeedback = ShoppingListFeedback(
                    title: "Added to Shopping List",
                    message: "Added \(ingredientCount) ingredients from \(recipe.name) to your shopping list.",
                    recipeIngredientCount: ingredientCount
                )
                
                // Clear after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.shoppingListFeedback = nil
                }
            }
        } else {
            // Fallback for when no shopping list view model is available
            print("ShoppingListViewModel not available, would add these ingredients:")
            for ingredient in recipe.ingredients {
                print("- \(ingredient.name) (\(ingredient.amount) \(ingredient.unit))")
            }
        }
        
        // Provide haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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

// MARK: - Sample Recipe Data for Development
// This would typically come from a recipe database or API

extension Recipe {
    static var sampleRecipes: [Recipe] {
        // Breakfast recipes
        let avocadoToast = Recipe(
            name: "Avocado Toast",
            ingredients: [
                Ingredient(name: "Avocado", amount: 1, unit: .pieces, category: .produce),
                Ingredient(name: "Bread", amount: 2, unit: .pieces, category: .bakery),
                Ingredient(name: "Salt", amount: 1, unit: .teaspoons, category: .pantry)
            ],
            instructions: ["Toast bread", "Mash avocado", "Spread on toast", "Season with salt"],
            estimatedTime: 600, // 10 minutes
            servings: 1,
            nutritionalInfo: NutritionInfo(calories: 350, protein: 5, carbs: 30, fat: 20),
            category: .breakfast,
            prepTime: 300, // 5 minutes
            cookTime: 300  // 5 minutes
        )
        
        let yogurtParfait = Recipe(
            name: "Greek Yogurt Parfait",
            ingredients: [
                Ingredient(name: "Greek Yogurt", amount: 1, unit: .cups, category: .dairy),
                Ingredient(name: "Granola", amount: 0.5, unit: .cups, category: .pantry),
                Ingredient(name: "Berries", amount: 0.5, unit: .cups, category: .produce)
            ],
            instructions: ["Layer yogurt", "Add granola", "Top with berries"],
            estimatedTime: 300, // 5 minutes
            servings: 1,
            nutritionalInfo: NutritionInfo(calories: 280, protein: 15, carbs: 25, fat: 10),
            category: .breakfast,
            prepTime: 300, // 5 minutes
            cookTime: 0    // No cooking
        )
        
        // Lunch recipes
        let caesarSalad = Recipe(
            name: "Chicken Caesar Salad",
            ingredients: [
                Ingredient(name: "Chicken Breast", amount: 1, unit: .pieces, category: .meat),
                Ingredient(name: "Romaine Lettuce", amount: 2, unit: .cups, category: .produce),
                Ingredient(name: "Caesar Dressing", amount: 2, unit: .tablespoons, category: .pantry),
                Ingredient(name: "Parmesan Cheese", amount: 2, unit: .tablespoons, category: .dairy)
            ],
            instructions: ["Cook chicken", "Chop lettuce", "Toss with dressing", "Add cheese"],
            estimatedTime: 900, // 15 minutes
            servings: 1,
            nutritionalInfo: NutritionInfo(calories: 380, protein: 30, carbs: 10, fat: 20),
            category: .lunch,
            prepTime: 300, // 5 minutes
            cookTime: 600  // 10 minutes
        )
        
        // Dinner recipes
        let spaghetti = Recipe(
            name: "Spaghetti Bolognese",
            ingredients: [
                Ingredient(name: "Ground Beef", amount: 0.5, unit: .pounds, category: .meat),
                Ingredient(name: "Spaghetti", amount: 8, unit: .ounces, category: .pantry),
                Ingredient(name: "Tomato Sauce", amount: 2, unit: .cups, category: .pantry),
                Ingredient(name: "Onion", amount: 1, unit: .pieces, category: .produce),
                Ingredient(name: "Garlic", amount: 2, unit: .pieces, category: .produce)
            ],
            instructions: ["Cook pasta", "Brown meat", "Add sauce", "Simmer", "Combine"],
            estimatedTime: 1800, // 30 minutes
            servings: 4,
            nutritionalInfo: NutritionInfo(calories: 450, protein: 25, carbs: 40, fat: 15),
            category: .dinner,
            prepTime: 600,  // 10 minutes
            cookTime: 1200  // 20 minutes
        )
        
        // Snack recipes
        let fruitSalad = Recipe(
            name: "Fresh Fruit Salad",
            ingredients: [
                Ingredient(name: "Apple", amount: 1, unit: .pieces, category: .produce),
                Ingredient(name: "Banana", amount: 1, unit: .pieces, category: .produce),
                Ingredient(name: "Orange", amount: 1, unit: .pieces, category: .produce),
                Ingredient(name: "Honey", amount: 1, unit: .tablespoons, category: .pantry)
            ],
            instructions: ["Chop fruits", "Combine in bowl", "Drizzle with honey"],
            estimatedTime: 600, // 10 minutes
            servings: 2,
            nutritionalInfo: NutritionInfo(calories: 150, protein: 1, carbs: 35, fat: 0),
            category: .snack,
            prepTime: 600, // 10 minutes
            cookTime: 0    // No cooking
        )
        
        return [avocadoToast, yogurtParfait, caesarSalad, spaghetti, fruitSalad]
    }
} 