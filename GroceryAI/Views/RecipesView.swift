import SwiftUI

struct RecipesView: View {
    // ViewModels passed from parent
    @ObservedObject var recipeListViewModel: RecipeListViewModel
    @ObservedObject var recipesViewModel: RecipesViewModel
    @ObservedObject var shoppingListViewModel: ShoppingListViewModel
    
    @State private var isRefreshing = false
    @State private var showingRecipeList = false
    @State private var isShowingNewRecipeSheet = false
    @State private var showScrollIndicator = true
    @State private var scrollToCustomRecipes = false
    @State private var showMyRecipesHighlight = false
    @Environment(\.colorScheme) private var colorScheme
    
    // Add parameter to accept ingredients from ShoppingListView
    var ingredients: [Ingredient] = []
    
    // Default initializer that creates its own ViewModels (for previews and standalone use)
    init() {
        let recipeListVM = RecipeListViewModel()
        let shoppingListVM = ShoppingListViewModel()
        let recipesVM = RecipesViewModel(recipeListViewModel: recipeListVM, shoppingListViewModel: shoppingListVM)
        
        self.recipeListViewModel = recipeListVM
        self.shoppingListViewModel = shoppingListVM
        self.recipesViewModel = recipesVM
    }
    
    // Initializer that accepts shared ViewModels
    init(shoppingListViewModel: ShoppingListViewModel, recipeListViewModel: RecipeListViewModel, recipesViewModel: RecipesViewModel) {
        self.shoppingListViewModel = shoppingListViewModel
        self.recipeListViewModel = recipeListViewModel
        self.recipesViewModel = recipesViewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppTheme.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) { // Remove default spacing
                    // Break down the view into smaller components
                    Group {
                        if recipesViewModel.isLoading {
                            loadingView
                        }
                        else if let error = recipesViewModel.errorMessage {
                            errorView(message: error)
                        }
                        else if recipesViewModel.recipes.isEmpty {
                            emptyRecipesView
                        }
                        else {
                            ScrollViewReader { scrollProxy in
                                ScrollView(showsIndicators: true) {
                                    VStack(spacing: 8) { // Reduced spacing
                                        // Display user's custom recipes at the top
                                        if !recipesViewModel.customRecipes().isEmpty {
                                            customRecipesSection
                                                .id("customRecipes") // ID for scrolling
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                                )
                                                .padding(.horizontal)
                                                .padding(.top, 4) // Reduced spacing
                                                .overlay(
                                                    // Highlight animation when scrolling to custom recipes
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(AppTheme.primary, lineWidth: showMyRecipesHighlight ? 2 : 0)
                                                        .padding(.horizontal)
                                                        .padding(.top, 4)
                                                        .opacity(showMyRecipesHighlight ? 1.0 : 0.0)
                                                )
                                                .animation(.easeInOut(duration: 0.7), value: showMyRecipesHighlight)
                                        }
                                        
                                        // Recipe suggestions section title
                                        HStack {
                                            Text("Recommended For You")
                                                .font(.headline)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                        
                                        // Then display suggested recipes
                                        recipeListView
                                    }
                                    .padding(.bottom, 20)
                                }
                                .onChange(of: scrollToCustomRecipes) { shouldScroll in
                                    if shouldScroll {
                                        withAnimation {
                                            scrollProxy.scrollTo("customRecipes", anchor: .top)
                                            // Show highlight animation
                                            showMyRecipesHighlight = true
                                        }
                                        
                                        // Reset the flag
                                        scrollToCustomRecipes = false
                                        
                                        // Fade out highlight after a delay
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                            withAnimation {
                                                showMyRecipesHighlight = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .overlay(
                    VStack {
                        Spacer()
                        if showScrollIndicator && recipesViewModel.recipes.count > 1 {
                            Text("Scroll down for more recipes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Capsule().fill(colorScheme == .dark ? Color(.systemGray4) : Color.white.opacity(0.8)))
                                .padding(.bottom, 8)
                                .transition(.opacity)
                                .onAppear {
                                    // Auto-hide after 3 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            showScrollIndicator = false
                                        }
                                    }
                                }
                        }
                    }
                )
            }
            .navigationTitle("Recipe Suggestions")
            .navigationBarTitleDisplayMode(.inline) // Compact layout with smaller header
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        refreshRecipes()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(recipesViewModel.isLoading)
                    
                    Button(action: {
                        isShowingNewRecipeSheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.primary)
                            .padding(6)
                            .background(
                                Circle()
                                    .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                            )
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $isShowingNewRecipeSheet, onDismiss: {
            // Check if we should scroll to custom recipes when sheet is dismissed
            if let recipeForm = recipesViewModel.customRecipes().first, recipeForm.isCustomRecipe {
                // Slight delay to allow the view to update
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    scrollToCustomRecipes = true
                }
            }
        }) {
            NavigationView {
                RecipeFormView(
                    onSave: { newRecipe in
                        // The direct integration with RecipesViewModel now happens in the form
                        isShowingNewRecipeSheet = false
                        // After dismissal, scroll to custom recipes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            scrollToCustomRecipes = true
                        }
                    },
                    recipesViewModel: recipesViewModel
                )
            }
        }
        .onAppear {
            // Check if recipes are loaded
            if recipesViewModel.recipes.isEmpty {
                print("No recipes loaded, forcing reload")
                recipesViewModel.loadInitialRecipes()
            }
            
            // Generate recipe suggestions based on shopping list
            refreshRecipes()
        }
        .onChange(of: shoppingListViewModel.items) { _ in
            // Then always refresh with current shopping list items
            refreshRecipes()
        }
    }
    
    // MARK: - Component Views
    
    // Loading indicator view
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Finding recipes...")
                .padding()
            Spacer()
        }
    }
    
