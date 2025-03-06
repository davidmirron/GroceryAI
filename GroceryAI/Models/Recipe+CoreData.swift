import Foundation
import CoreData

// Extension to convert between Recipe and CDRecipe (CoreData)
extension Recipe {
    
    // Convert a Recipe to a CDRecipe (CoreData entity)
    func toCoreData(in context: NSManagedObjectContext) -> CDRecipe {
        let cdRecipe = CDRecipe(context: context)
        
        // Set basic properties
        cdRecipe.id = self.id
        cdRecipe.name = self.name
        cdRecipe.estimatedTime = self.estimatedTime
        cdRecipe.servings = Int32(self.servings)
        cdRecipe.category = self.category.rawValue
        cdRecipe.difficulty = self.difficulty.rawValue
        cdRecipe.prepTime = self.prepTime
        cdRecipe.cookTime = self.cookTime
        cdRecipe.isCustomRecipe = self.isCustomRecipe
        cdRecipe.matchScore = self.matchScore
        cdRecipe.imageName = self.imageName
        cdRecipe.source = self.source
        
        // Convert instructions array using NSArray casting
        // The CoreData attribute is Transformable with customClassName [String]
        cdRecipe.setValue(self.instructions, forKey: "instructions")
        
        // Convert dietary tags using NSArray casting
        // The CoreData attribute is Transformable with customClassName [String]
        cdRecipe.setValue(self.dietaryTags.map { $0.rawValue }, forKey: "dietaryTags")
        
        // Create and link nutrition info if available
        if let nutritionalInfo = self.nutritionalInfo {
            let cdNutritionInfo = CDNutritionInfo(context: context)
            cdNutritionInfo.calories = Int32(nutritionalInfo.calories)
            cdNutritionInfo.protein = Int32(nutritionalInfo.protein)
            cdNutritionInfo.carbs = Int32(nutritionalInfo.carbs)
            cdNutritionInfo.fat = Int32(nutritionalInfo.fat)
            
            cdRecipe.nutritionalInfo = cdNutritionInfo
        }
        
        // Create and link ingredients
        for ingredient in self.ingredients {
            let cdIngredient = ingredient.toCoreData(in: context)
            cdIngredient.recipe = cdRecipe
        }
        
        // Create and link missing ingredients
        for ingredient in self.missingIngredients {
            let cdIngredient = ingredient.toCoreData(in: context)
            cdIngredient.recipeMissing = cdRecipe
        }
        
        return cdRecipe
    }
    
    // Create a Recipe from a CDRecipe (CoreData entity)
    static func fromCoreData(_ cdRecipe: CDRecipe) -> Recipe {
        // Create nutrition info if available
        let nutritionInfo: NutritionInfo?
        if let cdNutritionInfo = cdRecipe.nutritionalInfo {
            nutritionInfo = NutritionInfo(
                calories: Int(cdNutritionInfo.calories),
                protein: Int(cdNutritionInfo.protein),
                carbs: Int(cdNutritionInfo.carbs),
                fat: Int(cdNutritionInfo.fat)
            )
        } else {
            nutritionInfo = nil
        }
        
        // Convert ingredients
        let ingredients = (cdRecipe.ingredients?.allObjects as? [CDIngredient])?.map { Ingredient.fromCoreData($0) } ?? []
        
        // Convert missing ingredients
        let missingIngredients = (cdRecipe.missingIngredients?.allObjects as? [CDIngredient])?.map { Ingredient.fromCoreData($0) } ?? []
        
        // Convert instructions - properly handle the Transformable attribute
        let instructions = cdRecipe.value(forKey: "instructions") as? [String] ?? []
        
        // Convert dietary tags - properly handle the Transformable attribute
        let dietaryTagStrings = cdRecipe.value(forKey: "dietaryTags") as? [String] ?? []
        let dietaryTags = Set(dietaryTagStrings.compactMap { tagString in
            return DietaryTag.allCases.first { $0.rawValue == tagString }
        })
        
        // Determine recipe category
        let category = RecipeCategory.allCases.first { $0.rawValue == cdRecipe.category } ?? .other
        
        // Determine recipe difficulty
        let difficulty = RecipeDifficulty.allCases.first { $0.rawValue == cdRecipe.difficulty } ?? .medium
        
        // Create and return the Recipe
        let recipe = Recipe(
            id: cdRecipe.id ?? UUID(),
            name: cdRecipe.name ?? "",
            ingredients: ingredients,
            instructions: instructions,
            estimatedTime: cdRecipe.estimatedTime,
            servings: Int(cdRecipe.servings),
            nutritionalInfo: nutritionInfo,
            missingIngredients: missingIngredients,
            dietaryTags: dietaryTags,
            imageName: cdRecipe.imageName,
            matchScore: cdRecipe.matchScore,
            isCustomRecipe: cdRecipe.isCustomRecipe,
            category: category,
            difficulty: difficulty,
            prepTime: cdRecipe.prepTime,
            cookTime: cdRecipe.cookTime,
            source: cdRecipe.source
        )
        
        return recipe
    }
} 