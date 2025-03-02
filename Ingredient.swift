import Foundation

struct Ingredient: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let unit: Unit
    
    enum Unit: String {
        case grams = "g"
        case liters = "L"
        case pieces = "pcs"
    }
} 