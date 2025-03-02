import Foundation

class QuantityManager {
    
    // MARK: - Default Quantities
    
    static func defaultQuantity(for item: String, category: IngredientCategory, unit: UnitType) -> Double {
        let lowercasedName = item.lowercased()
        
        // Handle special cases first
        if unit == .liters || unit == .milliliters {
            return defaultLiquidQuantity(for: lowercasedName)
        }
        
        if unit == .pieces || unit == .count {
            return defaultCountQuantity(for: lowercasedName)
        }
        
        // Handle by category
        switch category {
        case .produce:
            if isSmallProduce(lowercasedName) {
                return 250.0 // 250g for small produce
            } else {
                return 500.0 // 500g for regular produce
            }
            
        case .meat:
            return 500.0 // 500g default for meat
            
        case .dairy:
            if ["cheese", "butter"].contains(where: lowercasedName.contains) {
                return 250.0 // 250g for solid dairy
            } else {
                return 1000.0 // 1L for liquid dairy (should use liters unit)
            }
            
        case .pantry:
            if ["spice", "herb", "salt", "pepper"].contains(where: lowercasedName.contains) {
                return 50.0 // 50g for spices
            } else if ["oil", "vinegar"].contains(where: lowercasedName.contains) {
                return 500.0 // 500ml for oils (should use ml unit)
            } else if ["pasta", "rice", "flour", "sugar"].contains(where: lowercasedName.contains) {
                return 500.0 // 500g for common pantry staples
            } else {
                return 250.0 // 250g default
            }
            
        case .frozen:
            return 400.0 // 400g default for frozen items
            
        default:
            return 250.0 // 250g default for other categories
        }
    }
    
    private static func defaultLiquidQuantity(for item: String) -> Double {
        if ["milk", "juice", "water"].contains(where: item.contains) {
            return 1000.0 // 1L for common beverages
        } else if ["oil", "vinegar", "sauce"].contains(where: item.contains) {
            return 500.0 // 500ml for cooking liquids
        } else {
            return 500.0 // 500ml default
        }
    }
    
    private static func defaultCountQuantity(for item: String) -> Double {
        if ["egg", "eggs"].contains(where: item.contains) {
            return 12.0 // Dozen eggs
        } else if ["apple", "orange", "banana", "lemon", "lime"].contains(where: item.contains) {
            return 6.0 // 6 pieces for common fruits
        } else if ["onion", "potato", "tomato"].contains(where: item.contains) {
            return 4.0 // 4 pieces for common vegetables
        } else {
            return 1.0 // 1 piece default
        }
    }
    
    private static func isSmallProduce(_ name: String) -> Bool {
        return ["berry", "berries", "grape", "cherry", "herb", "garlic", "shallot", "radish"]
            .contains(where: name.contains)
    }
    
    // MARK: - Increment Logic
    
    static func nextIncrement(current: Double, unit: UnitType) -> Double {
        switch unit {
        case .grams, .kilograms:
            return nextWeightIncrement(current)
        case .milliliters, .liters:
            return nextVolumeIncrement(current)
        case .pieces, .count:
            return nextCountIncrement(current)
        case .tablespoons, .teaspoons:
            return current + 1.0 // Always increment by 1 for spoon measures
        case .cups:
            return nextCupIncrement(current)
        }
    }
    
    static func previousIncrement(current: Double, unit: UnitType) -> Double {
        switch unit {
        case .grams, .kilograms:
            return previousWeightIncrement(current)
        case .milliliters, .liters:
            return previousVolumeIncrement(current)
        case .pieces, .count:
            return previousCountIncrement(current)
        case .tablespoons, .teaspoons:
            return max(1.0, current - 1.0) // Don't go below 1
        case .cups:
            return previousCupIncrement(current)
        }
    }
    
    private static func nextWeightIncrement(_ current: Double) -> Double {
        if current < 10 {
            return current + 1.0 // 1g increments below 10g
        } else if current < 100 {
            return current + 10.0 // 10g increments below 100g
        } else if current < 1000 {
            return current + 100.0 // 100g increments below 1kg
        } else {
            return current + 500.0 // 500g increments above 1kg
        }
    }
    
    private static func previousWeightIncrement(_ current: Double) -> Double {
        if current <= 10 {
            return max(1.0, current - 1.0) // 1g decrements, minimum 1g
        } else if current <= 100 {
            return current - 10.0 // 10g decrements
        } else if current <= 1000 {
            return current - 100.0 // 100g decrements
        } else {
            return current - 500.0 // 500g decrements
        }
    }
    
    private static func nextVolumeIncrement(_ current: Double) -> Double {
        if current < 10 {
            return current + 1.0 // 1ml increments below 10ml
        } else if current < 100 {
            return current + 10.0 // 10ml increments below 100ml
        } else if current < 1000 {
            return current + 100.0 // 100ml increments below 1L
        } else {
            return current + 500.0 // 500ml increments above 1L
        }
    }
    
    private static func previousVolumeIncrement(_ current: Double) -> Double {
        if current <= 10 {
            return max(1.0, current - 1.0) // 1ml decrements, minimum 1ml
        } else if current <= 100 {
            return current - 10.0 // 10ml decrements
        } else if current <= 1000 {
            return current - 100.0 // 100ml decrements
        } else {
            return current - 500.0 // 500ml decrements
        }
    }
    
