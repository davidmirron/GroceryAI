#!/bin/bash

# This script copies the recipes.json file to the app bundle's Resources directory
# Run this script after building the app to ensure the JSON data is available

# Get the current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source directory containing the recipes.json file
SOURCE_DIR="$SCRIPT_DIR/GroceryAI/Resources"

# Find the built app in the DerivedData directory
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*/Build/Products/Debug-iphonesimulator/*.app" -name "GroceryAI.app" -print -quit)

if [ -z "$APP_PATH" ]; then
    echo "Error: Could not find the built GroceryAI.app in DerivedData directory."
    echo "Please build the app first in Xcode."
    exit 1
fi

# Target directory in the app bundle
TARGET_DIR="$APP_PATH"

# Check if the source file exists
if [ ! -f "$SOURCE_DIR/recipes.json" ]; then
    echo "Error: recipes.json not found in $SOURCE_DIR"
    exit 1
fi

# Copy the file to the app bundle
echo "Copying recipes.json to $TARGET_DIR"
cp "$SOURCE_DIR/recipes.json" "$TARGET_DIR/"

# Check if the copy was successful
if [ $? -eq 0 ]; then
    echo "✅ Successfully copied recipes.json to the app bundle"
else
    echo "❌ Failed to copy recipes.json"
    exit 1
fi

echo "🚀 The app is now ready to load recipes from JSON"
exit 0 