import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @ObservedObject var viewModel: ShoppingListViewModel
    @ObservedObject var recipesViewModel: RecipesViewModel
    @State private var showingAddToListConfirmation = false
    @State private var showingSaveConfirmation = false
    @State private var scale: CGFloat = 1.0
    
    // Helper to determine appropriate emoji for recipe type
    private var recipeEmoji: String {
        let name = recipe.name.lowercased()
        
        if name.contains("pancake") {
            return "🥞"
        } else if name.contains("salad") {
            return "🥗"
        } else if name.contains("pasta") || name.contains("spaghetti") {
            return "🍝"
        } else if name.contains("cookie") {
            return "🍪"
        } else if name.contains("curry") {
            return "🍛"
        } else if name.contains("taco") {
            return "🌮"
        } else if name.contains("bread") || name.contains("banana") {
            return "🍞"
        } else if name.contains("stir fry") {
            return "🥘"
        } else if name.contains("chili") {
            return "🌶️"
        } else {
            return "🍲"
        }
    }
    
    var body: some View {
        // Break down the complex ScrollView into smaller components
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header section
                recipeHeaderSection
                
                // Action buttons section
                actionButtonsSection
                
                // Dietary tags if present
                if !recipe.dietaryTags.isEmpty {
                    dietaryTagsSection
                }
                
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
                Menu {
                    Button(action: addIngredientsToShoppingList) {
                        Label("Add to Shopping List", systemImage: "cart.badge.plus")
                    }
                    
                    Button(action: saveRecipe) {
                        Label("Save Recipe", systemImage: "bookmark")
                    }
                    
                    // Add sharing button in the future
                    Button(action: {}) {
                        Label("Share Recipe", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white)
                }
            }
        }
        .alert("Added to Shopping List", isPresented: $showingAddToListConfirmation) {
            Button("OK", role: .cancel) { }
        }
        .alert("Recipe Saved", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) { }
        }
    }
    
    // MARK: - View Components
    
    // Recipe header with image and basic info
    private var recipeHeaderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Recipe image
            recipeImage
            
            // Recipe name
            Text(recipe.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.text)
            
            // Recipe basic info (time, servings, etc.)
            recipeInfoRow
        }
    }
    
    // Recipe image
    private var recipeImage: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(
                    colors: [AppTheme.primary.opacity(0.1), AppTheme.secondary.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .aspectRatio(16/9, contentMode: .fit)
                .cornerRadius(16)
            
            if let imageName = recipe.imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)
                    .clipped()
            } else {
                Text(recipeEmoji)
                    .font(.system(size: 80))
                    .scaleEffect(scale)
                    .onAppear {
                        // Add a subtle animation to the emoji
                        withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            scale = 1.05
                        }
                    }
            }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Action buttons section
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            // Add to list button
            Button(action: addIngredientsToShoppingList) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("Add to List")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            // Save recipe button
            Button(action: saveRecipe) {
                HStack {
                    Image(systemName: "bookmark")
                    Text("Save Recipe")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.secondary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    // Dietary tags section
    private var dietaryTagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dietary Tags")
                .font(.headline)
                .foregroundColor(AppTheme.text)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(recipe.dietaryTags), id: \.self) { tag in
                        Text(tag.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(AppTheme.primary.opacity(0.1))
                            .foregroundColor(AppTheme.primary)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    // Recipe info row (time, servings, etc.)
    private var recipeInfoRow: some View {
        HStack(spacing: 16) {
            let cookingTime = formatTime(recipe.estimatedTime)
            
            RecipeInfoItem(systemImage: "clock", text: cookingTime)
            RecipeInfoItem(systemImage: "person.2", text: "\(recipe.servings) servings")
            
            if let nutrition = recipe.nutritionalInfo {
                RecipeInfoItem(systemImage: "flame", text: "\(nutrition.calories) cal")
            } else {
                RecipeInfoItem(systemImage: "flame", text: "Medium")
            }
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
        showingAddToListConfirmation = true
        
        // Haptic feedback on add
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func saveRecipe() {
        recipesViewModel.addToRecipeList(recipe)
        showingSaveConfirmation = true
        
        // Haptic feedback on save
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
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
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.subheadline)
            
            Text(text)
                .font(.subheadline)
        }
        .foregroundColor(AppTheme.textSecondary)
    }
} 