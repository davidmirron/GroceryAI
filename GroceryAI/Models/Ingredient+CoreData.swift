import Foundation
import CoreData

// Extension to convert between Ingredient and CDIngredient (CoreData)
extension Ingredient {
    
    // Convert an Ingredient to a CDIngredient (CoreData entity)
    func toCoreData(in context: NSManagedObjectContext) -> CDIngredient {
        let cdIngredient = CDIngredient(context: context)
        
        // Set basic properties
        cdIngredient.id = self.id
        cdIngredient.name = self.name
        cdIngredient.amount = self.amount
        cdIngredient.unit = self.unit.rawValue
        cdIngredient.category = self.category.rawValue
        cdIngredient.isPerishable = self.isPerishable
        
        // Set optional properties
        if let typicalShelfLife = self.typicalShelfLife {
            cdIngredient.typicalShelfLife = Int32(typicalShelfLife)
        }
        
        cdIngredient.notes = self.notes
        
        if let customOrder = self.customOrder {
            cdIngredient.customOrder = Int32(customOrder)
        }
        
        return cdIngredient
    }
    
    // Create an Ingredient from a CDIngredient (CoreData entity)
    static func fromCoreData(_ cdIngredient: CDIngredient) -> Ingredient {
        // Determine ingredient unit
        let unit = IngredientUnit(rawValue: cdIngredient.unit ?? "pieces") ?? .pieces
        
        // Determine ingredient category
        let category = IngredientCategory(rawValue: cdIngredient.category ?? "other") ?? .other
        
        // Convert optional values
        let typicalShelfLife: Int?
        if cdIngredient.typicalShelfLife > 0 {
            typicalShelfLife = Int(cdIngredient.typicalShelfLife)
        } else {
            typicalShelfLife = nil
        }
        
        let customOrder: Int?
        if cdIngredient.customOrder > 0 {
            customOrder = Int(cdIngredient.customOrder)
        } else {
            customOrder = nil
        }
        
        // Create and return the Ingredient
        return Ingredient(
            id: cdIngredient.id ?? UUID(),
            name: cdIngredient.name ?? "",
            amount: cdIngredient.amount,
            unit: unit,
            category: category,
            isPerishable: cdIngredient.isPerishable,
            typicalShelfLife: typicalShelfLife,
            notes: cdIngredient.notes,
            customOrder: customOrder
        )
    }
} 