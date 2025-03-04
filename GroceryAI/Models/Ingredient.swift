import Foundation

struct Ingredient: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var amount: Double
    var unit: IngredientUnit
    var category: IngredientCategory
    var isPerishable: Bool
    var typicalShelfLife: Int? // in days
    var notes: String?
    var customOrder: Int?
    
    init(id: UUID = UUID(), 
         name: String, 
         amount: Double, 
         unit: IngredientUnit, 
         category: IngredientCategory = .other,
         isPerishable: Bool = false,
         typicalShelfLife: Int? = nil,
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
    
    // Implement Equatable to compare ingredients
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.id == rhs.id
    }
}

enum IngredientUnit: String, Codable, CaseIterable {
    case pieces = "pcs"
    case grams = "g"
    case kilograms = "kg"
    case milliliters = "ml"
    case liters = "L"
    case cups = "cups"
    case tablespoons = "tbsp"
    case teaspoons = "tsp"
    case pounds = "lbs"
    case ounces = "oz"
    case units = "units"
}

enum IngredientCategory: String, Codable, CaseIterable {
    case dairy = "Dairy"
    case produce = "Produce"
    case pantry = "Pantry"
    case meat = "Meat & Seafood"
    case frozen = "Frozen"
    case bakery = "Bakery"
    case seafood = "Seafood" 
    case beverages = "Beverages"
    case other = "Other"
} 