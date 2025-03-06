import SwiftUI
import Combine

struct RecipesView: View {
    // ViewModels passed from parent
    @ObservedObject var recipeListViewModel: RecipeListViewModel
    @ObservedObject var recipesViewModel: RecipesViewModel
    @ObservedObject var shoppingListViewModel: ShoppingListViewModel
    
    // Cache for filtered recipe results to improve performance
    @State private var cachedCookTonight: [Recipe] = []
    @State private var cachedAlmostThere: [Recipe] = []
    @State private var cachedWorthExploring: [Recipe] = []
    @State private var lastFilterApplied: RecipeFilter = .all
    @State private var lastSearchApplied: String = ""
    
    @State private var isRefreshing = false
    @State private var showingRecipeList = false
    @State private var isShowingNewRecipeSheet = false
    @State private var showScrollIndicator = true
    @State private var scrollToCustomRecipes = false
    @State private var showMyRecipesHighlight = false
    @Environment(\.colorScheme) private var colorScheme
    
    // Add parameter to accept ingredients from ShoppingListView
    var ingredients: [Ingredient] = []
    
    // State variables for toast notifications
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon = "checkmark.circle.fill"
    @State private var toastColor = AppTheme.primary
    
    // MARK: - Performance Metrics
    
    @State private var totalFilteringTime: TimeInterval = 0
    @State private var filteringOperations: Int = 0
    @State private var cacheHits: Int = 0
    
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
        ZStack(alignment: .bottomTrailing) {
                // Background
                AppTheme.background
                    .edgesIgnoringSafeArea(.all)
                
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
                    // Search bar at the top
                    searchBar
                    
                    // Recipe filter bar below search
                    recipeFilterBar
                    
                    // Add filter state indicator
                    if recipesViewModel.selectedFilter != .all {
                        HStack {
                            Text("Active Filter:")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text(recipesViewModel.selectedFilter.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                recipesViewModel.applyFilter(.all)
                            }) {
                                HStack(spacing: 4) {
                                    Text("Clear")
                                        .font(.system(size: 14))
                                    
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(AppTheme.primary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.08))
                        .animation(.easeInOut(duration: 0.2), value: recipesViewModel.selectedFilter)
                    }
                    
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
                                    VStack(spacing: 16) {
                                        // Display user's custom recipes at the top
                                        if !recipesViewModel.customRecipes().isEmpty {
                                            customRecipesSection
                                                .id("customRecipes") // ID for scrolling
                                                .padding(.vertical, 8)
                                        }
                                        
                                        // Add an explanatory header for match groups
                                        if !recipesViewModel.recipes.isEmpty {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text("Recipes Organized by Ingredients Match")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(AppTheme.text)
                                                
                                                Text("Recipes are sorted by how well they match your shopping list items. Apply filters to refine what's shown in each group.")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppTheme.textSecondary)
                                                    .lineLimit(3)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.gray.opacity(0.1))
                                            )
                                            .padding(.horizontal)
                                            .padding(.bottom, 8)
                                        }
                                        
                                        // Recipe match groups based on percentage
                                        LazyVStack(spacing: 24) {
                                            // Cook Tonight section (90%+ match)
                                            if !recipesViewModel.cookTonightRecipes().isEmpty {
                                                recipeMatchGroup(
                                                    title: "Cook Tonight (90%+ Match)",
                                                    recipes: recipesViewModel.cookTonightRecipes(),
                                                    borderColor: AppTheme.highMatchColor
                                                )
                                            }
                                            
                                            // Almost There section (60-89% match)
                                            if !recipesViewModel.almostThereRecipes().isEmpty {
                                                recipeMatchGroup(
                                                    title: "Almost There (60-89% Match)",
                                                    recipes: recipesViewModel.almostThereRecipes(),
                                                    borderColor: AppTheme.mediumMatchColor
                                                )
                                            }
                                            
                                            // Worth Exploring section (30-59% match)
                                            if !recipesViewModel.worthExploringRecipes().isEmpty {
                                                recipeMatchGroup(
                                                    title: "Worth Exploring (30-59% Match)",
                                                    recipes: recipesViewModel.worthExploringRecipes(),
                                                    borderColor: AppTheme.lowMatchColor
                                                )
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .padding(.bottom, 80) // Extra padding for floating button
                                }
                                .onChange(of: scrollToCustomRecipes) { oldValue, shouldScroll in
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
                                .refreshable {
                                    // Pull to refresh functionality
                                    refreshRecipes()
                                }
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: recipesViewModel.isLoading)
                }
                
