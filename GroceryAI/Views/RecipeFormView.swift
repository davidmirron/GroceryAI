import SwiftUI
import UIKit

struct RecipeFormView: View {
    // MARK: - Environment and State
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Dependencies
    var onSave: (Recipe) -> Void
    var recipesViewModel: RecipesViewModel?
    
    // MARK: - Form State
    @State private var currentStep = 1
    @State private var recipeName = ""
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
    @State private var showSuccessAnimation = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardVisible = false
    
    // MARK: - Animation Properties
    @State private var stepInTransition = false
    @State private var stepOutTransition = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            AppTheme.background.ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                
                // Content container
                ZStack {
                    // Step 1
                    stepContent(1) {
                        basicInfoSection
                    }
                    .opacity(currentStep == 1 ? 1 : 0)
                    .zIndex(currentStep == 1 ? 1 : 0)
                    
                    // Step 2
                    stepContent(2) {
                        ingredientsSection
                    }
                    .opacity(currentStep == 2 ? 1 : 0)
                    .zIndex(currentStep == 2 ? 1 : 0)
                    
                    // Step 3
                    stepContent(3) {
                        instructionsSection
                    }
                    .opacity(currentStep == 3 ? 1 : 0)
                    .zIndex(currentStep == 3 ? 1 : 0)
                }
                
