import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @ObservedObject var viewModel: ShoppingListViewModel
    @ObservedObject var recipesViewModel: RecipesViewModel
    @State private var showingAddToListConfirmation = false
    @State private var showingSaveConfirmation = false
    @State private var scale: CGFloat = 1.0
    @State private var showingCookingMode = false
    @State private var selectedTab = 0
    @State private var showAddedToast = false
    
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
        // Check for cooking mode
        if showingCookingMode {
            cookingModeView
        } else {
            // Regular recipe view
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header section
                        recipeHeaderSection
                        
                        // Action buttons section
                        actionButtonsSection
                        
                        // Tabbed view for ingredients and instructions
                        VStack(spacing: 8) {
                            // Tab selection
                            HStack(spacing: 0) {
                                // Info tab
                                tabButton(title: "Overview", index: 0)
                                
                                // Ingredients tab
                                tabButton(title: "Ingredients", index: 1)
                                
                                // Instructions tab
                                tabButton(title: "Instructions", index: 2)
                            }
                            .padding(.horizontal)
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                            .padding(.horizontal)
                            
                            // Tab content
                            tabSections
                        }
                    }
                    .padding()
                }
                
                toastView
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle(recipe.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: addIngredientsToShoppingList) {
                            Label("Add to Shopping List", systemImage: "cart.badge.plus")
                        }
                        
                        Button(action: saveRecipe) {
                            Label("Save Recipe", systemImage: "bookmark")
                        }
                        
                        Button(action: { showingCookingMode = true }) {
                            Label("Cooking Mode", systemImage: "timer")
                        }
                        
                        // Add sharing button in the future
                        Button(action: {}) {
                            Label("Share Recipe", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .alert("Added to Shopping List", isPresented: $showingAddToListConfirmation) {
                Button("OK", role: .cancel) { }
            }
            .alert("Recipe Saved", isPresented: $showingSaveConfirmation) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    // MARK: - View Components
    
    // Tab button
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = index
            }
        }) {
            Text(title)
                .font(.system(size: 15, weight: selectedTab == index ? .bold : .medium))
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == index ? AppTheme.primary : AppTheme.textSecondary)
                .background(
                    ZStack {
                        if selectedTab == index {
                            Capsule()
                                .fill(AppTheme.primary.opacity(0.1))
                        }
                    }
                )
        }
    }
    
    // Tab sections
    @ViewBuilder
    private var tabSections: some View {
        switch selectedTab {
        case 0:
            // Overview tab
            recipeOverviewTab
                .transition(.opacity)
        case 1:
            // Ingredients tab
            ingredientsSection
                .transition(.opacity)
        case 2:
            // Instructions tab
            instructionsSection
                .transition(.opacity)
        default:
            EmptyView()
        }
        
        // Similar recipes shown at the bottom, regardless of the selected tab
        // Only show if we have similar recipes
        if !recipesViewModel.recipes.isEmpty {
            similarRecipesSection
                .padding(.top)
        }
    }
    
    // Recipe overview tab content
    private var recipeOverviewTab: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Recipe basic info (time, servings, etc.)
            recipeInfoRow
            
            // Recipe Facts section
            recipeFacts
            
            // Nutritional info if available
            if let nutrition = recipe.nutritionalInfo {
                // Nutrition section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Nutritional Info")
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                        .padding(.top, 8)
                    
                    // Nutrition bars
                    nutritionBars(for: nutrition)
                }
            }
            
            // Dietary tags if present
            if !recipe.dietaryTags.isEmpty {
                dietaryTagsSection
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .padding(.horizontal)
    }
    
    // Recipe header with image and basic info
    private var recipeHeaderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Recipe image
            recipeImage
            
            // Recipe name
            Text(recipe.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.text)
        }
    }
    
    // Recipe image
    private var recipeImage: some View {
        ZStack {
            CachedImage(
                imageName: recipe.imageName,
                category: recipe.category,
                contentMode: .fill,
                cornerRadius: 12,
                size: CGSize(width: UIScreen.main.bounds.width, height: 250),
                backgroundColor: Color(.systemGray5),
                placeholderScale: 0.5
            )
            .frame(height: 250)
            .clipped()
            
            // Add to cart button in corner
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button(action: {
                        recipesViewModel.addAllMissingIngredients(from: recipe)
                        showAddedToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showAddedToast = false
                            }
                        }
                    }) {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(AppTheme.primary))
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                    }
                    .padding([.trailing, .bottom], 16)
                }
            }
        }
    }
    
    // Action buttons section
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            // Add to list button
            Button(action: addIngredientsToShoppingList) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("Add to List")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            
            // Save recipe button
            Button(action: saveRecipe) {
                HStack {
                    Image(systemName: "bookmark")
                    Text("Save Recipe")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.secondary)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: AppTheme.secondary.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    // Dietary tags section
    private var dietaryTagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dietary Tags")
                .font(.headline)
                .foregroundColor(AppTheme.text)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(recipe.dietaryTags), id: \.self) { tag in
                        HStack(spacing: 6) {
                            // Icon based on dietary tag
                            Image(systemName: iconForDietaryTag(tag))
                                .font(.system(size: 12))
                                .foregroundColor(colorForDietaryTag(tag))
                            
                            Text(tag.rawValue)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.text)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(colorForDietaryTag(tag).opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(colorForDietaryTag(tag).opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.bottom, 4)
            }
            
            // Diet description if there are dietary tags
            if !recipe.dietaryTags.isEmpty {
                Text(dietDescriptionForTags())
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.top, 4)
                    .lineLimit(3)
            }
        }
    }
    
    // Helper to get icon for dietary tag
    private func iconForDietaryTag(_ tag: Recipe.DietaryTag) -> String {
        switch tag {
        case .vegetarian:
            return "leaf"
        case .vegan:
            return "leaf.fill"
        case .glutenFree:
            return "allergens"
        case .dairyFree:
            return "drop.triangle"
        case .keto:
            return "k.circle"
        case .lowCarb:
            return "chart.bar.fill"
        case .paleo:
            return "fossil.shell"
        default:
            return "tag"
        }
    }
    
    // Helper to get color for dietary tag
    private func colorForDietaryTag(_ tag: Recipe.DietaryTag) -> Color {
        switch tag {
        case .vegetarian, .vegan:
            return .green
        case .glutenFree, .dairyFree:
            return .orange
        case .keto, .lowCarb:
            return .blue
        case .paleo:
            return .brown
        default:
            return .gray
        }
    }
    
    // Helper to generate a description of the diet based on tags
    private func dietDescriptionForTags() -> String {
        var descriptions: [String] = []
        
        let tags = Array(recipe.dietaryTags)
        
        if tags.contains(.vegetarian) {
            descriptions.append("Suitable for vegetarian diets")
        }
        
        if tags.contains(.vegan) {
            descriptions.append("Plant-based recipe with no animal products")
        }
        
        if tags.contains(.glutenFree) {
            descriptions.append("Contains no wheat or gluten")
        }
        
        if tags.contains(.dairyFree) {
            descriptions.append("Contains no milk, cheese, or dairy products")
        }
        
        if tags.contains(.keto) {
            descriptions.append("High fat, moderate protein, very low carb")
        }
        
        if tags.contains(.lowCarb) {
            descriptions.append("Reduced carbohydrate content")
        }
        
        if descriptions.isEmpty {
            return "Standard recipe with no specific dietary accommodations."
        }
        
        return descriptions.joined(separator: ". ") + "."
    }
    
    // Recipe info row (time, servings, etc.)
    private var recipeInfoRow: some View {
        VStack(alignment: .leading, spacing: 16) {
            // First row with basic info
            HStack(spacing: 16) {
                // Format total time
                let cookingTime = formatTime(recipe.estimatedTime)
                
                RecipeInfoItem(systemImage: "clock", text: cookingTime)
                RecipeInfoItem(systemImage: "person.2", text: "\(recipe.servings) servings")
                
                if let nutrition = recipe.nutritionalInfo {
                    RecipeInfoItem(systemImage: "flame", text: "\(nutrition.calories) cal")
                } else {
                    RecipeInfoItem(systemImage: "flame", text: "---")
                }
            }
            
            // Second row with detailed timing and difficulty
            HStack(spacing: 16) {
                // Display prep time if available
                if recipe.prepTime > 0 {
                    RecipeInfoItem(systemImage: "knife", text: "Prep: \(formatTime(recipe.prepTime))")
                }
                
                // Display cook time if available
                if recipe.cookTime > 0 {
                    RecipeInfoItem(systemImage: "cooktop", text: "Cook: \(formatTime(recipe.cookTime))")
                }
                
                // Display difficulty
                let difficultyIcon = getDifficultyIcon(for: recipe.difficulty)
                RecipeInfoItem(systemImage: difficultyIcon, text: recipe.difficulty.rawValue)
            }
            
            // Category badge
            if recipe.category != .other {
                Text(recipe.category.rawValue)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(getCategoryColor(for: recipe.category).opacity(0.2))
                    .foregroundColor(getCategoryColor(for: recipe.category))
                    .clipShape(Capsule())
            }
            
            // Recipe source if available
            if let source = recipe.source, !source.isEmpty {
                Text("Source: \(source)")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .italic()
            }
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
    
    // Ingredients section
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Break down the ingredient list into a separate ForEach
            ForEach(recipe.ingredients, id: \.id) { ingredient in
                RecipeIngredientRow(ingredient: ingredient)
            }
            
            // Add missing ingredients button
            Button(action: addIngredientsToShoppingList) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("Add All to Shopping List")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .padding()
                .background(AppTheme.primary.opacity(0.1))
                .foregroundColor(AppTheme.primary)
                .cornerRadius(10)
                .padding(.top, 8)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .padding(.horizontal)
    }
    
    // Instructions section
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Instruction overview
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(recipe.instructions.count) Steps")
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                    
                    Text(estimatedTimePerStep())
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                // Cooking mode button (compact version)
                Button(action: { showingCookingMode = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                        Text("Cooking Mode")
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Break down the instructions list into a separate ForEach
            ForEach(Array(recipe.instructions.enumerated()), id: \.element) { index, instruction in
                enhancedInstructionRow(index: index + 1, instruction: instruction)
            }
            
            // Full-width cooking mode button at the bottom
            Button(action: { showingCookingMode = true }) {
                HStack {
                    Image(systemName: "timer")
                    Text("Start Cooking Mode")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppTheme.primary.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(AppTheme.primary.opacity(0.3), lineWidth: 1)
                        )
                )
                .foregroundColor(AppTheme.primary)
                .padding(.top, 8)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .padding(.horizontal)
    }
    
    // Cooking mode instruction row with expanded functionality
    private func cookingModeInstructionRow(index: Int, instruction: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Step indicator with progress visual
                ZStack {
                    Circle()
                        .fill(getStepColor(index: index, totalSteps: recipe.instructions.count))
                        .frame(width: 32, height: 32)
                    
                    Text("\(index)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Text("Step \(index)")
                    .font(.headline)
                    .foregroundColor(AppTheme.text)
                
                Spacer()
                
                // Timer button for this step
                Button(action: {
                    // This would set a timer for this step
                    selectedTab = 3 // Switch to timer tab
                }) {
                    HStack(spacing: 4) {
                        Text(formatTime(estimatedTimeForStep(index: index)))
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Image(systemName: "timer")
                            .font(.caption)
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .stroke(AppTheme.primary.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            
            Text(instruction)
                .font(.body)
                .foregroundColor(AppTheme.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 4)
                .lineSpacing(4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.7))
        )
    }
    
    // Enhanced instruction row for the normal recipe detail view
    private func enhancedInstructionRow(index: Int, instruction: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Step number with dynamic color based on progress
            ZStack {
                Circle()
                    .fill(getStepColor(index: index, totalSteps: recipe.instructions.count))
                    .frame(width: 30, height: 30)
                
                Text("\(index)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Instruction text
                Text(instruction)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                
                // Estimated time for this step (more prominent for longer steps)
                let stepTime = estimatedTimeForStep(index: index)
                if stepTime >= 60 {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .font(.system(size: 12))
                        
                        Text("\(formatTime(stepTime))")
                            .font(.caption)
                        
                        Spacer()
                    }
                    .foregroundColor(getStepColor(index: index, totalSteps: recipe.instructions.count))
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6).opacity(0.5))
                .padding(.horizontal)
        )
    }
    
    // Helper method to get estimated time per step
    private func estimatedTimePerStep() -> String {
        let totalMinutes = Int(recipe.estimatedTime / 60)
        let stepsCount = recipe.instructions.count
        
        if stepsCount == 0 || totalMinutes == 0 {
            return "No time estimate available"
        }
        
        // Simple average time per step
        let minutesPerStep = max(1, totalMinutes / stepsCount)
        return "About \(minutesPerStep) min per step on average"
    }
    
    // Helper method to estimate time for a specific step
    private func estimatedTimeForStep(index: Int) -> TimeInterval {
        let totalTime = recipe.estimatedTime
        let totalSteps = recipe.instructions.count
        
        if totalSteps == 0 {
            return 0
        }
        
        // Weight longer for middle steps, shorter for beginning and end steps
        let step = index - 1 // 0-based index
        
        // More complex distribution that weights middle steps higher
        let normalizedPosition = Double(step) / Double(totalSteps - 1) // 0.0 to 1.0
        
        // Bell curve distribution with peak in the middle
        let weight = 1.0 - 2.0 * abs(normalizedPosition - 0.5) // Peak at 0.5
        
        // Apply weighting but ensure all steps get at least some minimum time
        let baseTimePerStep = totalTime / Double(totalSteps)
        let variableComponent = baseTimePerStep * 0.5 // 50% of base time can vary
        
        return baseTimePerStep + (variableComponent * weight)
    }
    
    // Helper method to get a color for a step based on its position
    private func getStepColor(index: Int, totalSteps: Int) -> Color {
        let progress = Double(index) / Double(max(1, totalSteps))
        
        // Color gradient from green (start) to orange (middle) to red (end)
        if progress < 0.33 {
            return .green
        } else if progress < 0.66 {
            return .orange
        } else {
            return AppTheme.primary
        }
    }
    
    // Nutrition visualization
    private func nutritionBars(for nutrition: NutritionInfo) -> some View {
        VStack(spacing: 16) {
            // Summary at the top
            HStack(spacing: 20) {
                // Calories summary
                VStack(spacing: 4) {
                    Text("Calories")
                        .font(.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("\(nutrition.calories)")
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                
                // Macro percentages
                let totalMacros = Double(nutrition.protein + nutrition.carbs + nutrition.fat)
                
                // Protein summary
                MacroSummary(
                    name: "Protein",
                    value: "\(nutrition.protein)g",
                    percent: totalMacros > 0 ? Int((Double(nutrition.protein) / totalMacros) * 100) : 0,
                    color: .blue
                )
                
                // Carbs summary
                MacroSummary(
                    name: "Carbs",
                    value: "\(nutrition.carbs)g",
                    percent: totalMacros > 0 ? Int((Double(nutrition.carbs) / totalMacros) * 100) : 0,
                    color: .green
                )
                
                // Fat summary
                MacroSummary(
                    name: "Fat",
                    value: "\(nutrition.fat)g",
                    percent: totalMacros > 0 ? Int((Double(nutrition.fat) / totalMacros) * 100) : 0,
                    color: .red
                )
            }
            .padding(10)
            .background(AppTheme.cardBackground.opacity(0.5))
            .cornerRadius(10)
            
            Divider()
                .padding(.vertical, 4)
            
            // Detailed nutrition bars
            VStack(spacing: 12) {
                // Calories
                NutritionBar(
                    title: "Calories",
                    value: "\(nutrition.calories)",
                    percentage: 100,
                    color: .orange
                )
                
                // Protein
                NutritionBar(
                    title: "Protein",
                    value: "\(nutrition.protein)g",
                    percentage: Double(nutrition.protein) / Double(nutrition.calories) * 400,
                    color: .blue
                )
                
                // Carbs
                NutritionBar(
                    title: "Carbs",
                    value: "\(nutrition.carbs)g",
                    percentage: Double(nutrition.carbs) / Double(nutrition.calories) * 400,
                    color: .green
                )
                
                // Fat
                NutritionBar(
                    title: "Fat",
                    value: "\(nutrition.fat)g",
                    percentage: Double(nutrition.fat) / Double(nutrition.calories) * 400,
                    color: .red
                )
            }
        }
    }
    
    // Recipe facts section
    private var recipeFacts: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recipe Facts")
                .font(.headline)
                .foregroundColor(AppTheme.text)
            
            VStack(spacing: 12) {
                // Difficulty level
                HStack {
                    Image(systemName: getDifficultyIcon(for: recipe.difficulty))
                        .foregroundColor(getDifficultyColor(for: recipe.difficulty))
                        .frame(width: 24, height: 24)
                    
                    Text("Difficulty")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Spacer()
                    
                    Text(recipe.difficulty.rawValue)
                        .font(.subheadline.bold())
                        .foregroundColor(getDifficultyColor(for: recipe.difficulty))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(getDifficultyColor(for: recipe.difficulty).opacity(0.1))
                .cornerRadius(8)
                
                // Time breakdown
                if recipe.prepTime > 0 || recipe.cookTime > 0 {
                    HStack(alignment: .top) {
                        // Prep time
                        VStack(spacing: 4) {
                            Image(systemName: "knife")
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(height: 20)
                            
                            Text("Prep")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text(formatTime(recipe.prepTime))
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.text)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Cook time
                        VStack(spacing: 4) {
                            Image(systemName: "cooktop")
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(height: 20)
                            
                            Text("Cook")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text(formatTime(recipe.cookTime))
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.text)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Total time
                        VStack(spacing: 4) {
                            Image(systemName: "clock")
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(height: 20)
                            
                            Text("Total")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text(formatTime(recipe.estimatedTime))
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.text)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Ingredients count and info
                HStack {
                    Image(systemName: "list.bullet")
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(recipe.ingredients.count) Ingredients")
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.text)
                        
                        if !recipe.missingIngredients.isEmpty {
                            Text("Missing \(recipe.missingIngredients.count) ingredients")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                    
                    Text("\(recipe.servings) servings")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Source if available
                if let source = recipe.source, !source.isEmpty {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(width: 24, height: 24)
                        
                        Text("Source:")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Spacer()
                        
                        Text(source)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.primary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // Helper to get color for recipe difficulty
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
    
    // MARK: - Cooking Mode View
    
    private var cookingModeView: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header with title and close button
                ZStack {
                    Text(recipe.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    HStack {
                        Spacer()
                        Button(action: { showingCookingMode = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                .padding()
                .background(
                    AppTheme.cardBackground
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                )
                
                // Tab selection
                HStack(spacing: 0) {
                    Button(action: { selectedTab = 1 }) {
                        VStack(spacing: 2) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 16))
                            Text("Ingredients")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == 1 ? AppTheme.primary : Color.clear)
                        .foregroundColor(selectedTab == 1 ? .white : AppTheme.textSecondary)
                    }
                    
                    Button(action: { selectedTab = 2 }) {
                        VStack(spacing: 2) {
                            Image(systemName: "list.number")
                                .font(.system(size: 16))
                            Text("Steps")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == 2 ? AppTheme.primary : Color.clear)
                        .foregroundColor(selectedTab == 2 ? .white : AppTheme.textSecondary)
                    }
                    
                    Button(action: { selectedTab = 3 }) {
                        VStack(spacing: 2) {
                            Image(systemName: "timer")
                                .font(.system(size: 16))
                            Text("Timer")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == 3 ? AppTheme.primary : Color.clear)
                        .foregroundColor(selectedTab == 3 ? .white : AppTheme.textSecondary)
                    }
                }
                .background(AppTheme.cardBackground)
                
                // Tab content based on selection
                if selectedTab == 1 {
                    // Ingredients list with checkboxes
                    ingredientsCookingView
                } else if selectedTab == 2 {
                    // Steps list with interactive elements
                    stepsCookingView
                } else {
                    // Timer with presets based on recipe steps
                    timerView
                }
                
                // Bottom toolbar with quick actions
                HStack(spacing: 20) {
                    Button(action: addIngredientsToShoppingList) {
                        VStack(spacing: 2) {
                            Image(systemName: "cart.badge.plus")
                                .font(.system(size: 14))
                            Text("Shopping List")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .foregroundColor(AppTheme.text)
                        .cornerRadius(8)
                    }
                    
                    Button(action: saveRecipe) {
                        VStack(spacing: 2) {
                            Image(systemName: "bookmark")
                                .font(.system(size: 14))
                            Text("Save")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .foregroundColor(AppTheme.text)
                        .cornerRadius(8)
                    }
                    
                    // Share button
                    Button(action: {
                        // Share functionality would go here
                    }) {
                        VStack(spacing: 2) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14))
                            Text("Share")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .foregroundColor(AppTheme.text)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(AppTheme.cardBackground.shadow(radius: 2))
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .background(AppTheme.background.edgesIgnoringSafeArea(.all))
    }
    
    // Ingredients view for cooking mode
    private var ingredientsCookingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // Section title
                HStack {
                    Text("Ingredients")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(recipe.ingredients.count) items")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Servings adjustment
                HStack {
                    Text("Servings:")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("\(recipe.servings)")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.text)
                        .frame(width: 30, alignment: .center)
                    
                    // In a real app, this would adjust quantities
                    HStack(spacing: 8) {
                        Button(action: {}) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(AppTheme.primary)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                Divider()
                    .padding(.horizontal)
                
                // Grouped ingredients by category
                VStack(alignment: .leading, spacing: 16) {
                    let groupedIngredients = Dictionary(grouping: recipe.ingredients) { $0.category }
                    
                    ForEach(IngredientCategory.allCases, id: \.self) { category in
                        if let ingredients = groupedIngredients[category], !ingredients.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.primary)
                                    .padding(.horizontal)
                                
                                ForEach(ingredients) { ingredient in
                                    RecipeIngredientCheckRow(ingredient: ingredient)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .padding(.bottom, 20)
        }
    }
    
    // Steps view for cooking mode
    private var stepsCookingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Overview
                HStack {
                    Text("Steps")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("Total time: \(formatTime(recipe.estimatedTime))")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal)
                .padding(.top)
                
                Divider()
                    .padding(.horizontal)
                
                // Interactive steps
                ForEach(Array(recipe.instructions.enumerated()), id: \.element) { index, instruction in
                    cookingModeInstructionRow(index: index + 1, instruction: instruction)
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // Timer view
    private var timerView: some View {
        VStack(spacing: 20) {
            // Current timer display
            ZStack {
                Circle()
                    .stroke(AppTheme.primary.opacity(0.2), lineWidth: 15)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: 0.65) // This would be animated in a real implementation
                    .stroke(AppTheme.primary, lineWidth: 15)
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 8) {
                    Text("12:34")
                        .font(.system(size: 42, weight: .medium, design: .monospaced))
                        .foregroundColor(AppTheme.text)
                    
                    Text("remaining")
                        .font(.callout)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.vertical, 30)
            
            // Timer controls
            HStack(spacing: 30) {
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "pause.fill")
                            .font(.title)
                            .foregroundColor(AppTheme.text)
                    }
                }
                
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primary)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                            .foregroundColor(AppTheme.text)
                    }
                }
            }
            
            // Common timer presets
            VStack(alignment: .leading, spacing: 12) {
                Text("Presets")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        timerPresetButton(time: "1:00", label: "Quick Timer")
                        timerPresetButton(time: "5:00", label: "Short Timer")
                        timerPresetButton(time: "10:00", label: "Medium Timer")
                        timerPresetButton(time: "30:00", label: "Long Timer")
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.top)
    }
    
    // Timer preset button
    private func timerPresetButton(time: String, label: String) -> some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                Text(time)
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(AppTheme.text)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    // MARK: - Supporting Functions
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours) hr \(remainingMinutes) min"
        }
    }
    
    private func addIngredientsToShoppingList() {
        for ingredient in recipe.ingredients {
            viewModel.addItem(ingredient)
        }
        showingAddToListConfirmation = true
        
        // Haptic feedback on add
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func saveRecipe() {
        recipesViewModel.addToRecipeList(recipe)
        showingSaveConfirmation = true
        
        // Haptic feedback on save
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // Similar recipes section
    private var similarRecipesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section title
            Text("You might also like")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Similar recipes carousel
            let similarRecipes = recipesViewModel.findSimilarRecipes(to: recipe)
            if similarRecipes.isEmpty {
                Text("No similar recipes found")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(similarRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(
                                recipe: recipe,
                                viewModel: viewModel,
                                recipesViewModel: recipesViewModel
                            )) {
                                similarRecipeCard(recipe)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // Card for similar recipe
    private func similarRecipeCard(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Recipe image
            CachedImage(
                imageName: recipe.imageName,
                category: recipe.category,
                contentMode: .fill,
                cornerRadius: 8,
                size: CGSize(width: 140, height: 100)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Recipe name
            Text(recipe.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.text)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)
            
            // Recipe info (time and difficulty)
            HStack(spacing: 8) {
                // Time
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(formatTimeShort(recipe.estimatedTime))
                        .font(.system(size: 10))
                }
                .foregroundColor(AppTheme.textSecondary)
                
                // Difficulty
                HStack(spacing: 4) {
                    Image(systemName: recipe.difficulty == .easy ? "tortoise" : "hare")
                        .font(.system(size: 10))
                    Text(recipe.difficulty.rawValue)
                        .font(.system(size: 10))
                }
                .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(width: 140)
        .padding(.bottom, 8)
    }
    
    // Time formatter for compact display
    private func formatTimeShort(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
        }
    }
}

// MARK: - Supporting Views

// Single ingredient row
struct RecipeIngredientRow: View {
    let ingredient: Ingredient
    
    var body: some View {
        HStack {
            Text("•")
                .foregroundColor(AppTheme.primary)
                .font(.headline)
            
            // Format the amount and unit
            let formattedAmount = formatAmount(ingredient.amount)
            let unitText = ingredient.unit.rawValue
            
            Text("\(formattedAmount) \(unitText) \(ingredient.name)")
                .foregroundColor(AppTheme.text)
        }
        .padding(.vertical, 4)
    }
    
    // Simplified amount formatting
    private func formatAmount(_ value: Double) -> String {
        if value == floor(value) {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// Checkable ingredient row for cooking mode
struct RecipeIngredientCheckRow: View {
    let ingredient: Ingredient
    @State private var isChecked = false
    
    var body: some View {
        HStack {
            Button(action: { isChecked.toggle() }) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? AppTheme.primary : AppTheme.textSecondary)
            }
            
            // Format the amount and unit
            let formattedAmount = formatAmount(ingredient.amount)
            let unitText = ingredient.unit.rawValue
            
            Text("\(formattedAmount) \(unitText) \(ingredient.name)")
                .foregroundColor(isChecked ? AppTheme.textSecondary : AppTheme.text)
                .strikethrough(isChecked)
        }
        .padding(.vertical, 8)
    }
    
    // Simplified amount formatting
    private func formatAmount(_ value: Double) -> String {
        if value == floor(value) {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// Recipe info item (used in the info row)
struct RecipeInfoItem: View {
    let systemImage: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.subheadline)
            
            Text(text)
                .font(.subheadline)
        }
        .foregroundColor(AppTheme.textSecondary)
    }
}

// Nutrition bar
struct NutritionBar: View {
    let title: String
    let value: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.text)
                
                Spacer()
                
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppTheme.text)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: min(CGFloat(percentage) / 100 * geometry.size.width, geometry.size.width), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }
}

// Macro summary component for nutrition display
struct MacroSummary: View {
    let name: String
    let value: String
    let percent: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.footnote)
                .foregroundColor(AppTheme.textSecondary)
            
            Text(value)
                .font(.headline)
                .foregroundColor(AppTheme.text)
                .fontWeight(.bold)
            
            Text("\(percent)%")
                .font(.caption)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

// Toast notification view for RecipeDetailView
private extension RecipeDetailView {
    var toastView: some View {
        VStack {
            Spacer()
            
            if showAddedToast {
                HStack(spacing: 12) {
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.primary)
                    
                    Text("Added missing ingredients to your shopping list")
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
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showAddedToast)
            }
        }
    }
} 