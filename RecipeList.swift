import SwiftUI

struct RecipeListView: View {
    @StateObject var recipeListViewModel = RecipeListViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recipeListViewModel.recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        Text(recipe.name)
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addRecipe) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    /// Adds a new recipe to the list
    func addRecipe() {
        let newRecipe = Recipe(
            name: "New Recipe",
            ingredients: [],
            instructions: [],
            estimatedTime: 0,
            servings: 1
        )
        recipeListViewModel.recipes.append(newRecipe)
    }
    
    /// Deletes recipes at the specified offsets
    func deleteRecipes(at offsets: IndexSet) {
        recipeListViewModel.recipes.remove(atOffsets: offsets)
    }
}

class RecipeListViewModel: ObservableObject {
    @Published var recipes: [Recipe] = [
        Recipe(
            name: "Sample Recipe",
            ingredients: [
                Ingredient(
                    name: "Milk", 
                    amount: 1.0, 
                    unit: .liters, 
                    category: .dairy, 
                    isPerishable: true, 
                    typicalShelfLife: 7, 
                    notes: "Organic Whole Milk", 
                    customOrder: 1
                )
            ],
            instructions: ["Mix ingredients.", "Bake at 350°F for 30 minutes."],
            estimatedTime: 3600,
            servings: 4,
            nutritionalInfo: NutritionInfo(calories: 250, protein: 10, carbs: 30, fat: 5),
            missingIngredients: []
        )
    ]
} 