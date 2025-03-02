import Foundation

struct Ingredient: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let unit: Unit
    let category: IngredientCategory
    let isPerishable: Bool
    let typicalShelfLife: Int // in days
    let notes: String?
    let customOrder: Int?
    
    enum Unit: String {
        case grams = "g"
        case liters = "L"
        case pieces = "pcs"
    }
    
    enum IngredientCategory: String, CaseIterable {
        case dairy
        case produce
        case pantry
        case bakery
        case meat
        case seafood
        case frozen
        case beverages
        case other
    }
    
    /// Initializes a new Ingredient instance.
    init(id: UUID = UUID(),
         name: String,
         amount: Double,
         unit: Unit,
         category: IngredientCategory,
         isPerishable: Bool,
         typicalShelfLife: Int,
         notes: String? = nil,
         customOrder: Int? = nil) {
        
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.category = category
        self.isPerishable = isPerishable
        self.typicalShelfLife = typicalShelfLife
        self.notes = notes
        self.customOrder = customOrder
    }
} 