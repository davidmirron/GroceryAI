import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var showingAddToListConfirmation = false
    
    var body: some View {
        // Break down the complex ScrollView into smaller components
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header section
                recipeHeaderSection
                
                // Ingredients section
                ingredientsSection
                
                // Instructions section
                instructionsSection
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                addToListButton
            }
        }
        .alert("Added to Shopping List", isPresented: $showingAddToListConfirmation) {
            Button("OK", role: .cancel) { }
        }
    }
    
    // MARK: - View Components
    
    // Recipe header with image and basic info
    private var recipeHeaderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Recipe image
            recipeImage
            
            // Recipe basic info (time, servings, etc.)
            recipeInfoRow
        }
    }
    
    // Recipe image
    private var recipeImage: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(16/9, contentMode: .fit)
                .cornerRadius(12)
            
            Text("🍲")
                .font(.system(size: 72))
        }
    }
    
    // Recipe info row (time, servings, etc.)
    private var recipeInfoRow: some View {
        HStack(spacing: 16) {
            let cookingTime = formatTime(recipe.estimatedTime)
            
            RecipeInfoItem(systemImage: "clock", text: cookingTime)
            RecipeInfoItem(systemImage: "person.2", text: "\(recipe.servings) servings")
            RecipeInfoItem(systemImage: "flame", text: "Medium")
        }
    }
    
    // Ingredients section
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.title2)
                .fontWeight(.bold)
            
            // Break down the ingredient list into a separate ForEach
            ForEach(recipe.ingredients, id: \.id) { ingredient in
                RecipeIngredientRow(ingredient: ingredient)
            }
        }
    }
    
    // Instructions section
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
                .font(.title2)
                .fontWeight(.bold)
            
            // Break down the instructions list into a separate ForEach
            ForEach(Array(recipe.instructions.enumerated()), id: \.element) { index, instruction in
                instructionRow(index: index + 1, instruction: instruction)
            }
        }
    }
    
    // Single instruction row
    private func instructionRow(index: Int, instruction: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(AppTheme.primary)
                .clipShape(Circle())
            
            Text(instruction)
                .foregroundColor(AppTheme.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 4)
        }
    }
    
    // Add to list button
    private var addToListButton: some View {
        Button {
            addIngredientsToShoppingList()
            showingAddToListConfirmation = true
        } label: {
            Text("Add to List")
        }
    }
    
    // MARK: - Supporting Functions
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours) hr \(remainingMinutes) min"
        }
    }
    
    private func addIngredientsToShoppingList() {
        for ingredient in recipe.ingredients {
            viewModel.addItem(ingredient)
        }
    }
}

// MARK: - Supporting Views

// Single ingredient row
struct RecipeIngredientRow: View {
    let ingredient: Ingredient
    
    var body: some View {
        HStack {
            Text("•")
                .foregroundColor(AppTheme.primary)
                .font(.headline)
            
            // Format the amount and unit
            let formattedAmount = formatAmount(ingredient.amount)
            let unitText = ingredient.unit.rawValue
            
            Text("\(formattedAmount) \(unitText) \(ingredient.name)")
                .foregroundColor(AppTheme.text)
        }
        .padding(.vertical, 4)
    }
    
    // Simplified amount formatting
    private func formatAmount(_ value: Double) -> String {
        if value == floor(value) {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// Recipe info item (used in the info row)
struct RecipeInfoItem: View {
    let systemImage: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundColor(AppTheme.primary)
            
            Text(text)
                .foregroundColor(AppTheme.text)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(AppTheme.cardBackground)
        .cornerRadius(8)
    }
} 