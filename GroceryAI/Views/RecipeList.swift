import SwiftUI

struct RecipeListView: View {
    @StateObject var recipeListViewModel = RecipeListViewModel()
    @StateObject var shoppingListViewModel = ShoppingListViewModel()
    @State var presentationMode: RecipePresentationMode = .navigation
    @State private var selectedRecipe: Recipe?
    @State private var isShowingNewRecipeSheet = false
    
    enum RecipePresentationMode {
        case navigation
        case sheet
    }
    
    var body: some View {
        Group {
            if presentationMode == .navigation {
                NavigationView {
                    recipeListContent
                        .navigationTitle("Recipes")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: { isShowingNewRecipeSheet = true }) {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                }
                .sheet(isPresented: $isShowingNewRecipeSheet) {
                    RecipeFormView(onSave: { newRecipe in
                        recipeListViewModel.recipes.append(newRecipe)
                        isShowingNewRecipeSheet = false
                    })
                }
            } else {
                recipeListContent
                    .listStyle(.plain)
                    .sheet(item: $selectedRecipe) { recipe in
                        RecipeDetailView(recipe: recipe, viewModel: shoppingListViewModel)
                    }
            }
        }
    }
    
    private var recipeListContent: some View {
        List {
            ForEach(recipeListViewModel.recipes) { recipe in
                if presentationMode == .navigation {
                    NavigationLink {
                        RecipeDetailView(recipe: recipe, viewModel: shoppingListViewModel)
                    } label: {
                        RecipeRow(recipe: recipe)
                    }
                } else {
            RecipeRow(recipe: recipe)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedRecipe = recipe
                }
        }
            }
            .onDelete(perform: deleteRecipes)
        }
    }
    
    func deleteRecipes(at offsets: IndexSet) {
        recipeListViewModel.recipes.remove(atOffsets: offsets)
    }
}

// Recipe Form View for creating and editing recipes
struct RecipeFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var recipeName = ""
    @State private var ingredients: [Ingredient] = [
        Ingredient(
            name: "",
            amount: 1.0,
            unit: .pieces,
            category: .other,
            isPerishable: false
        )
    ]
    
    @State private var instructions: [String] = [""]
    @State private var cookingHours = 0
    @State private var cookingMinutes = 30
    @State private var servings = 4
    
    let onSave: (Recipe) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Recipe Name", text: $recipeName)
                    
                    Stepper(value: $servings, in: 1...20) {
                        Text("Servings: \(servings)")
                    }
                    
                    HStack {
                        Text("Cooking Time")
                        Spacer()
                        Picker("Hours", selection: $cookingHours) {
                            ForEach(0..<24) { hour in
                                Text("\(hour) hr").tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 80)
                        
                        Picker("Minutes", selection: $cookingMinutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                    }
                }
                
                Section(header: Text("Ingredients")) {
                    ForEach(0..<ingredients.count, id: \.self) { index in
                        HStack {
                            TextField("Name", text: Binding(
                                get: { ingredients[index].name },
                                set: { newValue in
                                    var updated = ingredients[index]
                                    updated.name = newValue
                                    ingredients[index] = updated
                                }
                            ))
                            
                            Divider()
                            
                            TextField("Amount", value: Binding(
                                get: { ingredients[index].amount },
                                set: { newValue in
                                    var updated = ingredients[index]
                                    updated.amount = newValue
                                    ingredients[index] = updated
                                }
                            ), formatter: NumberFormatter())
                            .frame(width: 60)
                            .keyboardType(.decimalPad)
                            
                            Picker("Unit", selection: Binding(
                                get: { ingredients[index].unit },
                                set: { newValue in
                                    var updated = ingredients[index]
                                    updated.unit = newValue
                                    ingredients[index] = updated
                                }
                            )) {
                                ForEach([IngredientUnit.pieces, .grams, .liters, .cups], id: \.self) { unit in
                                    Text(unit.rawValue).tag(unit)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 70)
                        }
                    }
                    
                    Button("Add Ingredient") {
                        ingredients.append(Ingredient(
                            name: "",
                            amount: 1.0,
                            unit: .pieces,
                            category: .other,
                            isPerishable: false
                        ))
                    }
                }
                
                Section(header: Text("Instructions")) {
                    ForEach(0..<instructions.count, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .foregroundColor(.gray)
                                .frame(width: 30, alignment: .leading)
                            
                            TextField("Step \(index + 1)", text: $instructions[index])
                        }
                    }
                    
                    Button("Add Step") {
                        instructions.append("")
                    }
                }
            }
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newRecipe = Recipe(
                            name: recipeName.isEmpty ? "New Recipe" : recipeName,
                            ingredients: ingredients.filter { !$0.name.isEmpty },
                            instructions: instructions.filter { !$0.isEmpty },
                            estimatedTime: TimeInterval((cookingHours * 60 + cookingMinutes) * 60),
                            servings: servings
                        )
                        
                        onSave(newRecipe)
                    }
                }
            }
        }
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

// This initializer function replaces the old RecipeList struct
// and provides the same functionality but uses the consolidated RecipeListView
func createSheetBasedRecipeList(recipes: [Recipe]) -> some View {
    var view = RecipeListView()
    // Create a new view model with the provided recipes
    let viewModel = RecipeListViewModel()
    viewModel.recipes = recipes
    view = RecipeListView(recipeListViewModel: viewModel)
    view.presentationMode = .sheet
    return view
}

struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.name)
                .font(.headline)
            
            HStack {
                Label("\(Int(recipe.estimatedTime / 60)) min", systemImage: "clock")
                
                Spacer()
                
                if let nutrition = recipe.nutritionalInfo {
                    Text("\(nutrition.calories) calories")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Array(recipe.dietaryTags), id: \.self) { tag in
                        Text(tag.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
} 
