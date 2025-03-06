# Enhanced Recipe Collection for GroceryAI

This implementation adds enhanced recipe collection capabilities to the GroceryAI app, introducing a structured JSON recipe database that significantly improves the app's recipe functionality.

## Features

- **Structured JSON Recipe Data**: Organized recipes with complete metadata including categories, difficulty, prep/cooking times, and nutritional information.
- **Rich Recipe Categorization**: Recipes are categorized by meal type, difficulty, and dietary preferences.
- **Enhanced Filtering**: Users can filter recipes by multiple criteria including categories and difficulty.
- **Non-invasive Integration**: Backwards compatible with existing app architecture.
- **Efficient Loading**: Recipes load from JSON on first launch then persist in UserDefaults.

## Implementation Details

### Data Structure

The implementation uses a structured JSON format with the following key attributes for each recipe:

- Basic information (name, id, source)
- Category and difficulty classification
- Detailed ingredients with quantities, units, and perishability information
- Preparation and cooking times (separate fields)
- Complete nutritional information
- Dietary tags for dietary preferences

### Files Added/Modified

1. **`Recipe+JSON.swift`**: Adds JSON loading capability to Recipe model with conversion utilities
2. **`recipes.json`**: Sample recipe database with structured recipe data
3. **`Recipe.swift`**: Extended with additional properties and enums for categorization
4. **`RecipesViewModel.swift`**: Updated filtering to support new recipe categories
5. **`RecipeListViewModel.swift`**: Enhanced DTO for JSON serialization
6. **`GroceryAIApp.swift`**: Updated to load recipe data on app startup
7. **`copy_recipes_to_bundle.sh`**: Helper script to ensure JSON is available in the app bundle

### Usage

1. Add recipes to the `recipes.json` file following the established format
2. Build and run the app - recipes will automatically load on first launch
3. Use the filtering options to browse recipes by category, difficulty, or dietary preferences

## JSON Recipe Schema

```json
{
  "id": "unique-uuid-string",
  "name": "Recipe Name",
  "category": "Category Name",
  "ingredients": [
    {
      "name": "Ingredient Name",
      "amount": 1.0,
      "unit": "g",
      "category": "Pantry",
      "isPerishable": false,
      "shelfLife": 365
    }
  ],
  "instructions": ["Step 1", "Step 2"],
  "prepTime": 10,
  "cookTime": 20,
  "servings": 4,
  "nutritionInfo": {
    "calories": 350,
    "protein": 10,
    "carbs": 45,
    "fat": 12
  },
  "dietaryTags": ["vegetarian"],
  "difficulty": "Easy",
  "imageFileName": "image_name",
  "source": "Source Information"
}
```

## Future Enhancements

- Remote recipe database with API integration
- User ratings and comments on recipes
- Recipe version history 
- Recipe sharing between users
- AI-powered recipe recommendations based on user preferences 