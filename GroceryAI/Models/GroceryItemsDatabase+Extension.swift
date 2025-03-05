import Foundation

extension GroceryItemsDatabase {
    // Add any custom items for your specific app here
    static func addCustomItems() {
        // Seasonal and Holiday Items
        items["turkey"] = GroceryItemData(name: "Turkey", category: .meat, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 5, keywords: ["thanksgiving", "holiday", "dinner"])
        items["cranberry sauce"] = GroceryItemData(name: "Cranberry Sauce", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["thanksgiving", "holiday", "side"])
        items["pumpkin puree"] = GroceryItemData(name: "Pumpkin Puree", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["fall", "pie", "baking"])
        items["eggnog"] = GroceryItemData(name: "Eggnog", category: .dairy, unit: .liters, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["christmas", "holiday", "drink"])
        items["candy canes"] = GroceryItemData(name: "Candy Canes", category: .other, unit: .pieces, defaultAmount: 12.0, isPerishable: false, typicalShelfLife: nil, keywords: ["christmas", "holiday", "sweet"])
        
        // Trending Food Items
        items["oat milk"] = GroceryItemData(name: "Oat Milk", category: .dairy, unit: .liters, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 10, keywords: ["dairy alternative", "vegan", "trendy"])
        items["kombucha"] = GroceryItemData(name: "Kombucha", category: .other, unit: .liters, defaultAmount: 0.5, isPerishable: true, typicalShelfLife: 30, keywords: ["fermented", "probiotic", "trendy"])
        items["kimchi"] = GroceryItemData(name: "Kimchi", category: .produce, unit: .grams, defaultAmount: 500.0, isPerishable: true, typicalShelfLife: 60, keywords: ["korean", "fermented", "spicy"])
        items["cauliflower rice"] = GroceryItemData(name: "Cauliflower Rice", category: .produce, unit: .grams, defaultAmount: 400.0, isPerishable: true, typicalShelfLife: 5, keywords: ["low-carb", "keto", "substitute"])
        items["plant-based burger"] = GroceryItemData(name: "Plant-Based Burger", category: .frozen, unit: .pieces, defaultAmount: 4.0, isPerishable: true, typicalShelfLife: 14, keywords: ["vegetarian", "meat alternative", "trendy"])
        
        // Regional Specialties
        items["salsa verde"] = GroceryItemData(name: "Salsa Verde", category: .pantry, unit: .grams, defaultAmount: 450.0, isPerishable: false, typicalShelfLife: nil, keywords: ["mexican", "sauce", "tomatillo"])
        items["miso paste"] = GroceryItemData(name: "Miso Paste", category: .pantry, unit: .grams, defaultAmount: 300.0, isPerishable: true, typicalShelfLife: 90, keywords: ["japanese", "soup", "umami"])
        items["gochujang"] = GroceryItemData(name: "Gochujang", category: .pantry, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["korean", "paste", "spicy"])
        items["feta cheese"] = GroceryItemData(name: "Feta Cheese", category: .dairy, unit: .grams, defaultAmount: 200.0, isPerishable: true, typicalShelfLife: 14, keywords: ["greek", "salad", "crumbly"])
        items["garam masala"] = GroceryItemData(name: "Garam Masala", category: .pantry, unit: .grams, defaultAmount: 50.0, isPerishable: false, typicalShelfLife: nil, keywords: ["indian", "spice blend", "curry"])
        
        // Special Diet Items
        items["coconut aminos"] = GroceryItemData(name: "Coconut Aminos", category: .pantry, unit: .liters, defaultAmount: 0.25, isPerishable: false, typicalShelfLife: nil, keywords: ["soy-free", "paleo", "sauce"])
        items["monk fruit sweetener"] = GroceryItemData(name: "Monk Fruit Sweetener", category: .pantry, unit: .grams, defaultAmount: 200.0, isPerishable: false, typicalShelfLife: nil, keywords: ["keto", "sweetener", "sugar-free"])
        items["cassava flour"] = GroceryItemData(name: "Cassava Flour", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["paleo", "gluten-free", "flour"])
        items["nutritional yeast"] = GroceryItemData(name: "Nutritional Yeast", category: .pantry, unit: .grams, defaultAmount: 150.0, isPerishable: false, typicalShelfLife: nil, keywords: ["vegan", "cheese substitute", "b-vitamins"])
        
        // Popular Snacks
        items["popcorn kernels"] = GroceryItemData(name: "Popcorn Kernels", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "whole grain", "movie"])
        items["protein bars"] = GroceryItemData(name: "Protein Bars", category: .other, unit: .pieces, defaultAmount: 6.0, isPerishable: false, typicalShelfLife: nil, keywords: ["workout", "protein", "quick"])
        items["seaweed snacks"] = GroceryItemData(name: "Seaweed Snacks", category: .other, unit: .pieces, defaultAmount: 10.0, isPerishable: false, typicalShelfLife: nil, keywords: ["asian", "low-calorie", "crispy"])
        items["dark chocolate"] = GroceryItemData(name: "Dark Chocolate", category: .other, unit: .grams, defaultAmount: 100.0, isPerishable: false, typicalShelfLife: nil, keywords: ["antioxidants", "dessert", "baking"])
    }
} 