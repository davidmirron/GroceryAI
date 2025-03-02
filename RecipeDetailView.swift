import SwiftUI

struct RecipeDetailView: View {
    @StateObject var recipe = Recipe(
        id: UUID(),
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
            ),
            Ingredient(
                name: "Eggs", 
                amount: 6.0, 
                unit: .pieces, 
                category: .dairy, 
                isPerishable: true, 
                typicalShelfLife: 14, 
                notes: nil, 
                customOrder: 2
            ),
            Ingredient(
                name: "Bread", 
                amount: 500.0, 
                unit: .grams, 
                category: .bakery, 
                isPerishable: false, 
                typicalShelfLife: 5, 
                notes: "Whole Grain", 
                customOrder: 3
            )
        ],
        instructions: [
            "Step 1: Mix ingredients.", 
            "Step 2: Bake at 350°F for 30 minutes."
        ],
        estimatedTime: 3600,
        servings: 4,
        nutritionalInfo: NutritionInfo(calories: 250, protein: 10, carbs: 30, fat: 5),
        missingIngredients: []
    )
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe header
                Text(recipe.name)
                    .font(.system(size: 28, weight: .bold))
                    .padding(.horizontal)
                
                // Recipe info
                HStack(spacing: 20) {
                    Label("\(Int(recipe.estimatedTime / 60)) min", systemImage: "clock")
                    Label("\(recipe.servings) servings", systemImage: "person.2")
                    
                    if let nutritionalInfo = recipe.nutritionalInfo {
                        Label("\(nutritionalInfo.calories) cal", systemImage: "flame")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(Color.darkTextSecondary)
                .padding(.horizontal)
                
                // Ingredients
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ingredients")
                        .font(.system(size: 20, weight: .semibold))
                    
                    IngredientsListView(recipe: recipe)
                }
                .padding()
                .background(Color.darkCardBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Instructions")
                        .font(.system(size: 20, weight: .semibold))
                    
                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top) {
                            Text("\(index + 1).")
                                .font(.headline)
                                .foregroundStyle(Color.darkHeaderBg)
                                .frame(width: 30, alignment: .leading)
                            
                            Text(step)
                                .lineLimit(nil)
                        }
                        .padding(.vertical, 8)
                        
                        if index < recipe.instructions.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(Color.darkCardBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                // Nutritional info
                if let nutritionalInfo = recipe.nutritionalInfo {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nutrition Facts")
                            .font(.system(size: 20, weight: .semibold))
                        
                        HStack {
                            NutritionItem(title: "Calories", value: "\(nutritionalInfo.calories)")
                            Divider()
                            NutritionItem(title: "Protein", value: "\(nutritionalInfo.protein)g")
                            Divider()
                            NutritionItem(title: "Carbs", value: "\(nutritionalInfo.carbs)g")
                            Divider()
                            NutritionItem(title: "Fat", value: "\(nutritionalInfo.fat)g")
                        }
                    }
                    .padding()
                    .background(Color.darkCardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                // Ingredients List with Deletion Capability
                IngredientsListView(recipe: recipe)
            }
            .padding(.vertical)
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NutritionItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.darkTextSecondary)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.darkText)
        }
        .frame(maxWidth: .infinity)
    }
} 