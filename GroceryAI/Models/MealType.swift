import SwiftUI

/// Enum representing different meal types
/// - Includes helper properties for display, icons, and theme colors
/// - Follows Apple's design language with semantic naming
enum MealType: String, CaseIterable, Codable {
    case breakfast
    case lunch
    case dinner
    case snack
    
    /// User-friendly display name for the meal type
    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        }
    }
    
    /// Icon name from SF Symbols that best represents the meal type
    var iconName: String {
        switch self {
        case .breakfast: return "sunrise"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .snack: return "carrot"
        }
    }
    
    /// Theme color from AppTheme that corresponds to this meal type
    var themeColor: Color {
        switch self {
        case .breakfast: return AppTheme.breakfastColor
        case .lunch: return AppTheme.lunchColor  
        case .dinner: return AppTheme.dinnerColor
        case .snack: return AppTheme.snackColor
        }
    }
    
    /// Keywords commonly associated with each meal type for filtering
    var associatedKeywords: [String] {
        switch self {
        case .breakfast:
            return ["breakfast", "morning", "cereal", "oatmeal", "pancake", "waffle", "egg", "toast", "bagel", "coffee", "juice", "pastry", "croissant"]
        case .lunch:
            return ["lunch", "sandwich", "soup", "salad", "wrap", "bowl", "pasta", "noodle", "midday", "burger", "quesadilla", "taco"]
        case .dinner:
            return ["dinner", "supper", "evening", "roast", "steak", "chicken", "fish", "curry", "casserole", "stew", "potato", "pasta", "rice", "hearty"]
        case .snack:
            return ["snack", "appetizer", "quick", "small", "bite", "fruit", "nut", "yogurt", "bar", "chip", "cracker", "popcorn", "treat", "dessert", "cookie", "cake"]
        }
    }
    
    /// Time range when this meal typically occurs
    var typicalTimeRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = Date()
        
        switch self {
        case .breakfast:
            // 5 AM - 10 AM
            let start = calendar.date(bySettingHour: 5, minute: 0, second: 0, of: today)!
            let end = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today)!
            return start...end
            
        case .lunch:
            // 11 AM - 2 PM
            let start = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: today)!
            let end = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today)!
            return start...end
            
        case .dinner:
            // 5 PM - 9 PM
            let start = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: today)!
            let end = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: today)!
            return start...end
            
        case .snack:
            // All day (10 AM - 10 PM)
            let start = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today)!
            let end = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: today)!
            return start...end
        }
    }
} 