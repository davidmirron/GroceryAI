import Foundation

struct GroceryItemData {
    let name: String
    let category: IngredientCategory
    let unit: IngredientUnit
    let defaultAmount: Double
    let isPerishable: Bool
    let typicalShelfLife: Int? // in days
    let keywords: [String]
}

struct GroceryItemsDatabase {
    static var items: [String: GroceryItemData] = [
        // FROZEN
        "frozen vegetables": GroceryItemData(name: "Frozen Vegetables", category: .frozen, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["frozen", "vegetable", "mixed"]),
        "frozen french fries": GroceryItemData(name: "Frozen French Fries", category: .frozen, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["frozen", "potato", "side dish"]),
        "frozen waffles": GroceryItemData(name: "Frozen Waffles", category: .frozen, unit: .pieces, defaultAmount: 8.0, isPerishable: false, typicalShelfLife: nil, keywords: ["frozen", "breakfast", "quick"]),
        "frozen breakfast sandwich": GroceryItemData(name: "Frozen Breakfast Sandwich", category: .frozen, unit: .pieces, defaultAmount: 4.0, isPerishable: false, typicalShelfLife: nil, keywords: ["frozen", "breakfast", "quick"]),
        "frozen dinner": GroceryItemData(name: "Frozen Dinner", category: .frozen, unit: .pieces, defaultAmount: 2.0, isPerishable: false, typicalShelfLife: nil, keywords: ["frozen", "meal", "convenience"]),
        "frozen lasagna": GroceryItemData(name: "Frozen Lasagna", category: .frozen, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["frozen", "dinner", "italian"]),
        "frozen burrito": GroceryItemData(name: "Frozen Burrito", category: .frozen, unit: .pieces, defaultAmount: 4.0, isPerishable: false, typicalShelfLife: nil, keywords: ["frozen", "mexican", "quick"]),
        "frozen meatballs": GroceryItemData(name: "Frozen Meatballs", category: .frozen, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["frozen", "meat", "pasta"]),
        "frozen pizza": GroceryItemData(name: "Frozen Pizza", category: .frozen, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["frozen", "dinner", "quick"]),
        "frozen berries": GroceryItemData(name: "Frozen Berries", category: .frozen, unit: .grams, defaultAmount: 450.0, isPerishable: false, typicalShelfLife: nil, keywords: ["frozen", "fruit", "smoothie"]),
        "ice cream": GroceryItemData(name: "Ice Cream", category: .frozen, unit: .liters, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["frozen", "dessert", "sweet"]),
        "frozen fish fillets": GroceryItemData(name: "Frozen Fish Fillets", category: .frozen, unit: .pieces, defaultAmount: 4.0, isPerishable: false, typicalShelfLife: nil, keywords: ["frozen", "seafood", "protein"]),
        
        // SNACKS
        "chips": GroceryItemData(name: "Chips", category: .other, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "crunchy", "savory"]),
        "potato chips": GroceryItemData(name: "Potato Chips", category: .other, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "crunchy", "salty"]),
        "tortilla chips": GroceryItemData(name: "Tortilla Chips", category: .other, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "mexican", "corn"]),
        "pretzels": GroceryItemData(name: "Pretzels", category: .other, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "crunchy", "salty"]),
        "popcorn": GroceryItemData(name: "Popcorn", category: .other, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "movie", "light"]),
        "peanuts": GroceryItemData(name: "Peanuts", category: .other, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "nuts", "protein"]),
        "almonds": GroceryItemData(name: "Almonds", category: .other, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "nuts", "protein"]),
        "candy": GroceryItemData(name: "Candy", category: .other, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "sweet", "treat"]),
        "chocolate": GroceryItemData(name: "Chocolate", category: .other, unit: .grams, defaultAmount: 200.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "sweet", "dessert"]),
        "granola bars": GroceryItemData(name: "Granola Bars", category: .other, unit: .pieces, defaultAmount: 8.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "breakfast", "portable"]),
        "energy bars": GroceryItemData(name: "Energy Bars", category: .other, unit: .pieces, defaultAmount: 8.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "protein", "workout"]),
        "beef jerky": GroceryItemData(name: "Beef Jerky", category: .other, unit: .grams, defaultAmount: 150.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "protein", "meat"]),
        "dried fruit": GroceryItemData(name: "Dried Fruit", category: .other, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "sweet", "fiber"]),
        "rice cakes": GroceryItemData(name: "Rice Cakes", category: .other, unit: .pieces, defaultAmount: 12.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "light", "low calorie"]),
        "trail mix": GroceryItemData(name: "Trail Mix", category: .other, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "hiking", "energy"]),
        "cookies": GroceryItemData(name: "Cookies", category: .other, unit: .grams, defaultAmount: 300.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "sweet", "dessert"]),
        "crackers": GroceryItemData(name: "Crackers", category: .other, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "crunchy", "cheese"]),
        "protein balls": GroceryItemData(name: "Protein Balls", category: .other, unit: .pieces, defaultAmount: 6.0, isPerishable: false, typicalShelfLife: nil, keywords: ["snack", "protein", "healthy"]),
        
        // HOUSEHOLD ITEMS
        "toilet paper": GroceryItemData(name: "Toilet Paper", category: .other, unit: .pieces, defaultAmount: 12.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "bathroom", "essential"]),
        "paper towels": GroceryItemData(name: "Paper Towels", category: .other, unit: .pieces, defaultAmount: 4.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "cleaning", "kitchen"]),
        "tissues": GroceryItemData(name: "Tissues", category: .other, unit: .pieces, defaultAmount: 2.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "cold", "kleenex"]),
        "dish soap": GroceryItemData(name: "Dish Soap", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "cleaning", "kitchen"]),
        "laundry detergent": GroceryItemData(name: "Laundry Detergent", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "cleaning", "clothes"]),
        "all purpose cleaner": GroceryItemData(name: "All Purpose Cleaner", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "cleaning", "spray"]),
        "sponges": GroceryItemData(name: "Sponges", category: .other, unit: .pieces, defaultAmount: 4.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "cleaning", "kitchen"]),
        "trash bags": GroceryItemData(name: "Trash Bags", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "kitchen", "garbage"]),
        "aluminum foil": GroceryItemData(name: "Aluminum Foil", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "kitchen", "wrapping"]),
        "plastic wrap": GroceryItemData(name: "Plastic Wrap", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "kitchen", "wrapping"]),
        "zip bags": GroceryItemData(name: "Zip Bags", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "storage", "ziploc"]),
        "parchment paper": GroceryItemData(name: "Parchment Paper", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "baking", "non-stick"]),
        "dish sponges": GroceryItemData(name: "Dish Sponges", category: .other, unit: .pieces, defaultAmount: 3.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "cleaning", "kitchen"]),
        "dishwasher pods": GroceryItemData(name: "Dishwasher Pods", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "cleaning", "kitchen"]),
        "batteries": GroceryItemData(name: "Batteries", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "electronics", "essential"]),
        "light bulbs": GroceryItemData(name: "Light Bulbs", category: .other, unit: .pieces, defaultAmount: 4.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "lighting", "essential"]),
        "paper plates": GroceryItemData(name: "Paper Plates", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "party", "disposable"]),
        "hand soap": GroceryItemData(name: "Hand Soap", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["household", "bathroom", "hygiene"]),
        
        // INTERNATIONAL FOODS
        "soy sauce": GroceryItemData(name: "Soy Sauce", category: .pantry, unit: .liters, defaultAmount: 0.5, isPerishable: false, typicalShelfLife: nil, keywords: ["asian", "condiment", "umami"]),
        "fish sauce": GroceryItemData(name: "Fish Sauce", category: .pantry, unit: .liters, defaultAmount: 0.25, isPerishable: false, typicalShelfLife: nil, keywords: ["asian", "thai", "condiment"]),
        "hoisin sauce": GroceryItemData(name: "Hoisin Sauce", category: .pantry, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["asian", "chinese", "sweet"]),
        "teriyaki sauce": GroceryItemData(name: "Teriyaki Sauce", category: .pantry, unit: .liters, defaultAmount: 0.25, isPerishable: false, typicalShelfLife: nil, keywords: ["asian", "japanese", "sweet"]),
        "oyster sauce": GroceryItemData(name: "Oyster Sauce", category: .pantry, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["asian", "chinese", "umami"]),
        "sriracha": GroceryItemData(name: "Sriracha", category: .pantry, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["asian", "hot sauce", "spicy"]),
        "sweet chili sauce": GroceryItemData(name: "Sweet Chili Sauce", category: .pantry, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["asian", "thai", "dipping"]),
        "nori": GroceryItemData(name: "Nori", category: .pantry, unit: .pieces, defaultAmount: 10.0, isPerishable: false, typicalShelfLife: nil, keywords: ["asian", "japanese", "seaweed"]),
        "salsa": GroceryItemData(name: "Salsa", category: .pantry, unit: .grams, defaultAmount: 450.0, isPerishable: false, typicalShelfLife: nil, keywords: ["mexican", "dip", "tomato"]),
        "guacamole": GroceryItemData(name: "Guacamole", category: .produce, unit: .grams, defaultAmount: 250.0, isPerishable: true, typicalShelfLife: 3, keywords: ["mexican", "dip", "avocado"]),
        "hummus": GroceryItemData(name: "Hummus", category: .produce, unit: .grams, defaultAmount: 250.0, isPerishable: true, typicalShelfLife: 7, keywords: ["mediterranean", "dip", "chickpea"]),
        "tahini": GroceryItemData(name: "Tahini", category: .pantry, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["mediterranean", "sesame", "hummus"]),
        "tzatziki": GroceryItemData(name: "Tzatziki", category: .dairy, unit: .grams, defaultAmount: 250.0, isPerishable: true, typicalShelfLife: 7, keywords: ["greek", "yogurt", "cucumber"]),
        "curry paste": GroceryItemData(name: "Curry Paste", category: .pantry, unit: .grams, defaultAmount: 200.0, isPerishable: false, typicalShelfLife: nil, keywords: ["indian", "thai", "spicy"]),
        "coconut milk": GroceryItemData(name: "Coconut Milk", category: .pantry, unit: .liters, defaultAmount: 0.4, isPerishable: false, typicalShelfLife: nil, keywords: ["asian", "thai", "curry"]),
        "sesame oil": GroceryItemData(name: "Sesame Oil", category: .pantry, unit: .liters, defaultAmount: 0.25, isPerishable: false, typicalShelfLife: nil, keywords: ["asian", "chinese", "cooking"]),
        
        // FRESH PRODUCE
        "milk": GroceryItemData(name: "Milk", category: .dairy, unit: .liters, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["dairy", "breakfast", "essential"]),
        "eggs": GroceryItemData(name: "Eggs", category: .dairy, unit: .pieces, defaultAmount: 12.0, isPerishable: true, typicalShelfLife: 21, keywords: ["breakfast", "protein", "baking"]),
        "bread": GroceryItemData(name: "Bread", category: .bakery, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 5, keywords: ["sandwich", "breakfast", "essential"]),
        "bananas": GroceryItemData(name: "Bananas", category: .produce, unit: .pieces, defaultAmount: 5.0, isPerishable: true, typicalShelfLife: 5, keywords: ["fruit", "breakfast", "snack"]),
        "apples": GroceryItemData(name: "Apples", category: .produce, unit: .pieces, defaultAmount: 6.0, isPerishable: true, typicalShelfLife: 14, keywords: ["fruit", "snack", "lunch"]),
        "cheese": GroceryItemData(name: "Cheese", category: .dairy, unit: .grams, defaultAmount: 200.0, isPerishable: true, typicalShelfLife: 14, keywords: ["dairy", "sandwich", "snack"]),
        "lettuce": GroceryItemData(name: "Lettuce", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["vegetable", "salad", "greens"]),
        "tomatoes": GroceryItemData(name: "Tomatoes", category: .produce, unit: .pieces, defaultAmount: 4.0, isPerishable: true, typicalShelfLife: 7, keywords: ["vegetable", "salad", "sandwich"]),
        "onions": GroceryItemData(name: "Onions", category: .produce, unit: .pieces, defaultAmount: 3.0, isPerishable: true, typicalShelfLife: 30, keywords: ["vegetable", "cooking", "base"]),
        "potatoes": GroceryItemData(name: "Potatoes", category: .produce, unit: .pieces, defaultAmount: 5.0, isPerishable: true, typicalShelfLife: 30, keywords: ["vegetable", "side dish", "staple"]),
        "garlic": GroceryItemData(name: "Garlic", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 21, keywords: ["vegetable", "cooking", "flavor"]),
        "avocados": GroceryItemData(name: "Avocados", category: .produce, unit: .pieces, defaultAmount: 3.0, isPerishable: true, typicalShelfLife: 5, keywords: ["fruit", "toast", "guacamole"]),
        "lemons": GroceryItemData(name: "Lemons", category: .produce, unit: .pieces, defaultAmount: 2.0, isPerishable: true, typicalShelfLife: 14, keywords: ["fruit", "drink", "flavor"]),
        "limes": GroceryItemData(name: "Limes", category: .produce, unit: .pieces, defaultAmount: 2.0, isPerishable: true, typicalShelfLife: 14, keywords: ["fruit", "drink", "mexican"]),
        "cilantro": GroceryItemData(name: "Cilantro", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 5, keywords: ["herb", "mexican", "garnish"]),
        "carrots": GroceryItemData(name: "Carrots", category: .produce, unit: .pieces, defaultAmount: 5.0, isPerishable: true, typicalShelfLife: 21, keywords: ["vegetable", "snack", "soup"]),
        "celery": GroceryItemData(name: "Celery", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 14, keywords: ["vegetable", "soup", "snack"]),
        "broccoli": GroceryItemData(name: "Broccoli", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["vegetable", "side dish", "healthy"]),
        "bell peppers": GroceryItemData(name: "Bell Peppers", category: .produce, unit: .pieces, defaultAmount: 3.0, isPerishable: true, typicalShelfLife: 10, keywords: ["vegetable", "salad", "stir fry"]),
        "cucumbers": GroceryItemData(name: "Cucumbers", category: .produce, unit: .pieces, defaultAmount: 2.0, isPerishable: true, typicalShelfLife: 7, keywords: ["vegetable", "salad", "refresh"]),
        "berries": GroceryItemData(name: "Berries", category: .produce, unit: .grams, defaultAmount: 250.0, isPerishable: true, typicalShelfLife: 5, keywords: ["fruit", "breakfast", "snack"]),
        "grapes": GroceryItemData(name: "Grapes", category: .produce, unit: .grams, defaultAmount: 500.0, isPerishable: true, typicalShelfLife: 7, keywords: ["fruit", "snack", "sweet"]),
        "spinach": GroceryItemData(name: "Spinach", category: .produce, unit: .grams, defaultAmount: 200.0, isPerishable: true, typicalShelfLife: 5, keywords: ["vegetable", "salad", "green"]),
        "zucchini": GroceryItemData(name: "Zucchini", category: .produce, unit: .pieces, defaultAmount: 2.0, isPerishable: true, typicalShelfLife: 7, keywords: ["vegetable", "side dish", "pasta"]),
        "mushrooms": GroceryItemData(name: "Mushrooms", category: .produce, unit: .grams, defaultAmount: 250.0, isPerishable: true, typicalShelfLife: 7, keywords: ["vegetable", "pizza", "pasta"]),
        
        // PROTEINS & MEAT
        "chicken breast": GroceryItemData(name: "Chicken Breast", category: .meat, unit: .grams, defaultAmount: 500.0, isPerishable: true, typicalShelfLife: 3, keywords: ["protein", "meat", "dinner"]),
        "ground beef": GroceryItemData(name: "Ground Beef", category: .meat, unit: .grams, defaultAmount: 500.0, isPerishable: true, typicalShelfLife: 3, keywords: ["protein", "meat", "burgers"]),
        "bacon": GroceryItemData(name: "Bacon", category: .meat, unit: .grams, defaultAmount: 250.0, isPerishable: true, typicalShelfLife: 7, keywords: ["meat", "breakfast", "sandwich"]),
        "sausages": GroceryItemData(name: "Sausages", category: .meat, unit: .pieces, defaultAmount: 6.0, isPerishable: true, typicalShelfLife: 5, keywords: ["protein", "meat", "grill"]),
        "salmon": GroceryItemData(name: "Salmon", category: .meat, unit: .grams, defaultAmount: 300.0, isPerishable: true, typicalShelfLife: 2, keywords: ["fish", "seafood", "dinner"]),
        "shrimp": GroceryItemData(name: "Shrimp", category: .meat, unit: .grams, defaultAmount: 300.0, isPerishable: true, typicalShelfLife: 2, keywords: ["seafood", "protein", "pasta"]),
        "tofu": GroceryItemData(name: "Tofu", category: .produce, unit: .grams, defaultAmount: 400.0, isPerishable: true, typicalShelfLife: 5, keywords: ["vegetarian", "protein", "stir fry"]),
        "deli meat": GroceryItemData(name: "Deli Meat", category: .meat, unit: .grams, defaultAmount: 200.0, isPerishable: true, typicalShelfLife: 5, keywords: ["sandwich", "lunch", "protein"]),
        
        // DAIRY & REFRIGERATED
        "butter": GroceryItemData(name: "Butter", category: .dairy, unit: .grams, defaultAmount: 250.0, isPerishable: true, typicalShelfLife: 30, keywords: ["dairy", "baking", "cooking"]),
        "yogurt": GroceryItemData(name: "Yogurt", category: .dairy, unit: .grams, defaultAmount: 500.0, isPerishable: true, typicalShelfLife: 14, keywords: ["dairy", "breakfast", "snack"]),
        "cream cheese": GroceryItemData(name: "Cream Cheese", category: .dairy, unit: .grams, defaultAmount: 250.0, isPerishable: true, typicalShelfLife: 14, keywords: ["dairy", "breakfast", "bagel"]),
        "sour cream": GroceryItemData(name: "Sour Cream", category: .dairy, unit: .grams, defaultAmount: 250.0, isPerishable: true, typicalShelfLife: 14, keywords: ["dairy", "mexican", "topping"]),
        "heavy cream": GroceryItemData(name: "Heavy Cream", category: .dairy, unit: .liters, defaultAmount: 0.5, isPerishable: true, typicalShelfLife: 7, keywords: ["dairy", "baking", "cooking"]),
        "almond milk": GroceryItemData(name: "Almond Milk", category: .dairy, unit: .liters, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["dairy", "vegan", "breakfast"]),
        "oat milk": GroceryItemData(name: "Oat Milk", category: .dairy, unit: .liters, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["dairy", "vegan", "breakfast"]),
        
        // PANTRY STAPLES
        "pasta": GroceryItemData(name: "Pasta", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["dinner", "italian", "carb"]),
        "rice": GroceryItemData(name: "Rice", category: .pantry, unit: .grams, defaultAmount: 1000.0, isPerishable: false, typicalShelfLife: nil, keywords: ["dinner", "side dish", "grain"]),
        "flour": GroceryItemData(name: "Flour", category: .pantry, unit: .grams, defaultAmount: 1000.0, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "essential", "pantry"]),
        "sugar": GroceryItemData(name: "Sugar", category: .pantry, unit: .grams, defaultAmount: 1000.0, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "sweetener", "essential"]),
        "olive oil": GroceryItemData(name: "Olive Oil", category: .pantry, unit: .liters, defaultAmount: 0.5, isPerishable: false, typicalShelfLife: nil, keywords: ["cooking", "oil", "essential"]),
        "salt": GroceryItemData(name: "Salt", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["seasoning", "essential", "cooking"]),
        "black pepper": GroceryItemData(name: "Black Pepper", category: .pantry, unit: .grams, defaultAmount: 100.0, isPerishable: false, typicalShelfLife: nil, keywords: ["seasoning", "spice", "essential"]),
        "chicken broth": GroceryItemData(name: "Chicken Broth", category: .pantry, unit: .liters, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["cooking", "soup", "flavor"]),
        "canned tomatoes": GroceryItemData(name: "Canned Tomatoes", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["canned", "sauce", "cooking"]),
        "pasta sauce": GroceryItemData(name: "Pasta Sauce", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["sauce", "italian", "dinner"]),
        "peanut butter": GroceryItemData(name: "Peanut Butter", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["sandwich", "breakfast", "spread"]),
        "jam": GroceryItemData(name: "Jam", category: .pantry, unit: .grams, defaultAmount: 300.0, isPerishable: false, typicalShelfLife: nil, keywords: ["sandwich", "breakfast", "spread"]),
        "honey": GroceryItemData(name: "Honey", category: .pantry, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["sweetener", "tea", "natural"]),
        "maple syrup": GroceryItemData(name: "Maple Syrup", category: .pantry, unit: .liters, defaultAmount: 0.25, isPerishable: false, typicalShelfLife: nil, keywords: ["breakfast", "sweetener", "pancakes"]),
        "canned beans": GroceryItemData(name: "Canned Beans", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["protein", "soup", "mexican"]),
        "canned tuna": GroceryItemData(name: "Canned Tuna", category: .pantry, unit: .grams, defaultAmount: 150.0, isPerishable: false, typicalShelfLife: nil, keywords: ["protein", "sandwich", "salad"]),
        "cereal": GroceryItemData(name: "Cereal", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["breakfast", "kids", "quick"]),
        "oats": GroceryItemData(name: "Oats", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["breakfast", "healthy", "porridge"]),
        "coffee": GroceryItemData(name: "Coffee", category: .pantry, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["beverage", "breakfast", "caffeine"]),
        "tea": GroceryItemData(name: "Tea", category: .pantry, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["beverage", "hot", "relaxing"]),
        "quinoa": GroceryItemData(name: "Quinoa", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["grain", "healthy", "protein"]),
        "brown rice": GroceryItemData(name: "Brown Rice", category: .pantry, unit: .grams, defaultAmount: 1000.0, isPerishable: false, typicalShelfLife: nil, keywords: ["grain", "healthy", "side dish"]),
        
        // BEVERAGES
        "orange juice": GroceryItemData(name: "Orange Juice", category: .other, unit: .liters, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["beverage", "breakfast", "fruit"]),
        "soda": GroceryItemData(name: "Soda", category: .other, unit: .liters, defaultAmount: 2.0, isPerishable: false, typicalShelfLife: nil, keywords: ["beverage", "carbonated", "sweet"]),
        "sparkling water": GroceryItemData(name: "Sparkling Water", category: .other, unit: .liters, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["beverage", "water", "carbonated"]),
        "bottled water": GroceryItemData(name: "Bottled Water", category: .other, unit: .liters, defaultAmount: 6.0, isPerishable: false, typicalShelfLife: nil, keywords: ["beverage", "essential", "hydration"]),
        "wine": GroceryItemData(name: "Wine", category: .other, unit: .pieces, defaultAmount: 1.0, isPerishable: false, typicalShelfLife: nil, keywords: ["beverage", "alcohol", "dinner"]),
        "beer": GroceryItemData(name: "Beer", category: .other, unit: .pieces, defaultAmount: 6.0, isPerishable: false, typicalShelfLife: nil, keywords: ["beverage", "alcohol", "party"]),
        "lemonade": GroceryItemData(name: "Lemonade", category: .other, unit: .liters, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["beverage", "summer", "refreshing"]),
        "iced tea": GroceryItemData(name: "Iced Tea", category: .other, unit: .liters, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["beverage", "summer", "cold"]),
        
        // BAKING SUPPLIES
        "baking powder": GroceryItemData(name: "Baking Powder", category: .pantry, unit: .grams, defaultAmount: 200.0, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "leavening", "essential"]),
        "baking soda": GroceryItemData(name: "Baking Soda", category: .pantry, unit: .grams, defaultAmount: 200.0, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "leavening", "cleaning"]),
        "vanilla extract": GroceryItemData(name: "Vanilla Extract", category: .pantry, unit: .liters, defaultAmount: 0.05, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "flavoring", "dessert"]),
        "cocoa powder": GroceryItemData(name: "Cocoa Powder", category: .pantry, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "chocolate", "dessert"]),
        "chocolate chips": GroceryItemData(name: "Chocolate Chips", category: .pantry, unit: .grams, defaultAmount: 350.0, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "dessert", "cookies"]),
        "brown sugar": GroceryItemData(name: "Brown Sugar", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "sweetener", "cookies"]),
        "powdered sugar": GroceryItemData(name: "Powdered Sugar", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "sweetener", "frosting"]),
        "yeast": GroceryItemData(name: "Yeast", category: .pantry, unit: .grams, defaultAmount: 50.0, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "bread", "leavening"]),
        
        // CONDIMENTS & SAUCES
        "ketchup": GroceryItemData(name: "Ketchup", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["condiment", "tomato", "burger"]),
        "mustard": GroceryItemData(name: "Mustard", category: .pantry, unit: .grams, defaultAmount: 250.0, isPerishable: false, typicalShelfLife: nil, keywords: ["condiment", "sandwich", "hotdog"]),
        "mayonnaise": GroceryItemData(name: "Mayonnaise", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["condiment", "sandwich", "dressing"]),
        "barbecue sauce": GroceryItemData(name: "Barbecue Sauce", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["condiment", "grill", "meat"]),
        "hot sauce": GroceryItemData(name: "Hot Sauce", category: .pantry, unit: .grams, defaultAmount: 150.0, isPerishable: false, typicalShelfLife: nil, keywords: ["condiment", "spicy", "flavor"]),
        "ranch dressing": GroceryItemData(name: "Ranch Dressing", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["condiment", "salad", "dipping"]),
        "italian dressing": GroceryItemData(name: "Italian Dressing", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["condiment", "salad", "marinade"]),
        "caesar dressing": GroceryItemData(name: "Caesar Dressing", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["condiment", "salad", "creamy"]),
        "worcestershire sauce": GroceryItemData(name: "Worcestershire Sauce", category: .pantry, unit: .grams, defaultAmount: 150.0, isPerishable: false, typicalShelfLife: nil, keywords: ["condiment", "umami", "marinade"]),
        
        // BREAKFAST ITEMS
        "granola": GroceryItemData(name: "Granola", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["breakfast", "cereal", "crunchy"]),
        "pancake mix": GroceryItemData(name: "Pancake Mix", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["breakfast", "baking", "quick"]),
        "waffle mix": GroceryItemData(name: "Waffle Mix", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["breakfast", "baking", "quick"]),
        "breakfast sausage": GroceryItemData(name: "Breakfast Sausage", category: .meat, unit: .grams, defaultAmount: 300.0, isPerishable: true, typicalShelfLife: 5, keywords: ["breakfast", "meat", "protein"]),
        "english muffins": GroceryItemData(name: "English Muffins", category: .bakery, unit: .pieces, defaultAmount: 6.0, isPerishable: true, typicalShelfLife: 7, keywords: ["breakfast", "bread", "toast"]),
        "bagels": GroceryItemData(name: "Bagels", category: .bakery, unit: .pieces, defaultAmount: 6.0, isPerishable: true, typicalShelfLife: 5, keywords: ["breakfast", "bread", "cream cheese"]),
        "croissants": GroceryItemData(name: "Croissants", category: .bakery, unit: .pieces, defaultAmount: 4.0, isPerishable: true, typicalShelfLife: 3, keywords: ["breakfast", "pastry", "french"]),
        
        // GLUTEN-FREE & SPECIALTY DIET
        "gluten-free bread": GroceryItemData(name: "Gluten-Free Bread", category: .bakery, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 5, keywords: ["bread", "gluten-free", "special diet"]),
        "gluten-free pasta": GroceryItemData(name: "Gluten-Free Pasta", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["pasta", "gluten-free", "dinner"]),
        "gluten-free flour": GroceryItemData(name: "Gluten-Free Flour", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "gluten-free", "special diet"]),
        "coconut flour": GroceryItemData(name: "Coconut Flour", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "gluten-free", "low-carb"]),
        "almond flour": GroceryItemData(name: "Almond Flour", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["baking", "gluten-free", "keto"]),
        "protein powder": GroceryItemData(name: "Protein Powder", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["supplement", "fitness", "smoothie"]),
        "chia seeds": GroceryItemData(name: "Chia Seeds", category: .pantry, unit: .grams, defaultAmount: 200.0, isPerishable: false, typicalShelfLife: nil, keywords: ["superfood", "breakfast", "pudding"]),
        "flax seeds": GroceryItemData(name: "Flax Seeds", category: .pantry, unit: .grams, defaultAmount: 200.0, isPerishable: false, typicalShelfLife: nil, keywords: ["superfood", "breakfast", "fiber"]),
        "nutritional yeast": GroceryItemData(name: "Nutritional Yeast", category: .pantry, unit: .grams, defaultAmount: 150.0, isPerishable: false, typicalShelfLife: nil, keywords: ["vegan", "cheese substitute", "umami"]),
        "tempeh": GroceryItemData(name: "Tempeh", category: .produce, unit: .grams, defaultAmount: 250.0, isPerishable: true, typicalShelfLife: 7, keywords: ["vegan", "protein", "fermented"]),
        "seitan": GroceryItemData(name: "Seitan", category: .produce, unit: .grams, defaultAmount: 250.0, isPerishable: true, typicalShelfLife: 5, keywords: ["vegan", "protein", "meat substitute"]),
        
        // CANNED GOODS
        "canned soup": GroceryItemData(name: "Canned Soup", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["soup", "quick meal", "pantry"]),
        "canned corn": GroceryItemData(name: "Canned Corn", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["vegetable", "side dish", "pantry"]),
        "canned peas": GroceryItemData(name: "Canned Peas", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["vegetable", "side dish", "pantry"]),
        "canned mushrooms": GroceryItemData(name: "Canned Mushrooms", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["vegetable", "pizza", "pantry"]),
        "canned pineapple": GroceryItemData(name: "Canned Pineapple", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["fruit", "dessert", "pantry"]),
        "canned peaches": GroceryItemData(name: "Canned Peaches", category: .pantry, unit: .grams, defaultAmount: 400.0, isPerishable: false, typicalShelfLife: nil, keywords: ["fruit", "dessert", "pantry"]),
        "canned olives": GroceryItemData(name: "Canned Olives", category: .pantry, unit: .grams, defaultAmount: 300.0, isPerishable: false, typicalShelfLife: nil, keywords: ["vegetable", "pizza", "pantry"]),
        "pickles": GroceryItemData(name: "Pickles", category: .pantry, unit: .grams, defaultAmount: 500.0, isPerishable: false, typicalShelfLife: nil, keywords: ["condiment", "sandwich", "burger"]),
        
        // FRUITS AND VEGETABLES
        "oranges": GroceryItemData(name: "Oranges", category: .produce, unit: .pieces, defaultAmount: 6.0, isPerishable: true, typicalShelfLife: 14, keywords: ["fruit", "citrus", "vitamin C"]),
        "pears": GroceryItemData(name: "Pears", category: .produce, unit: .pieces, defaultAmount: 4.0, isPerishable: true, typicalShelfLife: 7, keywords: ["fruit", "snack", "sweet"]),
        "peaches": GroceryItemData(name: "Peaches", category: .produce, unit: .pieces, defaultAmount: 4.0, isPerishable: true, typicalShelfLife: 5, keywords: ["fruit", "summer", "sweet"]),
        "plums": GroceryItemData(name: "Plums", category: .produce, unit: .pieces, defaultAmount: 6.0, isPerishable: true, typicalShelfLife: 5, keywords: ["fruit", "stone fruit", "sweet"]),
        "pineapple": GroceryItemData(name: "Pineapple", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 5, keywords: ["fruit", "tropical", "sweet"]),
        "mango": GroceryItemData(name: "Mango", category: .produce, unit: .pieces, defaultAmount: 2.0, isPerishable: true, typicalShelfLife: 5, keywords: ["fruit", "tropical", "sweet"]),
        "watermelon": GroceryItemData(name: "Watermelon", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["fruit", "summer", "refreshing"]),
        "kiwi": GroceryItemData(name: "Kiwi", category: .produce, unit: .pieces, defaultAmount: 4.0, isPerishable: true, typicalShelfLife: 7, keywords: ["fruit", "vitamin C", "tropical"]),
        "asparagus": GroceryItemData(name: "Asparagus", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 5, keywords: ["vegetable", "side dish", "roasting"]),
        "cauliflower": GroceryItemData(name: "Cauliflower", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["vegetable", "side dish", "rice substitute"]),
        "cabbage": GroceryItemData(name: "Cabbage", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 14, keywords: ["vegetable", "slaw", "cooking"]),
        "kale": GroceryItemData(name: "Kale", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["vegetable", "salad", "superfood"]),
        "beets": GroceryItemData(name: "Beets", category: .produce, unit: .pieces, defaultAmount: 4.0, isPerishable: true, typicalShelfLife: 14, keywords: ["vegetable", "salad", "roasting"]),
        "sweet potato": GroceryItemData(name: "Sweet Potato", category: .produce, unit: .pieces, defaultAmount: 3.0, isPerishable: true, typicalShelfLife: 21, keywords: ["vegetable", "side dish", "baking"]),
        "green beans": GroceryItemData(name: "Green Beans", category: .produce, unit: .grams, defaultAmount: 300.0, isPerishable: true, typicalShelfLife: 7, keywords: ["vegetable", "side dish", "steaming"]),
        "brussels sprouts": GroceryItemData(name: "Brussels Sprouts", category: .produce, unit: .grams, defaultAmount: 300.0, isPerishable: true, typicalShelfLife: 7, keywords: ["vegetable", "side dish", "roasting"]),
        "romaine lettuce": GroceryItemData(name: "Romaine Lettuce", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["vegetable", "salad", "caesar"]),
        "arugula": GroceryItemData(name: "Arugula", category: .produce, unit: .grams, defaultAmount: 150.0, isPerishable: true, typicalShelfLife: 5, keywords: ["vegetable", "salad", "peppery"]),
        
        // HERBS & SPICES
        "basil": GroceryItemData(name: "Basil", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 5, keywords: ["herb", "italian", "tomato"]),
        "parsley": GroceryItemData(name: "Parsley", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["herb", "garnish", "fresh"]),
        "rosemary": GroceryItemData(name: "Rosemary", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["herb", "roasting", "aromatic"]),
        "thyme": GroceryItemData(name: "Thyme", category: .produce, unit: .pieces, defaultAmount: 1.0, isPerishable: true, typicalShelfLife: 7, keywords: ["herb", "soup", "aromatic"]),
        "oregano": GroceryItemData(name: "Oregano", category: .pantry, unit: .grams, defaultAmount: 25.0, isPerishable: false, typicalShelfLife: nil, keywords: ["herb", "italian", "pizza"]),
        "cinnamon": GroceryItemData(name: "Cinnamon", category: .pantry, unit: .grams, defaultAmount: 50.0, isPerishable: false, typicalShelfLife: nil, keywords: ["spice", "baking", "sweet"]),
        "cumin": GroceryItemData(name: "Cumin", category: .pantry, unit: .grams, defaultAmount: 50.0, isPerishable: false, typicalShelfLife: nil, keywords: ["spice", "mexican", "indian"]),
        "paprika": GroceryItemData(name: "Paprika", category: .pantry, unit: .grams, defaultAmount: 50.0, isPerishable: false, typicalShelfLife: nil, keywords: ["spice", "color", "smoky"]),
        "garlic powder": GroceryItemData(name: "Garlic Powder", category: .pantry, unit: .grams, defaultAmount: 50.0, isPerishable: false, typicalShelfLife: nil, keywords: ["spice", "seasoning", "convenience"]),
        "onion powder": GroceryItemData(name: "Onion Powder", category: .pantry, unit: .grams, defaultAmount: 50.0, isPerishable: false, typicalShelfLife: nil, keywords: ["spice", "seasoning", "convenience"]),
        "chili powder": GroceryItemData(name: "Chili Powder", category: .pantry, unit: .grams, defaultAmount: 50.0, isPerishable: false, typicalShelfLife: nil, keywords: ["spice", "mexican", "heat"]),
        "red pepper flakes": GroceryItemData(name: "Red Pepper Flakes", category: .pantry, unit: .grams, defaultAmount: 30.0, isPerishable: false, typicalShelfLife: nil, keywords: ["spice", "pizza", "heat"]),
        "italian seasoning": GroceryItemData(name: "Italian Seasoning", category: .pantry, unit: .grams, defaultAmount: 30.0, isPerishable: false, typicalShelfLife: nil, keywords: ["spice", "blend", "pasta"]),
        "taco seasoning": GroceryItemData(name: "Taco Seasoning", category: .pantry, unit: .grams, defaultAmount: 30.0, isPerishable: false, typicalShelfLife: nil, keywords: ["spice", "blend", "mexican"])
    ]
    
    // Helper function to search for items matching a string
    static func findMatches(for searchTerm: String, limit: Int = 10) -> [String: GroceryItemData] {
        let lowercasedTerm = searchTerm.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Return empty if search term is too short
        if lowercasedTerm.count < 2 {
            return [:]
        }
        
        // Start with exact matches
        var exactMatches: [String: GroceryItemData] = [:]
        var startsWithMatches: [String: GroceryItemData] = [:]
        var containsMatches: [String: GroceryItemData] = [:]
        var keywordMatches: [String: GroceryItemData] = [:]
        
        for (key, item) in items {
            if key == lowercasedTerm {
                exactMatches[key] = item
            } else if key.starts(with: lowercasedTerm) {
                startsWithMatches[key] = item
            } else if key.contains(lowercasedTerm) {
                containsMatches[key] = item
            } else if item.keywords.contains(where: { $0.contains(lowercasedTerm) }) {
                keywordMatches[key] = item
            }
        }
        
        // Combine results in order of priority
        var results = exactMatches
        if results.count < limit {
            for (key, value) in startsWithMatches where results.count < limit {
                results[key] = value
            }
        }
        
        if results.count < limit {
            for (key, value) in containsMatches where results.count < limit {
                results[key] = value
            }
        }
        
        if results.count < limit {
            for (key, value) in keywordMatches where results.count < limit {
                results[key] = value
            }
        }
        
        return results
    }
} 