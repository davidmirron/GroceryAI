import SwiftUI

struct IngredientsListView: View {
    @ObservedObject var recipe: Recipe

    var body: some View {
        List {
            ForEach(recipe.ingredients, id: \.id) { ingredient in
                HStack {
                    Text("•")
                        .foregroundStyle(AppTheme.primary)
                    Text("\(ingredient.amount, specifier: "%.1f") \(ingredient.unit.rawValue) \(ingredient.name)")
                }
            }
            .onDelete(perform: deleteIngredients)
        }
        .listStyle(PlainListStyle())
    }

    /// Deletes ingredients at the specified offsets
    func deleteIngredients(at offsets: IndexSet) {
        recipe.ingredients.remove(atOffsets: offsets)
    }
} 