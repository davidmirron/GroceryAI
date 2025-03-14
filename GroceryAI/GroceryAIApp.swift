//
//  GroceryAIApp.swift
//  GroceryAI
//
//  Created by David Miron on 28.02.2025.
//

import SwiftUI
import CoreData
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct GroceryAIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showOnboarding = false
    @Environment(\.scenePhase) private var scenePhase
    
    // Create a RecipeListViewModel to hold recipe data
    @StateObject private var recipeListViewModel = RecipeListViewModel()
    
    init() {
        // Initialize the GroceryItemsDatabase by adding any custom items
        GroceryItemsDatabase.addCustomItems()
        
        // Configure appearance
        configureAppearance()
        
        // Initialize CoreData
        _ = CoreDataManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(recipeListViewModel) // Make available throughout the app
                .onAppear {
                    if !hasSeenOnboarding {
                        showOnboarding = true
                    }
                    
                    // Load recipes from JSON file (if needed)
                    loadRecipesIfNeeded()
                    
                    // Prune old image cache files
                    ImageLoader.shared.pruneCache()
                }
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView(showOnboarding: $showOnboarding)
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .inactive {
                        // Save any pending changes when app becomes inactive
                        CoreDataManager.shared.saveContext()
                        
                        // Prune image cache when app becomes inactive
                        ImageLoader.shared.pruneCache()
                    } else if newPhase == .background {
                        // Clear memory cache when app goes to background
                        ImageLoader.shared.clearMemoryCache()
                    } else if oldPhase == .background && newPhase == .active {
                        // App coming back to foreground - might check for updates
                    }
                }
        }
    }
    
    // Configure the app appearance settings
    private func configureAppearance() {
        // Configure navigation appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(AppTheme.background)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.text)]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppTheme.text)]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
    
    // Load recipes from JSON if not already loaded
    private func loadRecipesIfNeeded() {
        // Check if recipes are already loaded from CoreData
        let recipeCount = CoreDataManager.shared.getRecipeCount()
        let hasLoadedJSON = UserDefaults.standard.bool(forKey: "hasLoadedRecipeJSON")
        
        // Get the current app version for comparison
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        let lastRecipeVersion = UserDefaults.standard.string(forKey: "lastRecipeJSONVersion") ?? "0"
        
        // Force a refresh if the app version has changed or if recipes haven't been loaded yet
        let needsRefresh = recipeCount == 0 || !hasLoadedJSON || currentVersion != lastRecipeVersion
        
        if needsRefresh {
            // Clear existing recipes to avoid duplicates
            if hasLoadedJSON {
                print("🔄 App version changed: \(lastRecipeVersion) → \(currentVersion)")
                print("Refreshing recipe database...")
                
                // Clear existing recipes from CoreData
                CoreDataManager.shared.deleteAllRecipes()
            } else {
                print("🍳 Initial app launch: Loading recipe database")
            }
            
            // Load recipes from JSON file
            recipeListViewModel.loadRecipesFromJSON()
            
            // Enhance recipes with web images
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.recipeListViewModel.enhanceRecipeImages()
            }
            
            // Mark as loaded so we don't load again (unless needed)
            UserDefaults.standard.set(true, forKey: "hasLoadedRecipeJSON")
            UserDefaults.standard.set(currentVersion, forKey: "lastRecipeJSONVersion")
        } else {
            print("✅ Recipe database already loaded (version \(lastRecipeVersion))")
            print("📦 Found \(recipeCount) recipes in CoreData")
            
            // Check if we need to enhance images (for existing recipes)
            let hasEnhancedImages = UserDefaults.standard.bool(forKey: "hasEnhancedRecipeImages")
            if !hasEnhancedImages {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("🖼️ Enhancing existing recipe images with web URLs...")
                    self.recipeListViewModel.enhanceRecipeImages()
                    UserDefaults.standard.set(true, forKey: "hasEnhancedRecipeImages")
                }
            }
        }
        
        // Print recipe statistics to verify loading was successful
        // (Run after a slight delay to allow loading to complete)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.recipeListViewModel.recipes.count > 0 {
                print("\n📊 Recipe Database Summary:")
                print("Total recipes: \(self.recipeListViewModel.recipes.count)")
                
                // Print top categories
                let topCategories = self.recipeListViewModel.recipeCategoryCounts()
                    .sorted(by: { $0.value > $1.value })
                    .prefix(3)
                
                print("Top categories: \(topCategories.map { "\($0.key) (\($0.value))" }.joined(separator: ", "))")
                
                // Print top dietary tags
                let topDietaryTags = self.recipeListViewModel.recipeDietaryTagCounts()
                    .sorted(by: { $0.value > $1.value })
                    .prefix(3)
                
                if !topDietaryTags.isEmpty {
                    print("Top dietary tags: \(topDietaryTags.map { "\($0.key) (\($0.value))" }.joined(separator: ", "))")
                }
                
                // Clean up any memory-hungry objects we don't need at startup
                autoreleasepool {
                    // Force a memory cleanup
                    ImageLoader.shared.clearCache()
                }
                
                // Preload images for a smoother user experience
                // Start after a short delay to avoid interfering with app launch
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.recipeListViewModel.preloadRecipeImages()
                }
            } else {
                print("⚠️ No recipes found in database. Check JSON loading.")
            }
        }
    }
}
