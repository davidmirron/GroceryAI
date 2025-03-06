//
//  ContentView.swift
//  GroceryAI
//
//  Created by David Miron on 28.02.2025.
//

import SwiftUI

struct ContentView: View {
    // Access the shared RecipeListViewModel from the environment
    @EnvironmentObject var recipeListViewModel: RecipeListViewModel
    
    var body: some View {
        MainTabView(recipeListViewModel: recipeListViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(RecipeListViewModel())
    }
}
