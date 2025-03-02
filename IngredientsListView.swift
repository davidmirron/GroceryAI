import SwiftUI

struct IngredientsListView: View {
    @ObservedObject var recipe: Recipe
    
    var body: some View {
        List {
            ForEach(recipe.ingredients) { ingredient in
                HStack {
                    Text("•")
                        .foregroundColor(Color.darkHeaderBg)
                    VStack(alignment: .leading) {
                        Text("\(ingredient.amount, specifier: "%.1f") \(ingredient.unit.rawValue) \(ingredient.name)")
                            .font(.body)
                        if let notes = ingredient.notes {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }
                    }
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