    private static func nextCountIncrement(_ current: Double) -> Double {
        if current < 10 {
            return current + 1.0 // 1 piece increment below 10
        } else if current < 50 {
            return current + 5.0 // 5 piece increments below 50
        } else {
            return current + 10.0 // 10 piece increments above 50
        }
    }
    
    private static func previousCountIncrement(_ current: Double) -> Double {
        if current <= 10 {
            return max(1.0, current - 1.0) // 1 piece decrement, minimum 1
        } else if current <= 50 {
            return current - 5.0 // 5 piece decrements
        } else {
            return current - 10.0 // 10 piece decrements
        }
    }
    
    private static func nextCupIncrement(_ current: Double) -> Double {
        if current < 1.0 {
            // Handle fractions of cups
            if current < 0.25 {
                return 0.25 // Go to 1/4 cup
            } else if current < 0.5 {
                return 0.5 // Go to 1/2 cup
            } else if current < 0.75 {
                return 0.75 // Go to 3/4 cup
            } else {
                return 1.0 // Go to 1 cup
            }
        } else {
            return current + 0.5 // 1/2 cup increments above 1 cup
        }
    }
    
    private static func previousCupIncrement(_ current: Double) -> Double {
        if current <= 1.0 {
            // Handle fractions of cups
            if current <= 0.25 {
                return 0.25 // Minimum 1/4 cup
            } else if current <= 0.5 {
                return 0.25 // Go to 1/4 cup
            } else if current <= 0.75 {
                return 0.5 // Go to 1/2 cup
            } else {
                return 0.75 // Go to 3/4 cup
            }
        } else {
            return current - 0.5 // 1/2 cup decrements
        }
    }
    
    // MARK: - Formatting
    
    static func formatQuantity(_ quantity: Double, unit: UnitType) -> String {
        switch unit {
        case .grams:
            if quantity >= 1000 {
                return String(format: "%.1f kg", quantity/1000)
            } else if quantity >= 100 {
                return String(format: "%.0f g", quantity)  // No decimal for 100+
            } else if quantity >= 10 {
                return String(format: "%.0f g", quantity)  // No decimal for 10+
            } else {
                return String(format: "%.1f g", quantity)  // One decimal for small amounts
            }
            
        case .kilograms:
            if quantity < 1 {
                return String(format: "%.0f g", quantity * 1000)
            } else if quantity < 10 {
                return String(format: "%.1f kg", quantity)
            } else {
                return String(format: "%.0f kg", quantity)
            }
            
        case .milliliters:
            if quantity >= 1000 {
                return String(format: "%.1f L", quantity/1000)
            } else if quantity >= 100 {
                return String(format: "%.0f ml", quantity)
            } else {
                return String(format: "%.0f ml", quantity)
            }
            
        case .liters:
            if quantity < 1 {
                return String(format: "%.0f ml", quantity * 1000)
            } else if quantity < 10 {
                return String(format: "%.1f L", quantity)
            } else {
                return String(format: "%.0f L", quantity)
            }
            
        case .pieces, .count:
            if quantity == 1 {
                return "1 pc"
            } else {
                return String(format: "%.0f pcs", quantity)
            }
            
        case .tablespoons:
            if quantity == 1 {
                return "1 tbsp"
            } else {
                return String(format: "%.0f tbsp", quantity)
            }
            
        case .teaspoons:
            if quantity == 1 {
                return "1 tsp"
            } else {
                return String(format: "%.0f tsp", quantity)
            }
            
        case .cups:
            if quantity < 1 {
                // Handle fractions
                if quantity == 0.25 {
                    return "¼ cup"
                } else if quantity == 0.5 {
                    return "½ cup"
                } else if quantity == 0.75 {
                    return "¾ cup"
                } else {
                    return String(format: "%.2f cups", quantity)
                }
            } else if quantity == 1 {
                return "1 cup"
            } else {
                // Handle whole and half cups
                let isWholeNumber = quantity.truncatingRemainder(dividingBy: 1) == 0
                let isHalfCup = quantity.truncatingRemainder(dividingBy: 1) == 0.5
                
                if isWholeNumber {
                    return String(format: "%.0f cups", quantity)
                } else if isHalfCup {
                    let whole = Int(quantity)
                    return "\(whole)½ cups"
                } else {
                    return String(format: "%.1f cups", quantity)
                }
            }
        }
    }
    
    // MARK: - Smart Unit Selection
    
    static func suggestUnit(for item: String, category: IngredientCategory) -> UnitType {
        let lowercasedName = item.lowercased()
        
        // Liquids
        if ["milk", "juice", "water", "oil", "vinegar", "sauce", "drink", "beverage", "soup"]
            .contains(where: lowercasedName.contains) {
            return .liters
        }
        
        // Count items
        if ["egg", "apple", "orange", "banana", "lemon", "lime", "onion", "potato", "tomato", "avocado", "bread"]
            .contains(where: lowercasedName.contains) {
            return .pieces
        }
        
        // Spices and small quantities
        if ["spice", "herb", "salt", "pepper", "cinnamon", "nutmeg", "oregano", "basil"]
            .contains(where: lowercasedName.contains) {
            return .teaspoons
        }
        
        // Default by category
        switch category {
        case .produce, .meat, .pantry:
            return .grams
        case .dairy:
            // Most dairy is by weight, except milk which is caught above
            return .grams
        case .frozen:
            return .grams
        default:
            return .grams
        }
    }
} 