import SwiftUI

struct MealPlanView: View {
    @State private var selectedDay = "Today"
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    DayPlanCard(
                        day: "Today",
                        meals: [
                            MealViewItem(type: "Breakfast", name: "Greek Yogurt with Berries"),
                            MealViewItem(type: "Lunch", name: "Mediterranean Salad"),
                            MealViewItem(type: "Dinner", name: "Chicken & Vegetable Stir Fry")
                        ]
                    )
                    
                    DayPlanCard(
                        day: "Tomorrow",
                        meals: [
                            MealViewItem(type: "Breakfast", name: "Avocado Toast"),
                            MealViewItem(type: "Lunch", name: "Leftover Stir Fry"),
                            MealViewItem(type: "Dinner", name: "Creamy Spinach Pasta")
                        ]
                    )
                }
                .padding()
                .padding(.bottom, 80)
            }
            
            Button {
                // Create shopping list from meal plan
            } label: {
                Text("Create Shopping List from Meal Plan")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [AppTheme.headerStart, AppTheme.headerEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 4)
                    .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("Meal Plan")
        .background(AppTheme.backgroundGreen)
    }
}

// Renamed from Meal to MealViewItem to avoid conflicts
struct MealViewItem {
    let type: String
    let name: String
}

struct DayPlanCard: View {
    let day: String
    let meals: [MealViewItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(day)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.text)
                
                Spacer()
                
                Button {
                    // Edit meal plan
                } label: {
                    Text("Edit")
                        .foregroundColor(AppTheme.accentTeal)
                }
            }
            
            ForEach(meals, id: \.name) { meal in
                HStack(alignment: .top) {
                    Text("\(meal.type):")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(width: 80, alignment: .leading)
                    
                    Text(meal.name)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.text)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.borderColor, lineWidth: 1)
        )
        .shadow(color: Color.clear, radius: 0)
        .padding(.horizontal)
    }
} 