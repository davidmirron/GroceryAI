import SwiftUI
import UIKit

struct MainTabView: View {
    @State private var selectedTab = 0
    
    // Create shared ViewModels
    @StateObject private var shoppingListViewModel = ShoppingListViewModel()
    @StateObject private var recipeListViewModel = RecipeListViewModel()
    
    var body: some View {
        let recipesViewModel = RecipesViewModel(recipeListViewModel: recipeListViewModel)
        
        TabView(selection: $selectedTab) {
            NavigationStack {
                ShoppingListView(
                    viewModel: shoppingListViewModel,
                    recipesViewModel: recipesViewModel
                )
            }
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }
            .tag(0)
            
            NavigationStack {
                RecipesView(
                    shoppingListViewModel: shoppingListViewModel,
                    recipeListViewModel: recipeListViewModel,
                    recipesViewModel: recipesViewModel
                )
            }
            .tabItem {
                Label("Recipes", systemImage: "book")
            }
            .tag(1)
            
            NavigationStack {
                MealPlanView()
            }
            .tabItem {
                Label("Meal Plan", systemImage: "calendar")
            }
            .tag(2)
            
            NavigationStack {
                TipsView()
            }
            .tabItem {
                Label("Tips", systemImage: "lightbulb")
            }
            .tag(3)
        }
        .accentColor(AppTheme.accentTeal)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor(AppTheme.tabBarBackground)
            appearance.shadowColor = UIColor(AppTheme.tabBarBorder)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// Enhanced TipsView to make it more engaging and useful
struct TipsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Enhanced header
                Text("Shopping Tips")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primaryDark)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                // Group tips in a card with enhanced styling
                VStack(alignment: .leading, spacing: 16) {
                    // Add tip cards with icons for visual appeal
                    EnhancedTipRow(
                        icon: "calendar.badge.clock",
                        title: "Plan Your Meals",
                        description: "Planning meals in advance helps reduce food waste and saves money.",
                        accentColor: AppTheme.primary
                    )
                    
                    Divider().padding(.horizontal)
                    
                    EnhancedTipRow(
                        icon: "house",
                        title: "Check Your Pantry",
                        description: "Before shopping, check what you already have to avoid buying duplicates.",
                        accentColor: AppTheme.secondary
                    )
                    
                    Divider().padding(.horizontal)
                    
                    EnhancedTipRow(
                        icon: "leaf.fill",
                        title: "Buy Seasonal Produce",
                        description: "Seasonal fruits and vegetables are fresher, tastier, and often less expensive.",
                        accentColor: .green
                    )
                    
                    Divider().padding(.horizontal)
                    
                    EnhancedTipRow(
                        icon: "checklist",
                        title: "Shop with a List",
                        description: "Using a shopping list helps you stay focused and avoid impulse purchases.",
                        accentColor: AppTheme.accentTeal
                    )
                    
                    // Add app integration tip linking to meal plan
                    Divider().padding(.horizontal)
                    
                    NavigationLink(destination: MealPlanView()) {
                        EnhancedTipRow(
                            icon: "cart.fill.badge.plus",
                            title: "Use Your Meal Plan",
                            description: "Create a shopping list directly from your meal plan to ensure you have everything you need.",
                            accentColor: .orange,
                            isNavigationLink: true
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .shadow(color: Color(.systemGray4).opacity(0.5), radius: 3)
                .padding(.horizontal)
                
                // Seasonal tips section
                Text("Seasonal Tips")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.primaryDark)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                // Use the current month to show relevant seasonal tips
                SeasonalTipsCard()
            }
            .padding(.bottom, 100)
        }
        .navigationTitle("Shopping Tips")
        .background(AppTheme.backgroundGreen.opacity(0.5).ignoresSafeArea())
    }
}

// Enhanced tip row with icon and better styling
struct EnhancedTipRow: View {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
    var isNavigationLink: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon with circular background
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundColor(accentColor)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isNavigationLink ? accentColor : .primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if isNavigationLink {
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(accentColor.opacity(0.7))
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}

// Seasonal tips based on current month
struct SeasonalTipsCard: View {
    // Get current month
    @State private var currentMonth = Calendar.current.component(.month, from: Date())
    
    var seasonalTip: (title: String, description: String, icon: String) {
        // Return different tips based on season
        switch currentMonth {
        case 12, 1, 2: // Winter
            return ("Winter Produce Picks", "Look for citrus fruits, root vegetables, and winter squash for the best value.", "snowflake")
        case 3, 4, 5: // Spring
            return ("Spring Produce Picks", "Asparagus, peas, and strawberries are at their best during spring months.", "leaf")
        case 6, 7, 8: // Summer
            return ("Summer Produce Picks", "Berries, stone fruits, and tomatoes are abundant and affordable in summer.", "sun.max.fill")
        case 9, 10, 11: // Fall
            return ("Fall Produce Picks", "Apples, pears, and pumpkins offer the best value during autumn months.", "leaf.fill")
        default:
            return ("Seasonal Produce", "Buying what's in season ensures the best quality at the lowest prices.", "leaf")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: seasonalTip.icon)
                    .foregroundColor(.orange)
                    .font(.title3)
                
                Text(seasonalTip.title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text(seasonalTip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .preferredColorScheme(.dark)
    }
} 
