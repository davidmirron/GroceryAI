import SwiftUI

// "Complete Your Meal" component for the shopping list
struct MealCompletionView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    @ObservedObject var recipesViewModel: RecipesViewModel
    
    @State private var showingRecipeDetail = false
    @State private var selectedRecipe: Recipe?
    @State private var bestMatch: Recipe?
    @State private var missingIngredients: [Ingredient] = []
    @State private var isDismissed = false
    
    var body: some View {
        if let bestMatch = bestMatch, !missingIngredients.isEmpty, !isDismissed {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text("Complete Your Meal")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Dismiss button
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            isDismissed = true
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 20))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Text("You have \(bestMatch.ingredients.count - missingIngredients.count) of \(bestMatch.ingredients.count) ingredients needed for \(bestMatch.name).")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    Button {
                        selectedRecipe = bestMatch
                        showingRecipeDetail = true
                    } label: {
                        Text("View Recipe")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.primary)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle()) // Ensures button taps are registered correctly
                    
                    if !missingIngredients.isEmpty {
                        Button {
                            addMissingIngredients()
                        } label: {
                            Text("Add Missing Items")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppTheme.primary)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle()) // Ensures button taps are registered correctly
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.primary.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .sheet(isPresented: $showingRecipeDetail) {
                if let recipe = selectedRecipe {
                    NavigationView {
                        RecipeDetailView(
                            recipe: recipe,
                            viewModel: viewModel,
                            recipesViewModel: recipesViewModel
                        )
                    }
                }
            }
            .onAppear {
                updateCompletionData()
            }
            .onChange(of: viewModel.items) { oldValue, newValue in
                updateCompletionData()
            }
        } else {
            // Empty view when no best match
            EmptyView()
                .onAppear {
                    updateCompletionData()
                }
                .onChange(of: viewModel.items) { oldValue, newValue in
                    updateCompletionData()
                }
        }
    }
    
    private func updateCompletionData() {
        // Ensure we're on the main thread for UI updates
        DispatchQueue.main.async {
            let currentIngredients = viewModel.items
            
            // Find recipes with at least 70% match
            let matches = recipesViewModel.recipes
                .map { recipe -> (Recipe, Double) in
                    let score = recipesViewModel.calculateMatchScore(for: recipe, with: currentIngredients)
                    return (recipe, score)
                }
                .filter { $0.1 >= 0.7 && $0.1 < 1.0 } // Close but not 100%
                .sorted { $0.1 > $1.1 }
            
            if let bestMatchTuple = matches.first {
                let recipe = bestMatchTuple.0
                recipe.matchScore = bestMatchTuple.1
                self.bestMatch = recipe
                self.missingIngredients = recipesViewModel.getMissingIngredients(for: recipe, with: currentIngredients)
                
                // Reset dismissal when a new best match is found that's different from the current one
                if self.bestMatch?.id != recipe.id {
                    self.isDismissed = false
                }
            } else {
                self.bestMatch = nil
                self.missingIngredients = []
            }
        }
    }
    
    private func addMissingIngredients() {
        guard let _ = bestMatch, !missingIngredients.isEmpty else { return }
        
        // Create a copy of ingredients to avoid concurrent modification
        let ingredientsToAdd = missingIngredients
        
        for ingredient in ingredientsToAdd {
            viewModel.addItem(ingredient)
        }
        
        // Add haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Update the UI to reflect changes
        updateCompletionData()
        
        // Auto-dismiss after adding items
        withAnimation {
            isDismissed = true
        }
    }
} 