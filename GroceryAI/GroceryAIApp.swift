//
//  GroceryAIApp.swift
//  GroceryAI
//
//  Created by David Miron on 28.02.2025.
//

import SwiftUI

@main
struct GroceryAIApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showOnboarding = false
    
    init() {
        // Initialize the GroceryItemsDatabase by adding any custom items
        GroceryItemsDatabase.addCustomItems()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if !hasSeenOnboarding {
                        showOnboarding = true
                    }
                }
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView(showOnboarding: $showOnboarding)
                }
        }
    }
}
