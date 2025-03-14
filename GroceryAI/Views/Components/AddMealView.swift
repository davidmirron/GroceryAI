import SwiftUI

/// View for adding a meal to the meal plan
/// - Contains both recipe selection and custom meal creation
/// - Uses smooth animations and transitions
/// - Organizes content for better information density
struct AddMealView: View {
    let mealType: MealType
    let date: Date
    @ObservedObject var viewModel: MealPlanViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    @State private var selectedTab = 0 // 0 = Recipes, 1 = Custom
    @State private var customMealName = ""
    @State private var customMealEmoji = "🍽️"
    @State private var customMealCalories = ""
    @State private var selectedEmoji = false
    
    // Common emojis for meal types
    private let foodEmojis = ["🍎", "🥑", "🍌", "🥐", "🍞", "🥗", "🍕", "🌮", "🍜", "🍚", "🍣", "🍔", "🥤", "☕️", "🍰", "🍦"]
    
    // Popular emojis for each meal type
    private var suggestedEmojis: [String] {
        switch mealType {
        case .breakfast:
            return ["🥐", "🍳", "🥞", "🥓", "☕️", "🥛", "🍊", "🥪", "🥣", "🥯"]
        case .lunch:
            return ["🥗", "🍕", "🌮", "🥙", "🍜", "🍱", "🍙", "🥪", "🍔", "🍟"]
        case .dinner:
            return ["🍝", "🍛", "🍲", "🥘", "🍚", "🍖", "🍗", "🥩", "🌯", "🍣"]
        case .snack:
            return ["🍎", "🍌", "🥜", "🧀", "🥤", "🍪", "🍦", "🍭", "🍇", "🥨"]
        }
    }
    