                // Bottom navigation controls
                navigationControls
                    .background(Color(.systemBackground).opacity(0.95))
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(AppTheme.borderColor),
                        alignment: .top
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 3, y: -2)
            }
            
            // Success overlay
            if showSuccessAnimation {
                ZStack {
                    // Backdrop
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    // Success card
                    VStack(spacing: 20) {
                        // Success checkmark with animation
                        ZStack {
                            Circle()
                                .fill(AppTheme.success)
                                .frame(width: 100, height: 100)
                                .shadow(color: AppTheme.success.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 50, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(showSuccessAnimation ? 1 : 0.5)
                        .opacity(showSuccessAnimation ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSuccessAnimation)
                        
                        Text("Recipe Saved!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                        
                        Text("Your custom recipe has been added to your collection.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.7))
                            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                    )
                    .opacity(showSuccessAnimation ? 1 : 0)
                    .scaleEffect(showSuccessAnimation ? 1 : 0.8)
                    .animation(.easeOut(duration: 0.2), value: showSuccessAnimation)
                }
                .transition(.opacity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(stepTitle)
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.text)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(AppTheme.text)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if currentStep == 3 {
                    Button(action: saveRecipe) {
                        Text("Save")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.primary)
                    }
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
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                // Get the proper keyboard height without any arbitrary adjustments
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = keyboardFrame.height
                    keyboardVisible = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = 0
                keyboardVisible = false
            }
        }
    }
    
    // MARK: - UI Components
    
    // Progress indicator with animated transitions
    private var progressIndicator: some View {
        VStack(spacing: 8) {
            // Step progress bar
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                // Filled track with animation
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.primaryGradient)
                    .frame(width: fillWidth, height: 8)
            }
            
            // Step indicator text
            HStack {
                Text("Step \(currentStep) of 3")
                    .font(AppTheme.smallFont)
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                // Step labels
                HStack(spacing: 16) {
                    Text("Basics")
                        .font(AppTheme.smallFont)
                        .foregroundColor(currentStep >= 1 ? AppTheme.primary : AppTheme.textSecondary)
                    
                    Text("Ingredients")
                        .font(AppTheme.smallFont)
                        .foregroundColor(currentStep >= 2 ? AppTheme.primary : AppTheme.textSecondary)
                    
                    Text("Instructions")
                        .font(AppTheme.smallFont)
                        .foregroundColor(currentStep >= 3 ? AppTheme.primary : AppTheme.textSecondary)
                }
            }
        }
    }
    
    // Wrapper for each step's content with transitions
    private func stepContent<Content: View>(_ step: Int, @ViewBuilder content: @escaping () -> Content) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                content()
                    .padding(.bottom, 20) // Reduced padding at bottom
                
                // Add spacer at the bottom that adapts to keyboard height
                if keyboardVisible {
                    Color.clear
                        .frame(height: keyboardHeight * 0.6) // Only need partial height because ScrollView already helps
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .simultaneousGesture(
            // Add a tap gesture to dismiss keyboard when tapping empty areas
            TapGesture().onEnded { _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
        .opacity(stepInTransition && currentStep == step ? 1 : (stepOutTransition && currentStep != step ? 0 : 1))
        .offset(x: stepInTransition && currentStep == step ? 0 : (stepOutTransition && currentStep == step - 1 ? -30 : (stepOutTransition && currentStep == step + 1 ? 30 : 0)))
    }
    
    // Basic info step (step 1)
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Recipe name
            formField("Recipe Name") {
                TextField("E.g., Homemade Pancakes", text: $recipeName)
                    .font(AppTheme.bodyFont)
                    .padding()
                    .background(AppTheme.textFieldBackground)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                            .stroke(AppTheme.borderColor, lineWidth: 1)
                    )
            }
            
            // Servings
            formField("Servings") {
                HStack(spacing: 0) {
                    Button(action: { if servings > 1 { servings -= 1 } }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(servings > 1 ? AppTheme.primary : AppTheme.textSecondary.opacity(0.5))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)
                    
                    Text("\(servings)")
                        .font(.title2)
                        .fontWeight(.medium)
                        .frame(width: 60)
                        .multilineTextAlignment(.center)
                    
                    Button(action: { servings += 1 }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)
                }
                .frame(height: 56)
                .background(AppTheme.textFieldBackground)
                .cornerRadius(AppTheme.cornerRadiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .stroke(AppTheme.borderColor, lineWidth: 1)
                )
            }
            
            // Cooking time
            formField("Cooking Time") {
                HStack(spacing: 12) {
                    // Hours
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hours")
                            .font(AppTheme.smallFont)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Menu {
                            ForEach(0..<24) { hour in
                                Button(action: { cookingHours = hour }) {
                                    HStack {
                                        Text("\(hour)")
                                        if cookingHours == hour {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(cookingHours)")
                                    .foregroundColor(AppTheme.text)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .font(.system(size: 14))
                            }
                            .frame(height: 56)
                            .padding(.horizontal)
                            .background(AppTheme.textFieldBackground)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                    .stroke(AppTheme.borderColor, lineWidth: 1)
                            )
                        }
                    }
                    
                    // Minutes
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Minutes")
                            .font(AppTheme.smallFont)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Menu {
                            ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { minute in
                                Button(action: { cookingMinutes = minute }) {
                                    HStack {
                                        Text("\(minute)")
                                        if cookingMinutes == minute {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(cookingMinutes)")
                                    .foregroundColor(AppTheme.text)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .font(.system(size: 14))
                            }
                            .frame(height: 56)
                            .padding(.horizontal)
                            .background(AppTheme.textFieldBackground)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                    .stroke(AppTheme.borderColor, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            
            // Dietary tags
            formField("Dietary Tags") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Recipe.DietaryTag.allCases, id: \.self) { tag in
                            dietaryTagButton(tag)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    // Ingredients step (step 2)
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(0..<ingredientNames.count, id: \.self) { index in
                IngredientCard(
                    name: $ingredientNames[index],
                    amount: $ingredientAmounts[index],
                    unit: $ingredientUnits[index],
                    category: $ingredientCategories[index],
                    index: index,
                    showDeleteButton: ingredientNames.count > 1,
                    onDelete: { removeIngredient(at: index) }
                )
            }
            
            // Add ingredient button
            Button(action: addIngredient) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.headline)
                    Text("Add Ingredient")
                        .font(AppTheme.bodyFont.weight(.medium))
                }
                .foregroundColor(AppTheme.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .fill(AppTheme.chipBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .strokeBorder(AppTheme.primary, lineWidth: 1.5)
                        )
                )
            }
        }
    }
    
    // Instructions step (step 3)
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(0..<instructions.count, id: \.self) { index in
                InstructionCard(
                    instruction: $instructions[index],
                    index: index,
                    showDeleteButton: instructions.count > 1,
                    onDelete: { removeInstruction(at: index) }
                )
            }
            
            // Add instruction button
            Button(action: addInstruction) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.headline)
                    Text("Add Step")
                        .font(AppTheme.bodyFont.weight(.medium))
                }
                .foregroundColor(AppTheme.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .fill(AppTheme.chipBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .strokeBorder(AppTheme.primary, lineWidth: 1.5)
                        )
                )
            }
        }
    }
    
    // Navigation controls
    private var navigationControls: some View {
        HStack {
            // Back button (only visible on steps 2 and 3)
            if currentStep > 1 {
                Button(action: goToPreviousStep) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(AppTheme.primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .stroke(AppTheme.primary, lineWidth: 1.5)
                    )
                }
            } else {
                Spacer()
                    .frame(width: 40)
            }
            
            Spacer()
            
            // Next/Save button
            if currentStep < 3 {
                Button(action: goToNextStep) {
                    HStack(spacing: 8) {
                        Text("Continue")
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .fill(canMoveToNextStep() ? AppTheme.primaryGradient : 
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.6)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .disabled(!canMoveToNextStep())
            } else {
                Button(action: saveRecipe) {
                    HStack(spacing: 8) {
                        Text("Save Recipe")
                        Image(systemName: "checkmark")
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .fill(canMoveToNextStep() ? AppTheme.primaryGradient : 
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.6)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .disabled(!canMoveToNextStep())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Helper Views
    
    // Form field container with label
    private func formField<Content: View>(_ label: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppTheme.bodyFont.weight(.medium))
                .foregroundColor(AppTheme.text)
            
            content()
        }
    }
    
    // Dietary tag selection button
    private func dietaryTagButton(_ tag: Recipe.DietaryTag) -> some View {
        let isSelected = selectedDietaryTags.contains(tag)
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if isSelected {
                    selectedDietaryTags.remove(tag)
                } else {
                    selectedDietaryTags.insert(tag)
                }
            }
        }) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.primary)
                        .font(.system(size: 16))
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(AppTheme.textSecondary)
                        .font(.system(size: 16))
                }
                
                Text(tag.displayName)
                    .font(AppTheme.smallFont)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                    .fill(isSelected ? AppTheme.chipBackground : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                            .stroke(isSelected ? Color.clear : AppTheme.borderColor, lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Ingredient Card
    struct IngredientCard: View {
        @Binding var name: String
        @Binding var amount: Double
        @Binding var unit: IngredientUnit
        @Binding var category: IngredientCategory
        let index: Int
        let showDeleteButton: Bool
        let onDelete: () -> Void
        
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            VStack(spacing: 16) {
                // Header and delete button
                HStack {
                    Text("Ingredient \(index + 1)")
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.text)
                    
                    Spacer()
                    
                    if showDeleteButton {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .foregroundColor(AppTheme.error)
                                .font(.system(size: 16))
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.red.opacity(0.1))
                                )
                        }
                    }
                }
                
                // Ingredient name
                TextField("Ingredient name", text: $name)
                    .font(AppTheme.bodyFont)
                    .padding()
                    .background(AppTheme.textFieldBackground)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                            .stroke(AppTheme.borderColor, lineWidth: 1)
                    )
                
                // Amount and unit
                HStack(spacing: 12) {
                    // Amount with stepper
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Amount")
                            .font(AppTheme.smallFont)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        HStack(spacing: 0) {
                            Button(action: { if amount > 0.5 { amount -= 0.5 } }) {
                                Image(systemName: "minus")
                                    .padding(10)
                                    .foregroundColor(amount > 0.5 ? AppTheme.text : AppTheme.textSecondary.opacity(0.5))
                            }
                            
                            Text(String(format: "%.1f", amount))
                                .frame(minWidth: 40)
                                .multilineTextAlignment(.center)
                                .font(AppTheme.bodyFont)
                                .foregroundColor(AppTheme.text)
                            
                            Button(action: { amount += 0.5 }) {
                                Image(systemName: "plus")
                                    .padding(10)
                                    .foregroundColor(AppTheme.text)
                            }
                        }
                        .background(AppTheme.textFieldBackground)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .stroke(AppTheme.borderColor, lineWidth: 1)
                        )
                    }
                    .frame(width: 110)
                    
                    Spacer()
                    
                    // Unit selector
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Unit")
                            .font(AppTheme.smallFont)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Menu {
                            ForEach(IngredientUnit.allCases, id: \.self) { unitOption in
                                Button(action: { unit = unitOption }) {
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
                                    .foregroundColor(AppTheme.text)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(AppTheme.textFieldBackground)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                    .stroke(AppTheme.borderColor, lineWidth: 1)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Category selector
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(AppTheme.smallFont)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Menu {
                        ForEach(IngredientCategory.allCases, id: \.self) { categoryOption in
                            Button(action: { category = categoryOption }) {
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
                                .foregroundColor(AppTheme.text)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(AppTheme.textSecondary)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppTheme.textFieldBackground)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .stroke(AppTheme.borderColor, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.03))
            )
        }
    }
    
    // MARK: - Instruction Card
    struct InstructionCard: View {
        @Binding var instruction: String
        let index: Int
        let showDeleteButton: Bool
        let onDelete: () -> Void
        
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                // Header with delete button
                HStack {
                    Text("Step \(index + 1)")
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.text)
                    
                    Spacer()
                    
                    if showDeleteButton {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .foregroundColor(AppTheme.error)
                                .font(.system(size: 16))
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.red.opacity(0.1))
                                )
                        }
                    }
                }
                
                // Instruction text editor
                ZStack(alignment: .topLeading) {
                    if instruction.isEmpty {
                        Text("Describe this step...")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(EdgeInsets(top: 16, leading: 12, bottom: 12, trailing: 12))
                    }
                    
                    TextEditor(text: $instruction)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.text)
                        .frame(minHeight: 120)
                        .padding(6)
                        .background(AppTheme.textFieldBackground)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .stroke(AppTheme.borderColor, lineWidth: 1)
                        )
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.03))
            )
        }
    }
    
    // MARK: - Computed Properties
    
    // Step title text
    private var stepTitle: String {
        switch currentStep {
        case 1: return "Create Recipe"
        case 2: return "Add Ingredients"
        case 3: return "Instructions"
        default: return "Create Recipe"
        }
    }
    
    // Width of the progress bar fill based on current step
    private var fillWidth: CGFloat {
        let progress = CGFloat(currentStep) / 3.0
        return UIScreen.main.bounds.width * 0.89 * progress // Accounting for padding
    }
    
    // MARK: - Form Actions
    
    // Navigation between steps
    private func goToNextStep() {
        guard currentStep < 3 && canMoveToNextStep() else { return }
        
        // Dismiss keyboard before transition
        dismissKeyboard()
        
        withAnimation(.easeOut(duration: 0.2)) {
            stepOutTransition = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.none) {
                self.currentStep += 1
                self.stepOutTransition = false
                self.stepInTransition = false
            }
            
            withAnimation(.easeIn(duration: 0.2)) {
                self.stepInTransition = true
            }
        }
    }
    
    private func goToPreviousStep() {
        guard currentStep > 1 else { return }
        
        // Dismiss keyboard before transition
        dismissKeyboard()
        
        withAnimation(.easeOut(duration: 0.2)) {
            stepOutTransition = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.none) {
                self.currentStep -= 1
                self.stepOutTransition = false
                self.stepInTransition = false
            }
            
            withAnimation(.easeIn(duration: 0.2)) {
                self.stepInTransition = true
            }
        }
    }
    
    // Ingredient management
    private func addIngredient() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            ingredientNames.append("")
            ingredientAmounts.append(1.0)
            ingredientUnits.append(.pieces)
            ingredientCategories.append(.other)
        }
        
        // Give haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func removeIngredient(at index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            ingredientNames.remove(at: index)
            ingredientAmounts.remove(at: index)
            ingredientUnits.remove(at: index)
            ingredientCategories.remove(at: index)
        }
        
        // Give haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    // Instruction management
    private func addInstruction() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            instructions.append("")
        }
        
        // Give haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func removeInstruction(at index: Int) {
        _ = withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            instructions.remove(at: index)
        }
        
        // Give haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    // MARK: - Form Validation
    
    // Check if form can proceed to next step
    private func canMoveToNextStep() -> Bool {
        switch currentStep {
        case 1:
            return !recipeName.isEmpty
        case 2:
            return ingredientNames.contains { !$0.isEmpty }
        case 3:
            return instructions.contains { !$0.isEmpty }
        default:
            return false
        }
    }
    
    // Validate the entire recipe before saving
    private func validateRecipe() -> Bool {
        // Check recipe name
        if recipeName.isEmpty {
            validationMessage = "Please enter a recipe name"
            showingValidationAlert = true
            return false
        }
        
        // Check ingredients
        if !ingredientNames.contains(where: { !$0.isEmpty }) {
            validationMessage = "Please add at least one ingredient"
            showingValidationAlert = true
            return false
        }
        
        // Check instructions
        if !instructions.contains(where: { !$0.isEmpty }) {
            validationMessage = "Please add at least one instruction step"
            showingValidationAlert = true
            return false
        }
        
        return true
    }
    
    // MARK: - Form Submission
    
    // Save recipe with success animation
    private func saveRecipe() {
        // Validate the form
        guard validateRecipe() else { return }
        
        // Dismiss keyboard
        dismissKeyboard()
        
        // Create recipe object
        let newRecipe = createRecipeFromForm()
        
        // Show success animation
        withAnimation(.easeIn(duration: 0.3)) {
            showSuccessAnimation = true
        }
        
        // Give success feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // Save and dismiss after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Add recipe to the view model
            if let recipesVM = recipesViewModel {
                recipesVM.addCustomRecipeAndRefresh(newRecipe)
            } else {
                onSave(newRecipe)
            }
            
            // Dismiss the form
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
    }
    
    // Create recipe object from form data
    private func createRecipeFromForm() -> Recipe {
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
        
        // Calculate cooking time in seconds
        let cookingTimeInSeconds = TimeInterval((cookingHours * 60 + cookingMinutes) * 60)
        
        // Create and return recipe
        return Recipe(
            name: recipeName,
            ingredients: validIngredients,
            instructions: validInstructions,
            estimatedTime: cookingTimeInSeconds,
            servings: servings,
            dietaryTags: selectedDietaryTags,
            imageName: getDefaultImageName(for: recipeName),
            isCustomRecipe: true
        )
    }
    
    // MARK: - Helper Functions
    
    // Dismiss the keyboard
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Get default image name based on recipe name
    private func getDefaultImageName(for recipeName: String) -> String {
        let lowerName = recipeName.lowercased()
        
        if lowerName.contains("pizza") {
            return "pizza"
        } else if lowerName.contains("pasta") || lowerName.contains("spaghetti") {
            return "pasta"
        } else if lowerName.contains("salad") {
            return "salad"
        } else if lowerName.contains("soup") {
            return "soup"
        } else if lowerName.contains("cake") || lowerName.contains("dessert") {
            return "cake"
        } else if lowerName.contains("pancake") {
            return "pancakes"
        } else if lowerName.contains("chicken") {
            return "chicken"
        } else if lowerName.contains("fish") || lowerName.contains("salmon") {
            return "fish"
        } else {
            return "default_recipe"
        }
    }
}

// MARK: - Recipe.DietaryTag Extension for Display Names
extension Recipe.DietaryTag {
    var displayName: String {
        switch self {
        case .vegetarian:
            return "Vegetarian"
        case .vegan:
            return "Vegan"
        case .glutenFree:
            return "Gluten-Free"
        case .dairyFree:
            return "Dairy-Free"
        case .lowCarb:
            return "Low-Carb"
        case .keto:
            return "Keto"
        case .paleo:
            return "Paleo"
        }
    }
}