    // Error message view
    private func errorView(message: String) -> some View {
        VStack {
            Spacer()
            VStack {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                    .padding()
                
                Text(message)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Try Again") {
                    recipesViewModel.generateRecipes(from: shoppingListViewModel.items)
                }
                .padding()
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            Spacer()
        }
    }
    
    // Empty recipes view
    private var emptyRecipesView: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                
                Text("No Recipes Found")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Try adding more ingredients to your shopping list to see recipe suggestions.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .frame(maxWidth: 300)
                
                Button("Refresh Recipes") {
                    refreshRecipes()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            Spacer()
        }
    }
    
    // Recipe list view
    private var recipeListView: some View {
        ScrollView(showsIndicators: true) {
            LazyVStack(spacing: 12) {
                ForEach(recipesViewModel.recipes) { recipe in
                    recipeCell(for: recipe)
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    // Individual recipe cell - Redesigned to be more compact with horizontal layout
    private func recipeCell(for recipe: Recipe) -> some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(
                destination: RecipeDetailView(
                    recipe: recipe,
                    viewModel: shoppingListViewModel,
                    recipesViewModel: recipesViewModel
                )
            ) {
                // Redesigned recipe card that's more compact
                VStack(alignment: .leading, spacing: 8) {
                    // Recipe image area - more compact
                    HStack(spacing: 12) {
                        // Left side - Image
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.gray.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            if let imageName = recipe.imageName, !imageName.isEmpty, let uiImage = UIImage(named: imageName) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .clipped()
                                    .accessibility(label: Text("Recipe image for \(recipe.name)"))
                            } else {
                                VStack {
                                    Text(getRecipeEmoji(for: recipe.name))
                                        .font(.system(size: 30))
                                        .accessibility(label: Text("Recipe icon for \(recipe.name)"))
                                    
                                    if (recipe.imageName ?? "").isEmpty {
                                        // This prevents attempting to load non-existent images
                                        Text("")
                                            .frame(width: 0, height: 0)
                                            .opacity(0)
                                    }
                                }
                            }
                        }
                        
                        // Right side - Details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.name)
                                .font(.headline)
                                .lineLimit(1)
                                .foregroundColor(AppTheme.text)
                            
                            // Recipe metadata in horizontal layout
                            HStack {
                                Image(systemName: "clock")
                                    .font(.caption2)
                                Text("\(Int(recipe.estimatedTime / 60)) min")
                                    .font(.caption)
                                
                                Spacer()
                                
                                Image(systemName: "person.2")
                                    .font(.caption2)
                                Text("\(recipe.servings)")
                                    .font(.caption)
                            }
                            .foregroundColor(AppTheme.textSecondary)
                            
                            // Match score with better dark mode adaptation
                            HStack {
                                let matchPercentage = Int(recipe.matchScore * 100)
                                let matchColor: Color = matchPercentage >= 70 ? 
                                    (colorScheme == .dark ? AppTheme.success : Color.green) : 
                                    matchPercentage >= 40 ? 
                                        (colorScheme == .dark ? Color(hex: "#FB923C") : Color.orange) : 
                                        (colorScheme == .dark ? AppTheme.error : Color.red)
                                
                                Text("\(matchPercentage)% match")
                                    .font(.caption)
                                    .foregroundColor(matchColor)
                                
                                Spacer()
                                
                                // Progress bar with better dark mode adaptation
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .frame(height: 4)
                                        .opacity(0.2)
                                        .foregroundColor(matchColor)
                                    
                                    Rectangle()
                                        .frame(width: CGFloat(recipe.matchScore) * 100, height: 4)
                                        .foregroundColor(matchColor)
                                }
                                .frame(width: 100)
                            }
                            
                            // Missing ingredients
                            if !recipe.missingIngredients.isEmpty {
                                Text("Missing: \(recipe.missingIngredients.count) items")
                                    .font(.caption)
                                    .foregroundColor(colorScheme == .dark ? Color.orange.opacity(0.8) : Color.orange)
                            }
                        }
                    }
                    
                    // Tags in scrollable row if present
                    if !recipe.dietaryTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(Array(recipe.dietaryTags), id: \.self) { tag in
                                    Text(tag.rawValue)
                                        .font(.system(size: 9))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(AppTheme.chipBackground)
                                        .foregroundColor(AppTheme.chipText)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.top, -4) // Negative padding to compact the layout
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(AppTheme.cardBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? AppTheme.borderColor : Color.clear, lineWidth: 1)
                )
                .shadow(
                    color: colorScheme == .dark ? Color.clear : AppTheme.cardShadowColor,
                    radius: 3, x: 0, y: 2
                )
            }
            
            // Action buttons
            recipeActionButtons(for: recipe)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .padding(.vertical, 4) // Reduced vertical padding between cards
    }
    
    // Recipe action buttons - Smaller and more compact
    private func recipeActionButtons(for recipe: Recipe) -> some View {
        HStack(spacing: 6) {
            Button {
                addMissingIngredients(from: recipe)
            } label: {
                Image(systemName: "cart.badge.plus")
                    .font(.system(size: 12))
                    .padding(8)
                    .background(Circle().fill(AppTheme.primary))
                    .foregroundColor(.white)
                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.1) : Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(BorderlessButtonStyle())
            
            Button {
                saveRecipe(recipe)
            } label: {
                Image(systemName: "bookmark")
                    .font(.system(size: 12))
                    .padding(8)
                    .background(Circle().fill(AppTheme.secondary))
                    .foregroundColor(.white)
                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.1) : Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(10)
        .offset(x: -5, y: 5)
    }
    
    // Helper function to get emojis
    private func getRecipeEmoji(for name: String) -> String {
        let name = name.lowercased()
        
        if name.contains("pancake") { return "🥞" }
        else if name.contains("salad") { return "🥗" }
        else if name.contains("pasta") || name.contains("spaghetti") { return "🍝" }
        else if name.contains("cookie") { return "🍪" }
        else if name.contains("curry") { return "🍛" }
        else if name.contains("taco") { return "🌮" }
        else if name.contains("bread") || name.contains("banana") { return "🍞" }
        else if name.contains("stir fry") { return "🥘" }
        else if name.contains("chili") { return "🌶️" }
        else { return "🍲" }
    }
    
    // Refresh recipes based on current shopping list with debugging
    private func refreshRecipes() {
        // Set loading state
        isRefreshing = true
        
        // Generate recipes based on current shopping list items
        recipesViewModel.generateRecipes(from: shoppingListViewModel.items)
        
        // Debug output
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.debugRecipes()
        }
        
        // Reset loading state after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isRefreshing = false
        }
    }
    
    // Debug function to check loaded recipes
    private func debugRecipes() {
        print("Number of recipes in viewModel: \(recipesViewModel.recipes.count)")
        for (index, recipe) in recipesViewModel.recipes.enumerated() {
            print("Recipe \(index): \(recipe.name) - Match score: \(recipe.matchScore)")
        }
    }
    
    // Add missing ingredients from a recipe to the shopping list
    private func addMissingIngredients(from recipe: Recipe) {
        // Only add ingredients that are missing
        for ingredient in recipe.missingIngredients {
            shoppingListViewModel.addItem(ingredient)
        }
        
        // Show a confirmation with the count
        let count = recipe.missingIngredients.count
        if count > 0 {
            // In a real app, you would use a toast or alert here
            print("Added \(count) missing ingredients to shopping list")
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Force refresh
        refreshRecipes()
    }
    
    // Save recipe to RecipeListViewModel
    private func saveRecipe(_ recipe: Recipe) {
        recipesViewModel.addToRecipeList(recipe)
        
        // Show a confirmation
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // Custom recipes section - Showcases user's own recipes
    private var customRecipesSection: some View {
        VStack(alignment: .leading, spacing: 8) { // Reduced spacing
            // Section header with custom styling and improved visibility
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.footnote)
                        .foregroundColor(AppTheme.primary)
                    
                    Text("My Recipes")
                        .font(.headline)
                        .foregroundColor(AppTheme.primary)
                }
                
                Spacer()
                
                Button(action: {
                    // Show all user's recipes - for now we'll just highlight the section
                    withAnimation {
                        showMyRecipesHighlight = true
                    }
                    
                    // Then fade it out after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            showMyRecipesHighlight = false
                        }
                    }
                }) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Horizontal scrollable list of custom recipes
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recipesViewModel.customRecipes(), id: \.id) { recipe in
                        // Custom recipe card
                        customRecipeCard(for: recipe)
                            .frame(width: 160)
                    }
                    
                    // Add recipe button at the end
                    addRecipeButton
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
        .padding(.bottom, 8)
    }
    
    // Custom recipe card - Designed specifically for the "My Recipes" section
    private func customRecipeCard(for recipe: Recipe) -> some View {
        NavigationLink(
            destination: RecipeDetailView(
                recipe: recipe,
                viewModel: shoppingListViewModel,
                recipesViewModel: recipesViewModel
            )
        ) {
            VStack(alignment: .leading, spacing: 8) {
                // Recipe image or placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color(.systemGray5) : Color.gray.opacity(0.1))
                        .aspectRatio(1.0, contentMode: .fit)
                    
                    if let imageName = recipe.imageName, !imageName.isEmpty, let uiImage = UIImage(named: imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        VStack {
                            Text(getRecipeEmoji(for: recipe.name))
                                .font(.system(size: 40))
                        }
                    }
                    
                    // "My Recipe" badge for visual distinction
                    VStack {
                        HStack {
                            Spacer()
                            
                            Text("My Recipe")
                                .font(.system(size: 9))
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(AppTheme.primary)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                    }
                    .padding(8)
                }
                
                // Recipe details
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(Int(recipe.estimatedTime / 60)) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 16).fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)))
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Add recipe button
    private var addRecipeButton: some View {
        Button(action: {
            isShowingNewRecipeSheet = true
        }) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color(.systemGray5) : AppTheme.backgroundGreen)
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(height: 120)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(AppTheme.primary)
                        
                        Text("Add Recipe")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                
                // Empty space to match the other cards
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 45)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Action button for recipe actions
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
            Text(title)
                .font(.system(size: 15, weight: .medium))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(color.opacity(0.9))
        .foregroundColor(.white)
        .cornerRadius(12)
    }
}

// Recipe Card UI - No longer needed since we've integrated its functionality directly into recipeCell
// struct RecipeCard: View {
//     ...
// } 
