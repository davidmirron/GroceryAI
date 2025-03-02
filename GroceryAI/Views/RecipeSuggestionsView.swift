import SwiftUI

struct RecipeSuggestionsView: View {
    @State private var suggestions: [RecipeSuggestion] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if suggestions.isEmpty {
                    ContentUnavailableView {
                        Label("No Recipes", systemImage: "fork.knife")
                    } description: {
                        Text("Add ingredients to your grocery list to get recipe suggestions")
                    }
                } else {
                    ForEach(suggestions) { suggestion in
                        // Convert RecipeSuggestion to RecipeCardView format
                        RecipeCardView(
                            title: suggestion.name,
                            emoji: suggestion.emoji ?? "🍽️",
                            time: "\(suggestion.cookingTime) mins",
                            servings: "\(suggestion.servings) servings",
                            missingItems: suggestion.missingIngredients ?? []
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Recipe Suggestions")
    }
}

// Renamed to avoid conflicts with Recipe elsewhere in the app
struct RecipeSuggestion: Identifiable, Codable {
    var id = UUID()
    var name: String
    var ingredients: [String]
    var instructions: [String]
    var cookingTime: Int
    var servings: Int
    var emoji: String?
    var missingIngredients: [String]?
    
    var difficulty: RecipeDifficulty = .medium
    
    enum RecipeDifficulty: String, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
}

// Renamed to avoid conflicts with RecipeCard in RecipesView.swift
struct RecipeCardView: View {
    let title: String
    let emoji: String
    let time: String
    let servings: String
    let missingItems: [String]
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryLight)
                    .frame(width: 80, height: 80)
                
                Text(emoji)
                    .font(.system(size: 40))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.text)
                
                HStack(spacing: 16) {
                    Text(time)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                    
                    Text(servings)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                if missingItems.isEmpty {
                    Text("You have all ingredients!")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.top, 4)
                } else {
                    Text("Missing: \(missingItems.joined(separator: ", "))")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.top, 4)
                }
            }
            .padding(16)
        }
        .background(AppTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: AppTheme.primary.opacity(0.1), radius: 6, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.primary.opacity(0.08), lineWidth: 1)
        )
    }
} 