                // Toast notification
                toastView
            }
        }
        .navigationTitle("Recipe Suggestions")
        .navigationBarTitleDisplayMode(.inline) // Compact layout with smaller header
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation {
                        refreshRecipes()
                    }
                }) {
                    Image(systemName: isRefreshing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                        .foregroundColor(AppTheme.text)
                        .rotationEffect(Angle(degrees: isRefreshing ? 360 : 0))
                        .animation(isRefreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                }
                .disabled(recipesViewModel.isLoading)
            }
        }
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
        .onChange(of: shoppingListViewModel.items) { oldItems, newItems in
            // Keep suggestions updated based on shopping list changes
            if oldItems.count != newItems.count {
                print("Shopping list changed, refreshing recipes")
            refreshRecipes()
            }
        }
        .onReceive(recipesViewModel.$selectedFilter) { newValue in
            // Invalidate cache when filter changes
            invalidateCache()
        }
        .onReceive(recipeListViewModel.$searchText) { newValue in
            // Invalidate cache when search text changes
            invalidateCache()
        }
    }
    
    // MARK: - Component Views
    
    // Loading indicator view
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                .scaleEffect(1.5)
                .padding(.bottom, 16)
            
            Text("Finding recipes...")
                .font(.headline)
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .transition(.opacity)
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
                            CachedImage(
                                imageName: recipe.imageName,
                                category: recipe.category,
                                contentMode: .fill,
                                cornerRadius: 8,
                                size: CGSize(width: 140, height: 120),
                                backgroundColor: Color(.systemGray6)
                            )
                            .frame(width: 140, height: 120)
                            .clipped()
                            
                            // Category badge
                            if recipe.category != .other {
                                Text(recipe.category.rawValue)
                                    .font(.system(size: 9, weight: .medium))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(getCategoryColor(for: recipe.category))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                    .padding(4)
                            }
                        }
                        
                        // Right side - Recipe details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.name)
                                .font(.headline)
                                .foregroundColor(AppTheme.text)
                                .lineLimit(2)
                            
                            // Time and difficulty info
                            HStack(spacing: 8) {
                                // Time
                                HStack(spacing: 2) {
                                    Image(systemName: "clock")
                                        .font(.caption2)
                                    Text(formatTime(recipe.estimatedTime))
                                        .font(.caption)
                                }
                                .foregroundColor(AppTheme.textSecondary)
                                
                                Text("•")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .font(.caption)
                                
                                // Difficulty level
                                HStack(spacing: 2) {
                                    Image(systemName: getDifficultyIcon(for: recipe.difficulty))
                                        .font(.caption2)
                                    Text(recipe.difficulty.rawValue)
                                        .font(.caption)
                                }
                                .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            // Missing ingredients count
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
    
    // Reset performance metrics
    private func resetPerformanceMetrics() {
        totalFilteringTime = 0
        filteringOperations = 0
        cacheHits = 0
    }
    
    // Refresh recipes based on current shopping list with debugging
    private func refreshRecipes() {
        // Set loading state
        isRefreshing = true
        
        // Invalidate cache since recipe data will change
        invalidateCache()
        
        // Reset performance metrics
        resetPerformanceMetrics()
        
        // Use a background thread for heavy processing
        DispatchQueue.global(qos: .userInitiated).async {
            // Generate recipes based on current shopping list items on the background thread
            self.recipesViewModel.generateRecipes(from: self.shoppingListViewModel.items)
            
            // Debug output on main thread
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.debugRecipes()
            }
            
            // Reset loading state after a delay on main thread
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isRefreshing = false
            }
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
            // Show toast notification
            toastMessage = "Added \(count) ingredient\(count > 1 ? "s" : "") to your list"
            toastIcon = "cart.badge.plus"
            toastColor = AppTheme.primary
            
            withAnimation {
                showToast = true
            }
            
            // Hide toast after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showToast = false
                }
            }
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
        
        // Show toast notification
        toastMessage = "Recipe saved to My Recipes"
        toastIcon = "heart.fill"
        toastColor = AppTheme.secondary
        
        withAnimation {
            showToast = true
        }
        
        // Hide toast after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showToast = false
            }
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // Custom recipes section - Showcases user's own recipes
    private var customRecipesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section header with "See All" button
            HStack {
                Text("My Recipes")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.text)
                
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
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            // Horizontal scrollable list of custom recipes
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Custom recipe cards
                    ForEach(recipesViewModel.customRecipes(), id: \.id) { recipe in
                        customRecipeCard(for: recipe)
                    }
                    
                    // Add recipe card at the end
                    addRecipeCard
                }
        .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(showMyRecipesHighlight ? AppTheme.primary.opacity(0.05) : Color.clear)
        }
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
            VStack(alignment: .leading, spacing: 0) {
                // Recipe image
                ZStack(alignment: .topTrailing) {
                    CachedImage(
                        imageName: recipe.imageName,
                        category: recipe.category,
                        contentMode: .fill,
                        cornerRadius: 8,
                        size: CGSize(width: 140, height: 120),
                        backgroundColor: Color(.systemGray6)
                    )
                    .frame(width: 140, height: 120)
                    .clipped()
                    
                    // "My Recipe" badge
                    Text("My Recipe")
                        .font(.system(size: 10, weight: .medium))
        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.primary)
                        .cornerRadius(10)
                        .padding(8)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                
                // Recipe details
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.text)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.textSecondary)
                        Text(formatTime(recipe.estimatedTime))
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding(10)
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            .frame(width: 140, height: 170)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Add recipe card at the end of "My Recipes" section
    private var addRecipeCard: some View {
        Button(action: {
            isShowingNewRecipeSheet = true
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text("+")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(AppTheme.primary)
                }
                
                Text("Add Recipe")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.primary)
            }
            .frame(width: 140, height: 170)
            .background(AppTheme.primary.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        AppTheme.primary.opacity(0.3),
                        style: StrokeStyle(lineWidth: 1, dash: [5])
                    )
            )
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Recipe filter bar for filtering recipes by type
    private var recipeFilterBar: some View {
        VStack(spacing: 0) {
            // Primary filter scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Essential filters - shown by default
                    filterCapsule(filter: .all)
                    filterDivider
                    
                    // Discovery section - add these curated collections first for visibility
                    filterCapsule(filter: .weeknightDinners)
                    filterCapsule(filter: .healthyOptions)
                    filterCapsule(filter: .comfortFood)
                    
                    filterDivider
                    
                    // Category section
                    filterCapsule(filter: .breakfast)
                    filterCapsule(filter: .mainCourse)
                    filterCapsule(filter: .dessert)
                    
                    filterDivider
                    
                    // Dietary section
                    filterCapsule(filter: .vegetarian)
                    filterCapsule(filter: .glutenFree)
                    
                    filterDivider
                    
                    // Time section
                    filterCapsule(filter: .under30Min)
                    
                    // More filters option
                    Menu {
                        // Discovery section
                        Section("Discovery") {
                            if !filtersContain(.weeknightDinners) {
                                Button { recipesViewModel.applyFilter(.weeknightDinners) } label: {
                                    Label(RecipeFilter.weeknightDinners.rawValue, systemImage: RecipeFilter.weeknightDinners.iconName)
                                }
                            }
                            if !filtersContain(.healthyOptions) {
                                Button { recipesViewModel.applyFilter(.healthyOptions) } label: {
                                    Label(RecipeFilter.healthyOptions.rawValue, systemImage: RecipeFilter.healthyOptions.iconName)
                                }
                            }
                            if !filtersContain(.comfortFood) {
                                Button { recipesViewModel.applyFilter(.comfortFood) } label: {
                                    Label(RecipeFilter.comfortFood.rawValue, systemImage: RecipeFilter.comfortFood.iconName)
                                }
                            }
                            Button { recipesViewModel.applyFilter(.partyFood) } label: {
                                Label(RecipeFilter.partyFood.rawValue, systemImage: RecipeFilter.partyFood.iconName)
                            }
                        }
                        
                        // Additional dietary filters
                        Section("Dietary") {
                            Button { recipesViewModel.applyFilter(.vegan) } label: {
                                Label(RecipeFilter.vegan.rawValue, systemImage: RecipeFilter.vegan.iconName)
                            }
                            Button { recipesViewModel.applyFilter(.dairyFree) } label: {
                                Label(RecipeFilter.dairyFree.rawValue, systemImage: RecipeFilter.dairyFree.iconName)
                            }
                            Button { recipesViewModel.applyFilter(.keto) } label: {
                                Label(RecipeFilter.keto.rawValue, systemImage: RecipeFilter.keto.iconName)
                            }
                            Button { recipesViewModel.applyFilter(.lowCarb) } label: {
                                Label(RecipeFilter.lowCarb.rawValue, systemImage: RecipeFilter.lowCarb.iconName)
                            }
                        }
                        
                        // Additional meal types
                        Section("Meal Types") {
                            Button { recipesViewModel.applyFilter(.lunch) } label: {
                                Label(RecipeFilter.lunch.rawValue, systemImage: RecipeFilter.lunch.iconName)
                            }
                            Button { recipesViewModel.applyFilter(.dinner) } label: {
                                Label(RecipeFilter.dinner.rawValue, systemImage: RecipeFilter.dinner.iconName)
                            }
                        }
                        
                        // Other filters
                        Section("Other") {
                            Button { recipesViewModel.applyFilter(.easyRecipes) } label: {
                                Label(RecipeFilter.easyRecipes.rawValue, systemImage: RecipeFilter.easyRecipes.iconName)
                            }
                            Button { recipesViewModel.applyFilter(.popular) } label: {
                                Label(RecipeFilter.popular.rawValue, systemImage: RecipeFilter.popular.iconName)
                            }
                        }
                        
                    } label: {
                        HStack(spacing: 4) {
                            Text("More")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(Color(.systemGray6))
                        )
                        .foregroundColor(AppTheme.text)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .background(AppTheme.cardBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // Visual divider between filter categories
    private var filterDivider: some View {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            .frame(width: 1, height: 24)
    }
    
    // Modern capsule-style filter button
    private func filterCapsule(filter: RecipeFilter) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                recipesViewModel.applyFilter(filter)
            }
            
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }) {
            HStack(spacing: 6) {
                // Icon
                Image(systemName: filter.iconName)
                    .font(.system(size: 12))
                
                // Text
                Text(filter.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(recipesViewModel.selectedFilter == filter ? 
                          filter.color.opacity(0.15) : Color(.systemGray6))
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                recipesViewModel.selectedFilter == filter ? 
                                filter.color : Color.clear,
                                lineWidth: 1.5
                            )
                    )
            )
            .foregroundColor(recipesViewModel.selectedFilter == filter ? 
                             filter.color : AppTheme.text)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(recipesViewModel.selectedFilter == filter ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: recipesViewModel.selectedFilter)
    }
    
    // Recipe match group component for categorized recipes
    private func recipeMatchGroup(title: String, recipes: [Recipe], borderColor: Color) -> some View {
        // Apply both the filter and search text
        let filteredRecipes = getFilteredRecipes(from: recipes)
        
        // Only show section if there are matching recipes after filtering
        if filteredRecipes.isEmpty {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            VStack(alignment: .leading, spacing: 16) {
                // Section header with colored left border
                HStack {
                    Text("\(title) (\(filteredRecipes.count))")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppTheme.text)
                        .padding(.leading, 8)
                }
                .padding(.leading, 8)
                .background(
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 24)
                        .overlay(
                            Rectangle()
                                .fill(borderColor)
                                .frame(width: 3),
                            alignment: .leading
                        )
                )
                .padding(.top, 8)
                .padding(.bottom, 4)
                
                // Using LazyVStack for better rendering performance of recipes
                LazyVStack(spacing: 16) {
                    ForEach(filteredRecipes) { recipe in
                        enhancedRecipeCard(recipe: recipe)
                            .padding(.bottom, 8)
                    }
                }
            }
            .padding(.vertical, 8)
        )
    }
    
    // Enhanced recipe card with improved design and functionality
    private func enhancedRecipeCard(recipe: Recipe) -> some View {
        let matchPercentage = Int(recipe.matchScore * 100)
        let matchColor: Color = matchPercentage >= 90 ? AppTheme.highMatchColor :
                               matchPercentage >= 60 ? AppTheme.mediumMatchColor : AppTheme.lowMatchColor
        
        return NavigationLink(
            destination: RecipeDetailView(
                recipe: recipe,
                viewModel: shoppingListViewModel,
                recipesViewModel: recipesViewModel
            )
        ) {
            VStack(alignment: .leading, spacing: 0) {
                // Content container
                VStack(alignment: .leading, spacing: 12) {
                    // Recipe image and details row
                    HStack(alignment: .top, spacing: 16) {
                        // Recipe image with category badge
                        ZStack(alignment: .topTrailing) {
                            CachedImage(
                                imageName: recipe.imageName,
                                category: recipe.category,
                                contentMode: .fill,
                                cornerRadius: 12,
                                size: CGSize(width: 90, height: 90),
                                backgroundColor: Color(.systemGray6)
                            )
                            .frame(width: 90, height: 90)
                            
                            // Category badge in top right corner (only if category exists)
                            if recipe.category != .other {
                                Text(recipe.category.rawValue)
                                    .font(.system(size: 9, weight: .medium))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(getCategoryColor(for: recipe.category))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .padding(6)
                            }
                        }
                        .frame(width: 90, height: 90)
            
                        // Recipe details
                        VStack(alignment: .leading, spacing: 8) {
                            // Recipe name
                            Text(recipe.name)
                                .font(.headline)
                                .foregroundColor(AppTheme.text)
                                .lineLimit(2)
                            
                            // Recipe meta information (time, servings)
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.caption2)
                                    Text(formatTime(recipe.estimatedTime))
                                        .font(.caption)
                                }
                                .foregroundColor(AppTheme.textSecondary)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "person.2")
                                        .font(.caption2)
                                    Text("\(recipe.servings) servings")
                                        .font(.caption)
                                }
                                .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            // Match percentage with progress bar
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(matchPercentage)% Match")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(matchColor)
                    
                                // Progress bar (simplified)
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 4)
                                        .cornerRadius(2)
                            
                                    Rectangle()
                                        .fill(matchColor)
                                        .frame(width: CGFloat(recipe.matchScore) * 200, height: 4)
                                        .cornerRadius(2)
                                }
                            }
                            
                            // Missing ingredients information
                            if !recipe.missingIngredients.isEmpty {
                                Text("Missing \(recipe.missingIngredients.count) item\(recipe.missingIngredients.count > 1 ? "s" : "")")
                                    .font(.caption)
                                    .foregroundColor(matchColor)
                            }
                        }
                    }
                    
                    // Missing ingredients horizontal scroll (only show if there are missing ingredients)
                    if !recipe.missingIngredients.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(recipe.missingIngredients.prefix(4), id: \.id) { ingredient in
                                    missingIngredientPill(ingredient: ingredient)
                                }
                                
                                // Show count of remaining items if more than 4
                                if recipe.missingIngredients.count > 4 {
                                    Button(action: {
                                        addMissingIngredients(from: recipe)
                                    }) {
                                        Text("+\(recipe.missingIngredients.count - 4) more")
                                            .font(.caption)
                                            .foregroundColor(matchColor)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(matchColor.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.bottom, 4)
                        }
                    }
                    
                    // Tags horizontal scroll (only show if there are dietary tags)
                    if !recipe.dietaryTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                // Show only the first 3 tags plus difficulty to reduce complexity
                                ForEach(Array(recipe.dietaryTags.prefix(3)), id: \.self) { tag in
                                    Text(tag.rawValue)
                                        .font(.system(size: 10))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray6))
                                        .foregroundColor(AppTheme.textSecondary)
                                        .cornerRadius(10)
                                }
                                
                                // Show Difficulty as a tag
                                Text(recipe.difficulty.rawValue)
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(getDifficultyColor(for: recipe.difficulty).opacity(0.1))
                                    .foregroundColor(getDifficultyColor(for: recipe.difficulty))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(AppTheme.cardBackground))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.borderColor, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(
            HStack(spacing: 8) {
                // Add all missing ingredients button
                Button(action: {
                    addMissingIngredients(from: recipe)
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.primary)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                
                // Favorite button
                Button(action: {
                    saveRecipe(recipe)
                }) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.secondary)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(12),
            alignment: .topTrailing
        )
    }
    
    // Missing ingredient pill with one-tap add functionality
    private func missingIngredientPill(ingredient: Ingredient) -> some View {
        Button(action: {
            recipesViewModel.addMissingIngredient(ingredient)
        }) {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.mediumMatchColor)
                
                Text(ingredient.name)
                    .font(.caption)
                    .foregroundColor(AppTheme.mediumMatchColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.mediumMatchColor.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper to get color for difficulty level
    private func getDifficultyColor(for difficulty: RecipeDifficulty) -> Color {
        switch difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
    
    // Helper to get color for recipe category
    private func getCategoryColor(for category: RecipeCategory) -> Color {
        switch category {
        case .breakfast:
            return .orange
        case .lunch, .dinner, .mainCourse:
            return AppTheme.primary
        case .appetizer, .sideDish:
            return .green
        case .dessert:
            return .pink
        case .snack:
            return .yellow
        case .salad:
            return .mint
        case .soup:
            return .indigo
        case .beverage:
            return .blue
        case .other:
            return AppTheme.secondary
        }
    }
    
    // Helper to get icon for difficulty level
    private func getDifficultyIcon(for difficulty: RecipeDifficulty) -> String {
        switch difficulty {
        case .easy:
            return "tortoise"
        case .medium:
            return "hare"
        case .hard:
            return "bolt"
        }
    }
    
    // Helper function to format time in minutes
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours) hr \(remainingMinutes) min"
            }
        }
    }
    
    // Toast notification view
    private var toastView: some View {
        VStack {
            Spacer()
            
            if showToast {
                HStack(spacing: 12) {
                    Image(systemName: toastIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(toastColor)
                    
                    Text(toastMessage)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.text)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(AppTheme.cardBackground)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showToast)
                .onAppear {
                    // Auto-dismiss toast after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            showToast = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Additional UI Components
    
    // Search bar for recipe filtering
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textSecondary)
                .padding(.leading, 8)
            
            TextField("Search recipes...", text: $recipeListViewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(8)
                .foregroundColor(AppTheme.text)
            
            if !recipeListViewModel.searchText.isEmpty {
                Button(action: {
                    recipeListViewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.trailing, 8)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Recipe Filtering and Caching
    
    // Helper method to get recipes filtered by both the view model's filter and the search text
    private func getFilteredRecipes(from recipes: [Recipe]) -> [Recipe] {
        let startTime = Date()
        var isCacheHit = false
        
        // Identify which match group we're working with based on first recipe
        // (All recipes in a group have the same match score range)
        let matchGroup: String
        if let firstRecipe = recipes.first {
            if firstRecipe.matchScore >= 0.7 {
                matchGroup = "cookTonight"
            } else if firstRecipe.matchScore >= 0.4 && firstRecipe.matchScore < 0.7 {
                matchGroup = "almostThere"
            } else {
                matchGroup = "worthExploring"
            }
        } else {
            return [] // No recipes to filter
        }
        
        // Result to return
        var result: [Recipe]
        
        // Fast path: Check if we can use cached results
        if recipesViewModel.selectedFilter == lastFilterApplied && 
           recipeListViewModel.searchText == lastSearchApplied {
            // Cache is valid, return cached results for the appropriate group
            switch matchGroup {
            case "cookTonight" where !cachedCookTonight.isEmpty:
                result = cachedCookTonight
                isCacheHit = true
            case "almostThere" where !cachedAlmostThere.isEmpty:
                result = cachedAlmostThere
                isCacheHit = true
            case "worthExploring" where !cachedWorthExploring.isEmpty:
                result = cachedWorthExploring
                isCacheHit = true
            default:
                // Apply filtering
                result = recipes
                    .filtered(by: recipesViewModel.selectedFilter)
                    .filtered(bySearchText: recipeListViewModel.searchText)
            }
        } else {
            // Cache is invalid, apply filtering
            result = recipes
                .filtered(by: recipesViewModel.selectedFilter)
                .filtered(bySearchText: recipeListViewModel.searchText)
            
            // Update cache
            switch matchGroup {
            case "cookTonight":
                cachedCookTonight = result
            case "almostThere":
                cachedAlmostThere = result
            case "worthExploring":
                cachedWorthExploring = result
            default:
                break
            }
            
            // Update tracking state
            lastFilterApplied = recipesViewModel.selectedFilter
            lastSearchApplied = recipeListViewModel.searchText
        }
        
        // Record performance metrics
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        recordFilterPerformance(isCacheHit: isCacheHit, duration: duration)
        
        return result
    }
    
    // MARK: - Action Helpers
    
    // Show toast helper function
    private func showToast(message: String, icon: String = "checkmark.circle.fill", color: Color = AppTheme.primary) {
        // If a toast is already showing, dismiss it first
        if showToast {
            withAnimation {
                showToast = false
            }
            
            // Small delay before showing new toast
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                toastMessage = message
                toastIcon = icon
                toastColor = color
                
                withAnimation {
                    showToast = true
                }
            }
        } else {
            toastMessage = message
            toastIcon = icon
            toastColor = color
            
            withAnimation {
                showToast = true
            }
        }
    }
    
    // Add missing ingredients for a recipe
    private func addMissingIngredients(for recipe: Recipe) {
        recipesViewModel.addAllMissingIngredients(from: recipe)
        
        // Show toast notification
        showToast(
            message: "Added \(recipe.missingIngredients.count) ingredients to shopping list",
            icon: "cart.badge.plus",
            color: AppTheme.success
        )
    }
    
    // Helper to check if a filter is already shown in the main filter bar
    private func filtersContain(_ filter: RecipeFilter) -> Bool {
        // These filters are shown in the main filter bar
        let mainBarFilters: [RecipeFilter] = [
            .all, .weeknightDinners, .healthyOptions, .comfortFood,
            .breakfast, .mainCourse, .dessert, .vegetarian, .glutenFree, .under30Min
        ]
        return mainBarFilters.contains(filter)
    }
    
    // MARK: - Cache Management
    
    /// Invalidates the recipe filter cache when data changes
    private func invalidateCache() {
        // Clear cached results
        cachedCookTonight = []
        cachedAlmostThere = []
        cachedWorthExploring = []
        
        // Reset tracking variables
        lastFilterApplied = .all
        lastSearchApplied = ""
    }
    
    // MARK: - Performance Metrics
    
    private func recordFilterPerformance(isCacheHit: Bool, duration: TimeInterval) {
        totalFilteringTime += duration
        filteringOperations += 1
        if isCacheHit {
            cacheHits += 1
        }
        
        // Log performance metrics occasionally
        if filteringOperations % 10 == 0 {
            let hitRate = filteringOperations > 0 ? Double(cacheHits) / Double(filteringOperations) * 100.0 : 0
            let avgTime = filteringOperations > 0 ? totalFilteringTime / Double(filteringOperations) * 1000.0 : 0 // in ms
            
            print("📊 Recipe Filter Performance:")
            print("  - Cache hit rate: \(String(format: "%.1f", hitRate))%")
            print("  - Average filtering time: \(String(format: "%.2f", avgTime)) ms")
            print("  - Total operations: \(filteringOperations)")
        }
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
