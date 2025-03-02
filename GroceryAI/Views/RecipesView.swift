import SwiftUI

struct RecipesView: View {
    @StateObject private var recipesViewModel = RecipesViewModel()
    @StateObject private var shoppingListViewModel = ShoppingListViewModel()
    @State private var isRefreshing = false
    @State private var showingRecipeList = false
    
    // Add parameter to accept ingredients from ShoppingListView
    var ingredients: [Ingredient]
    
    // Add initializer with default empty array
    init(ingredients: [Ingredient] = []) {
        self.ingredients = ingredients
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if recipesViewModel.isLoading {
                    ProgressView("Generating recipe suggestions...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                } else {
                    // Recipes that can be made with current shopping list
                    Text("With Your Current List")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    if recipesViewModel.recipes.isEmpty {
                        Text("No recipes available based on your current list")
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        // Show recipes from view model instead of hardcoded ones
                        ForEach(recipesViewModel.recipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: shoppingListViewModel)) {
                                RecipeCard(
                                    recipe: recipe,
                                    onAddToList: { addMissingIngredients(from: recipe) }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    // All recipes section
                    Text("Browse All Recipes")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    NavigationLink(destination: RecipeListView()) {
                        Text("View All Recipes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .navigationTitle("What You Can Make")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("What You Can Make")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    refreshRecipes()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.white)
                }
                .disabled(isRefreshing)
            }
        }
        .toolbarBackground(AppTheme.primaryGradient, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .background(AppTheme.backgroundGreen)
        .onAppear {
            // Load recipes on view appear if needed
            if recipesViewModel.recipes.isEmpty {
                refreshRecipes()
            }
        }
    }
    
    private func refreshRecipes() {
        isRefreshing = true
        // In a real app, we'd get current ingredients from shopping list
        recipesViewModel.generateRecipes(from: ingredients)
        
        // Simulate loading to improve UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isRefreshing = false
        }
    }
    
    private func addMissingIngredients(from recipe: Recipe) {
        for ingredient in recipe.missingIngredients {
            shoppingListViewModel.addItem(ingredient)
        }
    }
}

// Updated RecipeCard to work with our Recipe model
struct RecipeCard: View {
    let recipe: Recipe
    let onAddToList: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background card - this catches navigation taps
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.clear)
            
            // Recipe content
            VStack(alignment: .leading) {
                // Recipe image/placeholder
                ZStack {
                    LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Text("🍲") // Could be customized per recipe in the future
                        .font(.system(size: 70))
                }
                .frame(height: 160)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(recipe.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.text)
                    
                    HStack {
                        // Format cooking time
                        let minutes = Int(recipe.estimatedTime / 60)
                        let timeText = minutes < 60 ? 
                            "\(minutes) mins" : 
                            "\(minutes / 60) hr \(minutes % 60) min"
                        
                        Text(timeText)
                        Spacer()
                        Text("\(recipe.servings) servings")
                    }
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    
                    if !recipe.missingIngredients.isEmpty {
                        let missingNames = recipe.missingIngredients.map { $0.name }
                        Text("Missing: \(missingNames.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.error)
                        
                        // This button is now explicitly outside the navigation tap
                        Button {
                            onAddToList()
                        } label: {
                            Label("Add to list", systemImage: "plus")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.accentTeal)
                                .padding(8)
                                .background(Color(UIColor.systemBackground).opacity(0.01))
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Text("You have all ingredients!")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.success)
                    }
                    
                    // Display dietary tags if available
                    if !recipe.dietaryTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(recipe.dietaryTags), id: \.self) { tag in
                                    Text(tag.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppTheme.primary.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.borderColor, lineWidth: 1)
            )
            .shadow(color: colorScheme == .dark ? Color.clear : AppTheme.cardShadowColor, radius: colorScheme == .dark ? 0 : 4)
        }
        .padding(.horizontal)
    }
} 
