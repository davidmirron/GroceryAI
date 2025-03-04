import SwiftUI

// MARK: - Clean, Minimal Progress Indicator
struct ProgressBar: View {
    let value: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...total, id: \.self) { step in
                Capsule()
                    .fill(step <= value ? AppTheme.primary : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .overlay(
                        step == value ? 
                            Capsule()
                                .stroke(AppTheme.primary, lineWidth: 1)
                                .blur(radius: 1)
                                .opacity(0.8)
                            : nil
                    )
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Form Navigation Protocol
/// A protocol for handling stepped form navigation
protocol SteppedFormNavigation {
    var currentStep: Int { get set }
    var totalSteps: Int { get }
    
    func canMoveToNextStep() -> Bool
    func canMoveToPreviousStep() -> Bool
    mutating func moveToNextStep()
    mutating func moveToPreviousStep()
}

// Default implementations
extension SteppedFormNavigation {
    func canMoveToPreviousStep() -> Bool {
        return currentStep > 1
    }
    
    func canMoveToNextStep() -> Bool {
        return currentStep < totalSteps
    }
    
    mutating func moveToNextStep() {
        if canMoveToNextStep() {
            currentStep += 1
        }
    }
    
    mutating func moveToPreviousStep() {
        if canMoveToPreviousStep() {
            currentStep -= 1
        }
    }
}

// Make RecipeFormState conform to SteppedFormNavigation
extension RecipeFormState: SteppedFormNavigation {
    mutating func moveToNextStep() {
        if canMoveToNextStep() {
            currentStep += 1
        }
    }
    
    mutating func moveToPreviousStep() {
        if canMoveToPreviousStep() {
            currentStep -= 1
        }
    }
}

// MARK: - Recipe Form State
/// A struct that encapsulates the state of the recipe form
struct RecipeFormState {
    var recipeName = ""
    var ingredientNames: [String] = [""]
    var ingredientAmounts: [Double] = [1.0]
    var ingredientUnits: [IngredientUnit] = [.pieces]
    var ingredientCategories: [IngredientCategory] = [.other]
    var instructions: [String] = [""]
    var cookingHours = 0
    var cookingMinutes = 30
    var servings = 4
    var selectedDietaryTags: Set<Recipe.DietaryTag> = []
    var currentStep = 1
    
    // Validation properties
    var showingValidationAlert = false
    var validationMessage = ""
    
    // UI state properties
    var showingSuccessToast = false
    
    /// Validates the form state and returns whether it's valid along with an error message if invalid
    func isValid() -> (Bool, String?) {
        // Check recipe name
        if recipeName.isEmpty {
            return (false, "Please enter a recipe name")
        }
        
        // Check for valid ingredients
        let validIngredientCount = zip(ingredientNames, zip(ingredientAmounts, zip(ingredientUnits, ingredientCategories)))
            .filter { !$0.0.isEmpty }
            .count
            
        if validIngredientCount == 0 {
            return (false, "Please add at least one ingredient")
        }
        
        // Check for valid instructions
        let validInstructionsCount = instructions.filter { !$0.isEmpty }.count
        if validInstructionsCount == 0 {
            return (false, "Please add at least one instruction step")
        }
        
        return (true, nil)
    }
    
    /// Builds a Recipe object from the form state if valid
    func buildRecipe() -> Recipe? {
        let (valid, _) = isValid()
        guard valid else { return nil }
        
        // Filter valid ingredients
        var validIngredients: [Ingredient] = []
        for i in 0..<ingredientNames.count {
            if !ingredientNames[i].isEmpty {
                let ingredient = Ingredient(
                    name: ingredientNames[i],
                    amount: ingredientAmounts[i],
                    unit: ingredientUnits[i],
                    category: ingredientCategories[i],
                    isPerishable: false
                )
                validIngredients.append(ingredient)
            }
        }
        
        // Filter valid instructions
        let validInstructions = instructions.filter { !$0.isEmpty }
        
        // Create and return recipe object
        return Recipe(
            name: recipeName,
            ingredients: validIngredients,
            instructions: validInstructions, 
            estimatedTime: TimeInterval((cookingHours * 60 + cookingMinutes) * 60),
            servings: servings,
            dietaryTags: selectedDietaryTags,
            imageName: getDefaultImageName(for: recipeName)
        )
    }
    
    /// Helper function to get default image name based on recipe name
    private func getDefaultImageName(for recipeName: String) -> String {
        let name = recipeName.lowercased()
        
        if name.contains("pizza") {
            return "pizza"
        } else if name.contains("pasta") || name.contains("spaghetti") {
            return "pasta"
        } else if name.contains("salad") {
            return "salad"
        } else if name.contains("soup") {
            return "soup"
        } else if name.contains("steak") || name.contains("beef") {
            return "steak"
        } else if name.contains("fish") || name.contains("salmon") {
            return "salmon"
        } else if name.contains("chicken") {
            return "chicken"
        } else if name.contains("breakfast") || name.contains("pancake") {
            return "breakfast"
        } else {
            return "default_recipe"
        }
    }
    
    // Form Navigation Methods
    var totalSteps: Int { return 3 }
    
    func canMoveToNextStep() -> Bool {
        switch currentStep {
        case 1:
            return !recipeName.isEmpty
        case 2:
            return ingredientNames.contains { !$0.isEmpty }
        case 3:
            return instructions.contains { !$0.isEmpty }
        default:
            return true
        }
    }
    
    func canMoveToPreviousStep() -> Bool {
        return currentStep > 1
    }
}

// MARK: - Ingredient Input Row
/// A reusable component for ingredient inputs
struct IngredientInputRow: View {
    @Binding var name: String
    @Binding var amount: Double
    @Binding var unit: IngredientUnit
    @Binding var category: IngredientCategory
    var index: Int
    var onDelete: () -> Void
    var showDeleteButton: Bool
    
    // Formatter for number input
    private let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.zeroSymbol = ""
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Ingredient header and delete button
            HStack {
                Text("Ingredient \(index + 1)")
                    .font(.headline)
                
                Spacer()
                
                if showDeleteButton {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Delete ingredient \(index + 1)")
                }
            }
            .foregroundColor(.secondary)
            
            // Ingredient name field
            TextField("Ingredient name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.next)
                .accessibilityLabel("Ingredient \(index + 1) name")
            
            // Amount and unit row
            HStack(spacing: 12) {
                // Amount input with stepper buttons
                HStack {
                    TextField("Amount", value: $amount, formatter: amountFormatter)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 80)
                        .accessibilityLabel("Amount for ingredient \(index + 1)")
                    
                    // Custom stepper
                    VStack(spacing: 5) {
                        Button(action: {
                            amount += 0.5
                        }) {
                            Image(systemName: "chevron.up")
                                .padding(3)
                        }
                        .accessibilityLabel("Increase amount")
                        
                        Button(action: {
                            if amount > 0.5 {
                                amount -= 0.5
                            }
                        }) {
                            Image(systemName: "chevron.down")
                                .padding(3)
                        }
                        .accessibilityLabel("Decrease amount")
                    }
                    .font(.caption)
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                }
                
                // Unit selector
                Menu {
                    ForEach(IngredientUnit.allCases, id: \.self) { unitOption in
                        Button(action: {
                            unit = unitOption
                        }) {
                            HStack {
                                Text(unitOption.rawValue)
                                if unit == unitOption {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(unit.rawValue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "chevron.down")
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                }
                .accessibilityLabel("Unit for ingredient \(index + 1)")
            }
            
            // Category selector
            Menu {
                ForEach(IngredientCategory.allCases, id: \.self) { categoryOption in
                    Button(action: {
                        category = categoryOption
                    }) {
                        HStack {
                            Text(categoryOption.rawValue.capitalized)
                            if category == categoryOption {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(category.rawValue.capitalized)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.down")
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
            .accessibilityLabel("Category for ingredient \(index + 1)")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Navigation Controls
struct NavigationControls: View {
    let currentStep: Int
    let totalSteps: Int
    let canGoBack: Bool
    let canContinue: Bool
    let onBack: () -> Void
    let onContinue: () -> Void
    let onSave: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            // Left side (Back button)
            if canGoBack {
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                        Text("Back")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .foregroundColor(AppTheme.primary)
                }
                .accessibility(label: Text("Go back to previous step"))
            } else {
                // Empty view to maintain alignment
                Spacer().frame(width: 80)
            }
            
            Spacer()
            
            // Right side (Next/Save button)
            Group {
                if currentStep == totalSteps {
                    // Final step - show save button
                    Button(action: onSave) {
                        HStack(spacing: 6) {
                            Text("Save Recipe")
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .frame(minWidth: 120)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(canContinue ? AppTheme.primary : Color.gray.opacity(0.5))
                        )
                        .contentShape(Rectangle())
                    }
                    .disabled(!canContinue)
                    .accessibilityLabel("Save recipe")
                    .accessibilityHint("Saves the recipe with the information provided")
                } else {
                    // Steps 1-2 - show continue button
                    Button(action: onContinue) {
                        HStack(spacing: 6) {
                            Text("Continue")
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .frame(minWidth: 120)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(canContinue ? AppTheme.primary : Color.gray.opacity(0.5))
                        )
                        .contentShape(Rectangle())
                    }
                    .disabled(!canContinue)
                    .accessibilityLabel("Continue to next step")
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 3, y: -2)
        )
    }
}

struct RecipeFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    
    // MARK: - Form State
    @State private var formState = RecipeFormState()
    
    // MARK: - UI State Properties
    // These properties are separate from the form data but affect the UI
    @State private var showingSuccessToast = false
    @State private var showingValidationAlert = false
    @State private var showSuccessAnimation = false
    @State private var showingActionSheet = false
    @State private var shouldNavigateToMyRecipes = false
    
    // Optional view model reference for enhanced integration
    var recipesViewModel: RecipesViewModel?
    
    // Formatter for number input
    private let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.zeroSymbol = ""
        return formatter
    }()
    
    // Callback for when a recipe is saved
    let onSave: (Recipe) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Use AppTheme.background to ensure dark mode compatibility
                AppTheme.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Progress View
                    ProgressBar(value: formState.currentStep, total: formState.totalSteps)
                        .padding(.horizontal, 24)
                        .padding(.top, 8) // Reduced top padding
                    
                    // Step Title - More compact
                    Text(stepTitle)
                        .font(.headline)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    
                    // Main Content - Step dependent
                    ScrollView {
                        VStack(spacing: 24) { // Reduced spacing
                            // Different view for each step
                            switch formState.currentStep {
                            case 1:
                                recipeDetailsSection
                            case 2:
                                ingredientsSection
                            case 3:
                                instructionsSection
                            default:
                                EmptyView()
                            }
                        }
                        .padding([.horizontal, .bottom])
                    }
                    
                    // Bottom navigation controls
                    NavigationControls(
                        currentStep: formState.currentStep,
                        totalSteps: formState.totalSteps,
                        canGoBack: formState.canMoveToPreviousStep(),
                        canContinue: formState.canMoveToNextStep(),
                        onBack: { formState.moveToPreviousStep() },
                        onContinue: { formState.moveToNextStep() },
                        onSave: saveRecipe
                    )
                    .background(
                        // Use adaptable color for dark mode
                        Rectangle()
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 3, y: -2)
                    )
                }
                
                // Success overlay - improved for dark mode
                if showSuccessAnimation {
                    // Full-screen translucent overlay
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                    
                    // Success animation
                    VStack(spacing: 16) {
                        // Checkmark in circle
                        ZStack {
                            Circle()
                                .fill(AppTheme.primary)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .transition(.scale)
                        
                        // Success message
                        Text("Recipe Saved!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Your recipe has been added to My Recipes")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.7))
                    )
                    .shadow(radius: 10)
                }
            }
            .navigationBarTitle("Create Recipe", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if formState.currentStep == formState.totalSteps {
                        Button(action: saveRecipe) {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
            .alert(isPresented: $showingValidationAlert) {
                Alert(
                    title: Text("Missing Information"),
                    message: Text(formState.validationMessage ?? "Please fill out all required fields."),
                    dismissButton: .default(Text("OK"))
                )
            }
            // Replace ActionSheet with a custom view in modal for better control and dark mode compatibility
            .sheet(isPresented: $showingActionSheet) {
                NavigationView {
                    VStack(spacing: 24) {
                        Image("recipe_success") // Add a nice success image asset if available
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                            .padding(.top, 40)
                        
                        Text("Recipe Saved Successfully!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Your recipe has been saved and added to your custom recipes.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                // Close the sheet
                                showingActionSheet = false
                                // Then close the form
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    presentationMode.wrappedValue.dismiss()
                                    // Signal to the parent view to show the My Recipes section
                                    shouldNavigateToMyRecipes = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "list.bullet")
                                    Text("View Your Recipes")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                // Just close both sheets
                                showingActionSheet = false
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Close")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .navigationBarItems(trailing: Button("Close") {
                        showingActionSheet = false
                        presentationMode.wrappedValue.dismiss()
                    })
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var stepTitle: String {
        switch formState.currentStep {
        case 1:
            return "Recipe Details"
        case 2:
            return "Ingredients"
        case 3:
            return "Instructions"
        default:
            return ""
        }
    }
    
    // MARK: - View Components
    
    // Recipe Details Section (Step 1)
    private var recipeDetailsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Recipe Name
            VStack(alignment: .leading) {
                Text("Recipe Name")
                    .font(.headline)
                
                TextField("Enter recipe name", text: $formState.recipeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 5)
                    .submitLabel(.next)
            }
            
            // Cooking Time
            VStack(alignment: .leading) {
                Text("Cooking Time")
                    .font(.headline)
                
                HStack {
                    Picker("Hours", selection: $formState.cookingHours) {
                        ForEach(0..<24) { hour in
                            Text("\(hour) hr").tag(hour)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                    
                    Text(":")
                        .font(.title2)
                        .padding(.horizontal, 5)
                    
                    Picker("Minutes", selection: $formState.cookingMinutes) {
                        ForEach([0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55], id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                }
            }
            
            // Servings
            VStack(alignment: .leading) {
                Text("Servings")
                    .font(.headline)
                
                Picker("Servings", selection: $formState.servings) {
                    ForEach(1..<13) { serving in
                        Text("\(serving) serving\(serving == 1 ? "" : "s")").tag(serving)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
            
            // Dietary Tags
            VStack(alignment: .leading) {
                Text("Dietary Tags")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Recipe.DietaryTag.allCases, id: \.self) { tag in
                            Button(action: {
                                if formState.selectedDietaryTags.contains(tag) {
                                    formState.selectedDietaryTags.remove(tag)
                                } else {
                                    formState.selectedDietaryTags.insert(tag)
                                }
                            }) {
                                HStack {
                                    if formState.selectedDietaryTags.contains(tag) {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                    }
                                    Text(tag.rawValue.capitalized)
                                        .font(.subheadline)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(formState.selectedDietaryTags.contains(tag) ? AppTheme.primary : Color(.systemGray6))
                                )
                                .foregroundColor(formState.selectedDietaryTags.contains(tag) ? .white : .primary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Ingredients Section (Step 2)
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(0..<formState.ingredientNames.count, id: \.self) { index in
                IngredientInputRow(name: $formState.ingredientNames[index], amount: $formState.ingredientAmounts[index], unit: $formState.ingredientUnits[index], category: $formState.ingredientCategories[index], index: index, onDelete: {
                    // Remove this ingredient
                    formState.ingredientNames.remove(at: index)
                    formState.ingredientAmounts.remove(at: index)
                    formState.ingredientUnits.remove(at: index)
                    formState.ingredientCategories.remove(at: index)
                }, showDeleteButton: index > 0)
            }
            
            // Add ingredient button
            Button(action: {
                // Create a new ingredient
                formState.ingredientNames.append("")
                formState.ingredientAmounts.append(1.0)
                formState.ingredientUnits.append(.pieces)
                formState.ingredientCategories.append(.other)
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Ingredient")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.primary, lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                        )
                )
                .foregroundColor(AppTheme.primary)
            }
        }
    }
    
    // Instructions Section (Step 3)
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(0..<formState.instructions.count, id: \.self) { index in
                VStack(alignment: .leading, spacing: 10) {
                    // Instruction header and delete button
                    HStack {
                        Text("Step \(index + 1)")
                            .font(.headline)
                        
                        Spacer()
                        
                        if index > 0 {
                            Button(action: {
                                // Remove this instruction
                                formState.instructions.remove(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    // Instruction text
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Use TextEditor for multi-line input
                        TextEditor(text: $formState.instructions[index])
                            .frame(minHeight: 100)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray3), lineWidth: 1)
                            )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            
            // Add instruction button
            Button(action: {
                // Create a new instruction step
                formState.instructions.append("")
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Step")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.primary, lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                        )
                )
                .foregroundColor(AppTheme.primary)
            }
        }
    }
    
    // MARK: - Functions
    
    // Build recipe from current form state
    private func buildRecipeFromState() -> Recipe {
        // Filter valid ingredients
        var validIngredients: [Ingredient] = []
        for i in 0..<formState.ingredientNames.count {
            if !formState.ingredientNames[i].isEmpty {
                let ingredient = Ingredient(
                    name: formState.ingredientNames[i],
                    amount: formState.ingredientAmounts[i],
                    unit: formState.ingredientUnits[i],
                    category: formState.ingredientCategories[i],
                    isPerishable: false
                )
                validIngredients.append(ingredient)
            }
        }
        
        // Filter valid instructions
        let validInstructions = formState.instructions.filter { !$0.isEmpty }
        
        // Create recipe object
        return Recipe(
            name: formState.recipeName,
            ingredients: validIngredients,
            instructions: validInstructions, 
            estimatedTime: TimeInterval((formState.cookingHours * 60 + formState.cookingMinutes) * 60),
            servings: formState.servings,
            dietaryTags: formState.selectedDietaryTags,
            imageName: getDefaultImageName(for: formState.recipeName),
            isCustomRecipe: true
        )
    }
    
    // Enhanced save method with success journey
    private func saveWithSuccessJourney() {
        // 1. Haptic success feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // 2. Show beautiful success animation
        withAnimation(.spring()) {
            showSuccessAnimation = true
        }
        
        // 3. Create the custom recipe
        let newRecipe = buildRecipeFromState()
        
        // 4. Add to suggestions at the top if possible
        if let viewModel = recipesViewModel {
            viewModel.addCustomRecipeAndRefresh(newRecipe)
        } else {
            // Fallback to regular save
            onSave(newRecipe)
        }
        
        // 5. Dismiss with elegant timing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                showSuccessAnimation = false
            }
            // Offer "View Your Recipe" option
            showingActionSheet = true
        }
    }
    
    // Save recipe function
    private func saveRecipe() {
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Use the form state to validate and build the recipe
        let (isValid, errorMessage) = formState.isValid()
        
        if !isValid {
            formState.validationMessage = errorMessage ?? "Please check your recipe details"
            formState.showingValidationAlert = true
            return
        }
        
        // Use enhanced success journey
        saveWithSuccessJourney()
    }
    
    // Helper function to get default image name based on recipe name
    private func getDefaultImageName(for recipeName: String) -> String {
        let name = recipeName.lowercased()
        
        if name.contains("pizza") {
            return "pizza"
        } else if name.contains("pasta") || name.contains("spaghetti") {
            return "pasta"
        } else if name.contains("salad") {
            return "salad"
        } else if name.contains("soup") {
            return "soup"
        } else if name.contains("steak") || name.contains("beef") {
            return "steak"
        } else if name.contains("fish") || name.contains("salmon") {
            return "salmon"
        } else if name.contains("chicken") {
            return "chicken"
        } else if name.contains("breakfast") || name.contains("pancake") {
            return "breakfast"
        } else {
            return "default_recipe"
        }
    }
}

struct RecipeFormView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeFormView(onSave: { _ in })
    }
} 