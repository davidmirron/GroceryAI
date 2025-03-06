import Foundation
import SwiftUI

/// Represents a curated collection of recipes with a theme
struct RecipeCollection: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let recipeIds: [UUID]
    let featured: Bool
    let emoji: String
    let colorHex: String
    
    init(id: UUID = UUID(), 
         name: String, 
         description: String, 
         recipeIds: [UUID] = [], 
         featured: Bool = false,
         emoji: String = "🍽️",
         colorHex: String = "#007AFF") {
        self.id = id
        self.name = name
        self.description = description
        self.recipeIds = recipeIds
        self.featured = featured
        self.emoji = emoji
        self.colorHex = colorHex
    }
    
    // Get a color from the hex string
    var color: Color {
        Color(hex: colorHex)
    }
}

// MARK: - Sample Collections
extension RecipeCollection {
    /// Returns a list of predefined collections for the MVP
    static func sampleCollections() -> [RecipeCollection] {
        [
            RecipeCollection(
                name: "Quick Weeknight Meals", 
                description: "Dinner on the table in 30 minutes or less", 
                featured: true,
                emoji: "⏱️",
                colorHex: "#FF9500"
            ),
            
            RecipeCollection(
                name: "Healthy Options", 
                description: "Nutritious and delicious recipes", 
                emoji: "🥗",
                colorHex: "#34C759"
            ),
            
            RecipeCollection(
                name: "Breakfast Favorites", 
                description: "Start your day right with these delicious breakfast recipes", 
                emoji: "🍳",
                colorHex: "#FF3B30"
            ),
            
            RecipeCollection(
                name: "Vegetarian Dishes", 
                description: "Flavorful meat-free meals everyone will enjoy", 
                emoji: "🥬",
                colorHex: "#30D158"
            ),
            
            RecipeCollection(
                name: "Comfort Food", 
                description: "Hearty, satisfying recipes for when you need some comfort", 
                emoji: "🍲",
                colorHex: "#BF5AF2"
            ),
            
            RecipeCollection(
                name: "Desserts & Treats", 
                description: "Indulgent sweets to satisfy your cravings", 
                emoji: "🍰",
                colorHex: "#FF375F"
            ),
            
            RecipeCollection(
                name: "Party Favorites", 
                description: "Crowd-pleasing recipes perfect for entertaining", 
                emoji: "🎉",
                colorHex: "#5E5CE6"
            )
        ]
    }
} 