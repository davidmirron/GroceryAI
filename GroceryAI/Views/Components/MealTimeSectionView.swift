import SwiftUI

/// A standardized view for a section of meals for a specific meal type (breakfast, lunch, etc.)
/// - Consistent visual language with proper animations
/// - Optimized rendering with minimal state
/// - Follows Apple HIG with appropriate sizing and spacing
struct MealTimeSectionView: View {
    let mealType: MealType
    let date: Date
    let meals: [Meal]
    @ObservedObject var viewModel: MealPlanViewModel
    @State private var isAddingMeal = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Header
            headerView
                .padding(.horizontal, 16)
            
            // MARK: - Meals or Empty State
            if meals.isEmpty {
                emptyStateView
                    .padding(.vertical, 4)
            } else {
                mealsListView
                    .padding(.horizontal, 16)
            }
            
            // Bottom add button (always visible)
            addButton
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 8)
        }
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground.opacity(0.5))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
        .sheet(isPresented: $isAddingMeal) {
            addMealView
                .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Component Views
    
    private var headerView: some View {
        HStack(spacing: 12) {
            // Meal type indicator
            MealTypeIndicator(mealType: mealType, style: .filledCircle, size: 32)
            
            // Header text
            Text(mealType.displayName)
                .font(.headline)
                .foregroundColor(AppTheme.text)
            
            Spacer()
            
            if !meals.isEmpty {
                // Badge showing meal count
                Text("\(meals.count)")
                    .font(.footnote.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(mealType.themeColor))
                    .foregroundColor(.white)
                    .accessibilityLabel("\(meals.count) meals")
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(mealType.displayName), \(meals.isEmpty ? "No meals" : "\(meals.count) meals")")
    }
    
    private var mealsListView: some View {
        VStack(spacing: 12) {
            ForEach(meals) { meal in
                MealRowView(meal: meal) {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.removeMeal(meal)
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.spring(response: 0.4), value: meals.count)
    }
    
    private var emptyStateView: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: mealType.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(mealType.themeColor.opacity(0.7))
                
                Text("No \(mealType.displayName.lowercased()) planned")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
            }
            .padding(.vertical, 16)
            Spacer()
        }
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
    
    private var addButton: some View {
        Button(action: {
            isAddingMeal = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                Text("Add \(mealType.displayName)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(mealType.themeColor)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(mealType.themeColor, lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(mealType.themeColor.opacity(0.05))
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("Add \(mealType.displayName)")
    }
    
    private var addMealView: some View {
        NavigationView {
            AddMealView(mealType: mealType, date: date, viewModel: viewModel)
                .navigationTitle("Add \(mealType.displayName)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isAddingMeal = false
                        }
                    }
                }
        }
    }
}

// MARK: - Preview
struct MealTimeSectionView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MealPlanViewModel()
        let today = Date()
        
        // Create sample meal data
        let breakfastMeals = [
            Meal(id: UUID(), name: "Oatmeal with Berries", recipeId: UUID(), date: today, calories: 320, mealType: .breakfast, emoji: nil),
            Meal(id: UUID(), name: "Coffee", recipeId: nil, date: today, calories: 5, mealType: .breakfast, emoji: "☕️")
        ]
        
        // Empty lunch for testing empty state
        let lunchMeals: [Meal] = []
        
        return VStack(spacing: 16) {
            MealTimeSectionView(
                mealType: .breakfast,
                date: today,
                meals: breakfastMeals,
                viewModel: viewModel
            )
            
            MealTimeSectionView(
                mealType: .lunch,
                date: today,
                meals: lunchMeals,
                viewModel: viewModel
            )
        }
        .padding()
        .background(AppTheme.background)
    }
} 