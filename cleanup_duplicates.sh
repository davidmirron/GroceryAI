#!/bin/bash

# Script to identify and clean up duplicate files in the GroceryAI project
# Created by Claude - 2025-03-03

# Set the working directory to the project root
cd "$(dirname "$0")"
echo "Working directory: $(pwd)"

# Create a backup directory
BACKUP_DIR="./duplicates_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "Created backup directory: $BACKUP_DIR"

# Function to check if files are similar
are_files_similar() {
    # Simple check for now - just compare the first few lines
    diff -q <(head -n 10 "$1") <(head -n 10 "$2") >/dev/null
    return $?
}

# List of potential duplicate files to check
echo "Checking for duplicate files..."

# Recipe Model
if [ -f "./Recipe.swift" ] && [ -f "./GroceryAI/Models/Recipe.swift" ]; then
    echo "Found potential duplicate: Recipe.swift"
    cp "./Recipe.swift" "$BACKUP_DIR/Recipe.swift.bak"
    if are_files_similar "./Recipe.swift" "./GroceryAI/Models/Recipe.swift"; then
        echo "  - Files are similar, removing the duplicate at root level"
        rm "./Recipe.swift"
    else
        echo "  - Files are different, keeping both but you should review them"
    fi
fi

# RecipesViewModel
if [ -f "./RecipesViewModel.swift" ] && [ -f "./GroceryAI/ViewModels/RecipesViewModel.swift" ]; then
    echo "Found potential duplicate: RecipesViewModel.swift"
    cp "./RecipesViewModel.swift" "$BACKUP_DIR/RecipesViewModel.swift.bak"
    if are_files_similar "./RecipesViewModel.swift" "./GroceryAI/ViewModels/RecipesViewModel.swift"; then
        echo "  - Files are similar, removing the duplicate at root level"
        rm "./RecipesViewModel.swift"
    else
        echo "  - Files are different, keeping both but you should review them"
    fi
fi

# RecipeList
if [ -f "./RecipeList.swift" ] && [ -f "./GroceryAI/Views/RecipeList.swift" ]; then
    echo "Found potential duplicate: RecipeList.swift"
    cp "./RecipeList.swift" "$BACKUP_DIR/RecipeList.swift.bak"
    if are_files_similar "./RecipeList.swift" "./GroceryAI/Views/RecipeList.swift"; then
        echo "  - Files are similar, removing the duplicate at root level"
        rm "./RecipeList.swift"
    else
        echo "  - Files are different, keeping both but you should review them"
    fi
fi

# RecipeDetailView
if [ -f "./RecipeDetailView.swift" ] && [ -f "./GroceryAI/Views/RecipeDetailView.swift" ]; then
    echo "Found potential duplicate: RecipeDetailView.swift"
    cp "./RecipeDetailView.swift" "$BACKUP_DIR/RecipeDetailView.swift.bak"
    if are_files_similar "./RecipeDetailView.swift" "./GroceryAI/Views/RecipeDetailView.swift"; then
        echo "  - Files are similar, removing the duplicate at root level"
        rm "./RecipeDetailView.swift"
    else
        echo "  - Files are different, keeping both but you should review them"
    fi
fi

# Other potential duplicates like Ingredient.swift and IngredientsListView.swift
other_files=("Ingredient.swift" "IngredientsListView.swift" "Ingredients.swift" "Color+Theme.swift")
for file in "${other_files[@]}"; do
    model_path="./GroceryAI/Models/$file"
    view_path="./GroceryAI/Views/$file"
    
    if [[ "$file" == *"+"* ]]; then
        # For utility files like extensions
        check_path="./GroceryAI/Utilities/$file"
    elif [[ "$file" == *"View"* ]]; then
        # View files
        check_path="$view_path"
    else
        # Assume model files
        check_path="$model_path"
    fi
    
    if [ -f "./$file" ] && [ -f "$check_path" ]; then
        echo "Found potential duplicate: $file"
        cp "./$file" "$BACKUP_DIR/$file.bak"
        if are_files_similar "./$file" "$check_path"; then
            echo "  - Files are similar, removing the duplicate at root level"
            rm "./$file"
        else
            echo "  - Files are different, keeping both but you should review them"
        fi
    fi
done

# Check for the 'delete' file which seems unnecessary
if [ -f "./delete" ]; then
    echo "Found seemingly unnecessary file: delete"
    cp "./delete" "$BACKUP_DIR/delete.bak"
    echo "  - Removing the file"
    rm "./delete"
fi

echo "Cleanup complete. All removed files were backed up to: $BACKUP_DIR"
echo "Please rebuild your Xcode project to ensure everything works correctly." 