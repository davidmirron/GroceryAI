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
    // MARK: - Environment and Dismissal
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Dependencies
    var onSave: (Recipe) -> Void
    var recipesViewModel: RecipesViewModel?
    
    // MARK: - Form State
    @State private var currentStep = 1
    @State private var recipeName = ""
    
    // Using separate arrays for ingredients for better binding control
    @State private var ingredientNames: [String] = [""]
    @State private var ingredientAmounts: [Double] = [1.0]
    @State private var ingredientUnits: [IngredientUnit] = [.pieces]
    @State private var ingredientCategories: [IngredientCategory] = [.other]
    
    @State private var instructions: [String] = [""]
    @State private var cookingHours = 0
    @State private var cookingMinutes = 30
    @State private var servings = 4
    @State private var selectedDietaryTags: Set<Recipe.DietaryTag> = []
    
    // MARK: - UI State
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var showingSuccessAlert = false
    @State private var keyboardHeight: CGFloat = 0
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Progress bar
                ProgressBar(value: currentStep, total: 3)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Step title
                Text(stepTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Main form content
                ScrollView {
                    VStack(spacing: 20) {
                        contentForCurrentStep
                            .padding(.bottom, keyboardHeight > 0 ? keyboardHeight : 0)
                    }
                    .padding()
                }
                .animation(.default, value: currentStep)
                
                // Navigation controls
                NavigationControls(
                    currentStep: currentStep,
                    totalSteps: 3,
                    canGoBack: currentStep > 1,
                    canContinue: canContinueToNextStep(),
                    onBack: goToPreviousStep,
                    onContinue: {
                        if currentStep < 3 {
                            goToNextStep()
                        }
                    },
                    onSave: saveRecipe
                )
            }
            
            // Success alert overlay
            if showingSuccessAlert {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Recipe Saved!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Your recipe has been successfully saved.")
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("View Your Recipes")
                            .fontWeight(.medium)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                )
                .padding(20)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                }
            }
        }
        .alert(isPresented: $showingValidationAlert) {
            Alert(
                title: Text("Please Check"),
                message: Text(validationMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            // Set initial values if needed from RecipesViewModel
        }
    }
    
    // MARK: - Computed Properties
    private var stepTitle: String {
        switch currentStep {
        case 1: return "Basic Information"
        case 2: return "Ingredients"
        case 3: return "Instructions"
        default: return "Create Recipe"
        }
    }
    
    private var contentForCurrentStep: some View {
        Group {
            switch currentStep {
            case 1: basicInfoStep
            case 2: ingredientsStep
            case 3: instructionsStep
            default: EmptyView()
            }
        }
    }
    
    // MARK: - Form Steps
    private var basicInfoStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Recipe name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Recipe Name")
                    .font(.headline)
                
                TextField("Enter recipe name", text: $recipeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .submitLabel(.next)
            }
            
            // Servings field
            VStack(alignment: .leading, spacing: 8) {
                Text("Servings")
                    .font(.headline)
                
                Stepper(value: $servings, in: 1...20) {
                    Text("\(servings) \(servings == 1 ? "serving" : "servings")")
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
            }
            
            // Cooking time
            VStack(alignment: .leading, spacing: 8) {
                Text("Cooking Time")
                    .font(.headline)
                
                HStack {
                    // Hours picker
                    VStack(alignment: .leading) {
                        Text("Hours")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Hours", selection: $cookingHours) {
                            ForEach(0..<24) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    // Minutes picker
                    VStack(alignment: .leading) {
                        Text("Minutes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Minutes", selection: $cookingMinutes) {
                            ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
            }
            
            // Dietary tags
            VStack(alignment: .leading, spacing: 8) {
                Text("Dietary Tags")
                    .font(.headline)
                
                TagsView(selectedTags: $selectedDietaryTags)
            }
        }
    }
    
    private var ingredientsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(0..<ingredientNames.count, id: \.self) { index in
                VStack(alignment: .leading, spacing: 12) {
                    // Header and delete button
                    HStack {
                        Text("Ingredient \(index + 1)")
                            .font(.headline)
                        
                        Spacer()
                        
                        if ingredientNames.count > 1 {
                            Button(action: { removeIngredient(at: index) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    // Ingredient name
                    TextField("Ingredient name", text: $ingredientNames[index])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Amount and unit
                    HStack {
                        // Amount
                        VStack(alignment: .leading) {
                            Text("Amount")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextField("1.0", value: $ingredientAmounts[index], formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Unit
                        VStack(alignment: .leading) {
                            Text("Unit")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Picker("Unit", selection: $ingredientUnits[index]) {
                                ForEach(IngredientUnit.allCases, id: \.self) { unit in
                                    Text(unit.rawValue).tag(unit)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Category
                    VStack(alignment: .leading) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Category", selection: $ingredientCategories[index]) {
                            ForEach(IngredientCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            // Add ingredient button
            Button(action: addIngredient) {
                Label("Add Ingredient", systemImage: "plus.circle.fill")
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 1)
            )
        }
    }
    
    private var instructionsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(0..<instructions.count, id: \.self) { index in
                VStack(alignment: .leading, spacing: 12) {
                    // Header and delete button
                    HStack {
                        Text("Step \(index + 1)")
                            .font(.headline)
                        
                        Spacer()
                        
                        if instructions.count > 1 {
                            Button(action: { removeInstruction(at: index) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    // Instruction text
                    TextEditor(text: $instructions[index])
                        .frame(minHeight: 100)
                        .padding(4)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                        )
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            // Add instruction button
            Button(action: addInstruction) {
                Label("Add Step", systemImage: "plus.circle.fill")
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Helper Methods
    private func addIngredient() {
        ingredientNames.append("")
        ingredientAmounts.append(1.0)
        ingredientUnits.append(.pieces)
        ingredientCategories.append(.other)
    }
    
    private func removeIngredient(at index: Int) {
        guard ingredientNames.count > 1, index < ingredientNames.count else { return }
        ingredientNames.remove(at: index)
        ingredientAmounts.remove(at: index)
        ingredientUnits.remove(at: index)
        ingredientCategories.remove(at: index)
    }
    
    private func addInstruction() {
        instructions.append("")
    }
    
    private func removeInstruction(at index: Int) {
        guard instructions.count > 1, index < instructions.count else { return }
        instructions.remove(at: index)
    }
    
    private func goToNextStep() {
        guard currentStep < 3 else { return }
        currentStep += 1
    }
    
    private func goToPreviousStep() {
        guard currentStep > 1 else { return }
        currentStep -= 1
    }
    
    private func canContinueToNextStep() -> Bool {
        switch currentStep {
        case 1: return !recipeName.isEmpty
        case 2: return ingredientNames.contains { !$0.isEmpty }
        case 3: return instructions.contains { !$0.isEmpty }
        default: return false
        }
    }
    
    private func validateRecipe() -> Bool {
        // Check recipe name
        if recipeName.isEmpty {
            validationMessage = "Please enter a recipe name"
            showingValidationAlert = true
            return false
        }
        
        // Check ingredients
        let validIngredients = ingredientNames.filter { !$0.isEmpty }
        if validIngredients.isEmpty {
            validationMessage = "Please add at least one ingredient"
            showingValidationAlert = true
            return false
        }
        
        // Check instructions
        let validInstructions = instructions.filter { !$0.isEmpty }
        if validInstructions.isEmpty {
            validationMessage = "Please add at least one instruction step"
            showingValidationAlert = true
            return false
        }
        
        return true
    }
    
    private func saveRecipe() {
        guard validateRecipe() else { return }
        
        // Create ingredients array
        var recipeIngredients: [Ingredient] = []
        for i in 0..<ingredientNames.count {
            if !ingredientNames[i].isEmpty {
                let ingredient = Ingredient(
                    name: ingredientNames[i],
                    amount: ingredientAmounts[i],
                    unit: ingredientUnits[i],
                    category: ingredientCategories[i],
                    isPerishable: false  // Default value
                )
                recipeIngredients.append(ingredient)
            }
        }
        
        // Filter out empty instructions
        let recipeInstructions = instructions.filter { !$0.isEmpty }
        
        // Calculate cooking time in seconds
        let cookingTimeInSeconds = TimeInterval((cookingHours * 60 + cookingMinutes) * 60)
        
        // Create recipe
        let newRecipe = Recipe(
            name: recipeName,
            ingredients: recipeIngredients,
            instructions: recipeInstructions,
            estimatedTime: cookingTimeInSeconds,
            servings: servings,
            dietaryTags: selectedDietaryTags,
            imageName: getDefaultImageName(for: recipeName),
            isCustomRecipe: true  // Mark as custom
        )
        
        // Show success animation
        withAnimation {
            showingSuccessAlert = true
        }
        
        // Delay for animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Save recipe
            if let recipesVM = recipesViewModel {
                recipesVM.addCustomRecipeAndRefresh(newRecipe)
            } else {
                onSave(newRecipe)
            }
            
            // Dismiss after a brief delay to show success animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
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

// MARK: - Tags View
struct TagsView: View {
    @Binding var selectedTags: Set<Recipe.DietaryTag>
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Recipe.DietaryTag.allCases, id: \.self) { tag in
                    Button(action: {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    }) {
                        Text(tag.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedTags.contains(tag) ? AppTheme.primary : Color(UIColor.secondarySystemBackground))
                            .foregroundColor(selectedTags.contains(tag) ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(4)
        }
        .frame(height: 40)
    }
}

// MARK: - Preview
struct RecipeFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecipeFormView(onSave: { _ in })
        }
    }
} 
