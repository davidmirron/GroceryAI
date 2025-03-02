import Foundation

enum DietaryTag: String, Codable, CaseIterable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case lowCarb = "Low-Carb"
    case keto = "Keto"
    case paleo = "Paleo"
    case pescatarian = "Pescatarian"
} 