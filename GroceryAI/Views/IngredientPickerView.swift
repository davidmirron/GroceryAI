import SwiftUI

struct IngredientPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIngredients: [Ingredient]
    @State private var searchText = ""
    @State private var selectedCategory: IngredientCategory?
    
    // This would come from a database in a real app
    private let availableIngredients: [Ingredient] = [
        Ingredient(name: "Chicken Breast", amount: 1, unit: .pieces, category: .meat),
        Ingredient(name: "Rice", amount: 1, unit: .cups, category: .pantry),
        Ingredient(name: "Tomatoes", amount: 2, unit: .pieces, category: .produce),
        // Add more ingredients...
    ]
    
    var filteredIngredients: [Ingredient] {
        availableIngredients.filter { ingredient in
            let matchesSearch = searchText.isEmpty || 
                ingredient.name.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || 
                ingredient.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(IngredientCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: category == selectedCategory,
                                action: { toggleCategory(category) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                List {
                    ForEach(filteredIngredients) { ingredient in
                        IngredientRow(
                            ingredient: ingredient,
                            isSelected: selectedIngredients.contains { $0.id == ingredient.id },
                            action: { toggleIngredient(ingredient) }
                        )
                    }
                }
                .listStyle(.plain)
            }
            .searchable(text: $searchText, prompt: "Search ingredients")
            .navigationTitle("Add Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func toggleCategory(_ category: IngredientCategory) {
        if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }
    
    private func toggleIngredient(_ ingredient: Ingredient) {
        if let index = selectedIngredients.firstIndex(where: { $0.id == ingredient.id }) {
            selectedIngredients.remove(at: index)
        } else {
            selectedIngredients.append(ingredient)
        }
    }
}

struct CategoryButton: View {
    let category: IngredientCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? .blue : .blue.opacity(0.1))
                .foregroundStyle(isSelected ? .white : .blue)
                .clipShape(Capsule())
        }
    }
}

struct IngredientRow: View {
    let ingredient: Ingredient
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(ingredient.name)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
} 