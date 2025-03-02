import Foundation

struct Ingredient: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var unit: Unit
    var category: IngredientCategory
    var isPerishable: Bool
    var typicalShelfLife: Int?
    var notes: String?
    var customOrder: Int?
    
    enum Unit: String, Codable {
        case grams = "g"
        case liters = "L"
        case pieces = "pcs"
        case cups = "cups"
    }
    
    init(id: UUID = UUID(), 
         name: String, 
         amount: Double, 
         unit: Unit, 
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
}

enum IngredientCategory: String, Codable, CaseIterable {
    case dairy = "Dairy"
    case produce = "Produce"
    case pantry = "Pantry"
    case meat = "Meat & Seafood"
    case frozen = "Frozen"
    case other = "Other"
} 