    // Filtered recipes based on search text
    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return viewModel.recipes
        } else {
            return viewModel.recipes.filter { recipe in
                recipe.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Quick suggestions based on meal type
    private var quickSuggestions: [Recipe] {
        viewModel.suggestedRecipe(for: mealType, limit: 4)
    }
    
    private var recentCustomMeals: [CustomMeal] {
        CustomMeal.sampleData.filter { $0.mealType == mealType }
    }
    
    // Check if we have valid input for a custom meal
    private var isCustomMealValid: Bool {
        !customMealName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            Picker("Meal Type", selection: $selectedTab) {
                Text("Recipes").tag(0)
                Text("Custom Meal").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top)
            
            // Content based on selected tab
            if selectedTab == 0 {
                recipesTab
            } else {
                customMealTab
            }
            
            // Bottom action button
            actionButton
                .padding()
                .background(AppTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
        }
    }
    
    // MARK: - Recipes Tab
    
    private var recipesTab: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar
                .padding(.horizontal)
                .padding(.top, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Quick suggestions section
                    if !quickSuggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Suggestions for \(mealType.displayName)")
                                .font(.headline)
                                .foregroundColor(AppTheme.text)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(quickSuggestions) { recipe in
                                        suggestionCard(for: recipe)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 16)
                    }
                    
                    // Available recipes section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(searchText.isEmpty ? "All Recipes" : "Search Results")
                                .font(.headline)
                                .foregroundColor(AppTheme.text)
                            
                            Spacer()
                            
                            if !filteredRecipes.isEmpty {
                                Text("\(filteredRecipes.count) recipes")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Empty state when no recipes found
                        if filteredRecipes.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 36))
                                    .foregroundColor(AppTheme.secondaryText.opacity(0.7))
                                
                                Text("No recipes found")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.text)
                                
                                Text("Try a different search term or create a custom meal instead")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.secondaryText)
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    withAnimation {
                                        selectedTab = 1
                                    }
                                } label: {
                                    Text("Create Custom Meal")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Capsule().fill(mealType.themeColor))
                                }
                                .padding(.top, 8)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        } else {
                            // List of recipes
                            ForEach(filteredRecipes) { recipe in
                                recipeRow(for: recipe)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        // Add recipe to meal plan
                                        addRecipeToMealPlan(recipe)
                                    }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.bottom, 100) // Extra padding for bottom content
            }
        }
    }
    
    // MARK: - Custom Meal Tab
    
    private var customMealTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meal Name")
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                    
                    TextField("Enter meal name", text: $customMealName)
                        .padding()
                        .background(AppTheme.textFieldBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppTheme.borderColor, lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Emoji selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose an emoji")
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                    
                    // Selected emoji display
                    Button {
                        withAnimation {
                            selectedEmoji.toggle()
                        }
                    } label: {
                        HStack {
                            Text(customMealEmoji)
                                .font(.system(size: 36))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(AppTheme.textFieldBackground)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(AppTheme.borderColor, lineWidth: 1)
                                )
                            
                            Text("Tap to change")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.secondaryText)
                        }
                    }
                    
                    // Emoji picker
                    if selectedEmoji {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Suggested for \(mealType.displayName)")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.secondaryText)
                            
                            // Suggested emojis for this meal type
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                                ForEach(suggestedEmojis, id: \.self) { emoji in
                                    Button {
                                        customMealEmoji = emoji
                                        selectedEmoji = false
                                    } label: {
                                        Text(emoji)
                                            .font(.system(size: 30))
                                            .frame(width: 50, height: 50)
                                            .background(
                                                customMealEmoji == emoji ?
                                                AppTheme.secondary.opacity(0.2) : Color.clear
                                            )
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            Text("Other Food Emojis")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.secondaryText)
                            
                            // All food emojis
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                                ForEach(foodEmojis, id: \.self) { emoji in
                                    Button {
                                        customMealEmoji = emoji
                                        selectedEmoji = false
                                    } label: {
                                        Text(emoji)
                                            .font(.system(size: 30))
                                            .frame(width: 50, height: 50)
                                            .background(
                                                customMealEmoji == emoji ?
                                                AppTheme.secondary.opacity(0.2) : Color.clear
                                            )
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal)
                
                // Calories input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calories (optional)")
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                    
                    TextField("Enter calories", text: $customMealCalories)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(AppTheme.textFieldBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppTheme.borderColor, lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                // Recent custom meals
                if !recentCustomMeals.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Custom Meals")
                            .font(.headline)
                            .foregroundColor(AppTheme.text)
                        
                        ForEach(recentCustomMeals) { meal in
                            Button {
                                // Set this as the current custom meal
                                customMealName = meal.name
                                customMealEmoji = meal.emoji
                                if let calories = meal.calories {
                                    customMealCalories = "\(calories)"
                                }
                            } label: {
                                HStack {
                                    Text(meal.emoji)
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading) {
                                        Text(meal.name)
                                            .font(.subheadline.bold())
                                            .foregroundColor(AppTheme.text)
                                        
                                        if let calories = meal.calories {
                                            Text("\(calories) calories")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.secondaryText)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(mealType.themeColor)
                                }
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(AppTheme.borderColor, lineWidth: 1)
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 100) // Extra space for button
            }
        }
    }
    
    // MARK: - Component Views
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.secondaryText)
            
            TextField("Search recipes", text: $searchText)
                .foregroundColor(AppTheme.text)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(AppTheme.textFieldBackground)
        .cornerRadius(10)
        .animation(.spring(response: 0.3), value: searchText)
    }
    
    private func suggestionCard(for recipe: Recipe) -> some View {
        VStack(alignment: .leading) {
            // Image or placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(mealType.themeColor.opacity(0.2))
                .frame(width: 150, height: 100)
                .overlay(
                    Image(systemName: "fork.knife")
                        .foregroundColor(mealType.themeColor)
                        .font(.system(size: 24))
                )
            
            Text(recipe.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.text)
                .lineLimit(2)
                .frame(width: 150, alignment: .leading)
        }
        .frame(width: 150)
        .padding(.bottom, 8)
        .background(AppTheme.cardBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .onTapGesture {
            addRecipeToMealPlan(recipe)
        }
    }
    
    private func recipeRow(for recipe: Recipe) -> some View {
        HStack(spacing: 12) {
            // Image or placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(mealType.themeColor.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "fork.knife")
                        .foregroundColor(mealType.themeColor)
                )
            
            // Recipe details
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.text)
                
                Text("10 min • 320 calories")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
            }
            
            Spacer()
            
            // Add button
            Button {
                addRecipeToMealPlan(recipe)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(mealType.themeColor)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.vertical, 8)
        .background(AppTheme.cardBackground)
        .cornerRadius(10)
    }
    
    private var actionButton: some View {
        Button(action: {
            if selectedTab == 0 {
                // This is handled by the individual recipe buttons
            } else {
                addCustomMealToMealPlan()
            }
        }) {
            HStack {
                Spacer()
                Text(selectedTab == 0 ? "Select a Recipe" : "Add Custom Meal")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 15)
            .background(
                Capsule()
                    .fill(selectedTab == 0 ? AppTheme.secondary : isCustomMealValid ? mealType.themeColor : AppTheme.secondaryText)
            )
            .opacity(selectedTab == 0 || isCustomMealValid ? 1.0 : 0.5)
        }
        .disabled(selectedTab == 0 || !isCustomMealValid)
        .animation(.spring(response: 0.3), value: selectedTab)
        .animation(.spring(response: 0.3), value: isCustomMealValid)
    }
    
    // MARK: - Actions
    
    private func addRecipeToMealPlan(_ recipe: Recipe) {
        // Create a new meal from the recipe
        let meal = Meal(
            id: UUID(),
            name: recipe.name,
            recipeId: recipe.id,
            date: date,
            calories: recipe.nutritionalInfo?.calories,
            mealType: mealType,
            emoji: nil
        )
        
        // Add to the meal plan
        withAnimation {
            viewModel.addMeal(meal)
            
            // Provide haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Dismiss sheet
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func addCustomMealToMealPlan() {
        // Get calories as int if available
        let caloriesInt = Int(customMealCalories) ?? 0
        
        // Create a new meal
        let meal = Meal(
            id: UUID(),
            name: customMealName.trimmingCharacters(in: .whitespacesAndNewlines),
            recipeId: nil, // nil for custom meals
            date: date,
            calories: caloriesInt > 0 ? caloriesInt : nil,
            mealType: mealType,
            emoji: customMealEmoji
        )
        
        // Add to the meal plan
        withAnimation {
            viewModel.addMeal(meal)
            
            // Provide haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Dismiss the sheet
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    AddMealView(
        mealType: .breakfast,
        date: Date(),
        viewModel: MealPlanViewModel()
    )
} 