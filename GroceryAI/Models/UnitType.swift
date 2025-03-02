import Foundation

enum UnitType: String, CaseIterable, Codable {
    case grams = "g"
    case kilograms = "kg"
    case milliliters = "ml"
    case liters = "L"
    case pieces = "pcs"
    case count = "count"
    case tablespoons = "tbsp"
    case teaspoons = "tsp"
    case cups = "cup"
    
    var displayName: String {
        switch self {
        case .grams:
            return "g"
        case .kilograms:
            return "kg"
        case .milliliters:
            return "ml"
        case .liters:
            return "L"
        case .pieces:
            return "pcs"
        case .count:
            return "count"
        case .tablespoons:
            return "tbsp"
        case .teaspoons:
            return "tsp"
        case .cups:
            return "cups"
        }
    }
    
    var abbreviation: String {
        return self.rawValue
    }
} 