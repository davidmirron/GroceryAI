import SwiftUI
import UIKit

/// A standardized row for displaying a meal in the meal plan
/// - Supports both recipe-based and custom meals
/// - Uses proper sizing and animations
/// - Consistent with Apple's design language
struct MealRowView: View {
    let meal: Meal
    let onDelete: () -> Void
    var viewModel: MealPlanViewModel? = nil
    @State private var isPressed: Bool = false
    @State private var showingActionFeedback = false
    
    private var isCustomMeal: Bool {
        meal.recipeId == nil
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 12) {
                // Meal icon/emoji 
                ZStack {
                    Circle()
                        .fill(AppTheme.cardBackground)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    if isCustomMeal {
                        Text(meal.emoji ?? "🍽️")
                            .font(.system(size: 20))
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.primary)
                    }
                }
                
                // Meal details
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.text)
                        .lineLimit(1)
                    
                    if let calories = meal.calories, calories > 0 {
                        Text("\(calories) calories")
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                }
                
                Spacer()
                
                // Shopping list button (only for recipe-based meals)
                if !isCustomMeal && viewModel != nil {
                    Button {
                        viewModel?.addIngredientsToShoppingList(for: meal)
                    } label: {
                        Image(systemName: "cart.badge.plus")
                            .foregroundColor(AppTheme.primary)
                            .padding(8)
                            .background(Circle().fill(AppTheme.cardBackground))
                            .shadow(color: AppTheme.shadowColor.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .accessibilityLabel("Add ingredients to shopping list")
                    .disabled(viewModel == nil)
                }
                
                // Delete button
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        onDelete()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.secondaryText.opacity(0.7))
                        .frame(width: 44, height: 44) // Proper touch target
                }
                .accessibilityLabel("Remove \(meal.name)")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                    .scaleEffect(isPressed ? 0.98 : 1.0)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                // Add haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
                // Add visual feedback
                withAnimation(.spring(response: 0.3)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3)) {
                        isPressed = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        // Recipe meal
        MealRowView(
            meal: Meal(
                id: UUID(),
                name: "Avocado Toast",
                recipeId: UUID(),
                date: Date(),
                calories: 320,
                mealType: .breakfast,
                emoji: nil
            ),
            onDelete: {}
        )
        
        // Custom meal
        MealRowView(
            meal: Meal(
                id: UUID(),
                name: "Protein Shake",
                recipeId: nil,
                date: Date(),
                calories: 180,
                mealType: .snack,
                emoji: "🥤"
            ),
            onDelete: {}
        )
    }
    .padding()
    .background(AppTheme.background)
} 