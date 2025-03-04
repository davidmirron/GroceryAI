import SwiftUI

// MARK: - Binding Extensions
// Add this at the TOP of the file, not inside any struct
extension Binding where Value == Ingredient {
    var nameBinding: Binding<String> {
        Binding<String>(
            get: { self.wrappedValue.name },
            set: { self.wrappedValue.name = $0 }
        )
    }
    
    var amountBinding: Binding<Double> {
        Binding<Double>(
            get: { self.wrappedValue.amount },
            set: { self.wrappedValue.amount = $0 }
        )
    }
    
    var unitBinding: Binding<IngredientUnit> {
        Binding<IngredientUnit>(
            get: { self.wrappedValue.unit },
            set: { self.wrappedValue.unit = $0 }
        )
    }
    
    var categoryBinding: Binding<IngredientCategory> {
        Binding<IngredientCategory>(
            get: { self.wrappedValue.category },
            set: { self.wrappedValue.category = $0 }
        )
    }
}

struct RecipeListView: View {
    @ObservedObject var recipeListViewModel: RecipeListViewModel
    @ObservedObject var shoppingListViewModel: ShoppingListViewModel
    @ObservedObject var recipesViewModel: RecipesViewModel
    @State var presentationMode: RecipePresentationMode = .navigation
    @State private var selectedRecipe: Recipe?
    @State private var isShowingNewRecipeSheet = false
    
    // Default initializer
    init(recipeListViewModel: RecipeListViewModel = RecipeListViewModel(),
         shoppingListViewModel: ShoppingListViewModel = ShoppingListViewModel()) {
        self.recipeListViewModel = recipeListViewModel
        self.shoppingListViewModel = shoppingListViewModel
        self.recipesViewModel = RecipesViewModel(recipeListViewModel: recipeListViewModel, shoppingListViewModel: shoppingListViewModel)
    }
    
    // Initializer that accepts all three ViewModels
    init(recipeListViewModel: RecipeListViewModel,
         shoppingListViewModel: ShoppingListViewModel,
         recipesViewModel: RecipesViewModel) {
        self.recipeListViewModel = recipeListViewModel
        self.shoppingListViewModel = shoppingListViewModel
        self.recipesViewModel = recipesViewModel
    }
    
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
                        recipeListViewModel.addRecipe(newRecipe)
                        isShowingNewRecipeSheet = false
                    })
                }
            } else {
                // When in sheet mode, wrap the content in a NavigationView for better presentation
                NavigationView {
                    recipeListContent
                        .navigationTitle("Recipes")
                        .listStyle(.plain)
                }
                .sheet(item: $selectedRecipe) { recipe in
                    NavigationView {
                        RecipeDetailView(recipe: recipe, viewModel: shoppingListViewModel, recipesViewModel: recipesViewModel)
                    }
                }
            }
        }
    }
    
    private var recipeListContent: some View {
        List {
            ForEach(recipeListViewModel.recipes) { recipe in
                if presentationMode == .navigation {
                    NavigationLink {
                        RecipeDetailView(recipe: recipe, viewModel: shoppingListViewModel, recipesViewModel: recipesViewModel)
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
        .emptyState(recipeListViewModel.recipes.isEmpty) {
            VStack(spacing: 20) {
                Image(systemName: "note.text.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.secondary)
                
                Text("No Recipes Yet")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Tap the + button to add your first recipe")
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    isShowingNewRecipeSheet = true
                } label: {
                    Text("Add Recipe")
                        .fontWeight(.medium)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }
    
    func deleteRecipes(at offsets: IndexSet) {
        recipeListViewModel.removeRecipe(at: offsets)
    }
}

// Removed RecipeFormView implementation as it now exists in RecipeFormView.swift

// Tag button for dietary tags
struct TagButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppTheme.primary : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : AppTheme.text)
                .cornerRadius(15)
        }
    }
}

// Empty state view extension
extension View {
    func emptyState<Content: View>(_ isEmpty: Bool, @ViewBuilder content: @escaping () -> Content) -> some View {
        ZStack {
            self
            if isEmpty {
                content()
            }
        }
    }
}

// This initializer function provides a recipe list with custom recipes
func createSheetBasedRecipeList(recipes: [Recipe], shoppingListViewModel: ShoppingListViewModel = ShoppingListViewModel()) -> some View {
    let recipeListVM = RecipeListViewModel()
    // Add the recipes to the view model but don't save them
    // This allows sharing recipes without affecting persisted ones
    recipeListVM.recipes = recipes
    
    let recipesVM = RecipesViewModel(recipeListViewModel: recipeListVM)
    
    let view = RecipeListView(
        recipeListViewModel: recipeListVM,
        shoppingListViewModel: shoppingListViewModel,
        recipesViewModel: recipesVM
    )
    view.presentationMode = .sheet
    return view
}

struct RecipeRow: View {
    let recipe: Recipe
    
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
        HStack(spacing: 12) {
            // Recipe image or emoji
            ZStack {
                Circle()
                    .fill(AppTheme.primaryLight.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                if let imageName = recipe.imageName, let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Text(recipeEmoji)
                        .font(.system(size: 24))
                }
            }
            
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
        }
        .padding(.vertical, 8)
    }
} 
