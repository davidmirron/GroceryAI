# Fridge Snapshot Feature Demo Implementation

## Overview

This document outlines how to implement a working demo of the "Fridge Snapshot" feature for our existing app. This feature enables users to take photos of their fridge/pantry and receive AI-powered recipe suggestions through a conversational interface.

Following Steve Jobs' approach, this demo implements a **chat-based interface** that embraces ChatGPT's natural text output format.

## Demo Requirements

The demo should showcase:
- A working camera interface
- Simulated ingredient detection
- Recipe suggestions based on detected ingredients
- Detailed recipe presentation
- Interactive chat elements (quick replies, etc.)

No actual AI integration is needed for this demo - we'll use hardcoded data and responses.

## User Flow for Demo

### Step 1: Camera Access
- User clicks camera button in the chat interface
- Simple camera view opens with frame guide
- Clear instruction shows: "Position your open fridge or pantry in the frame"

### Step 2: Photo Processing
- After capturing "photo", it appears in the chat thread
- Typing indicator displays (simulating AI processing)
- Brief delay (2-3 seconds) before showing the response

### Step 3: AI Analysis & Recipe Suggestions
- AI responds: "I can see several ingredients in your fridge!"
- Lists predefined ingredients
- Presents 2 recipe cards with hardcoded options
- Shows quick reply buttons for further interaction

### Step 4: Recipe Details
- When recipe is selected, displays recipe details in chat format
- Shows ingredients and instructions with simple formatting
- Offers quick reply buttons for related actions

## Hardcoded Data for Demo

### Detected Ingredients
```javascript
const detectedIngredients = [
  'Chicken breast',
  'Bell peppers',
  'Onions',
  'Tomatoes',
  'Cheese',
  'Pasta'
];
```

### Recipe Data
```javascript
const recipes = [
  {
    id: 1,
    title: 'Chicken Pasta Primavera',
    cookTime: '25 min',
    servings: 4,
    match: '95%',
    ingredients: [
      '2 chicken breasts, cut into bite-sized pieces',
      '250g pasta (any shape works)',
      '2 bell peppers, sliced',
      '1 medium onion, diced',
      '2 tomatoes, diced',
      '100g cheese, grated',
      '2 tbsp olive oil',
      '2 cloves garlic, minced',
      'Salt and pepper to taste'
    ],
    instructions: [
      'Boil pasta according to package instructions until al dente. Drain and set aside.',
      'Season chicken with salt and pepper. Heat olive oil in a large pan and cook chicken for 5-6 minutes until no longer pink.',
      'Add onions and garlic, cook for 2 minutes until fragrant.',
      'Add bell peppers and cook for 3-4 minutes until slightly softened.',
      'Add tomatoes and cook for another 2 minutes.',
      'Add cooked pasta and toss to combine. Sprinkle with cheese, give a final toss, and serve hot!'
    ]
  },
  {
    id: 2,
    title: 'Quick Chicken Fajitas',
    cookTime: '20 min',
    servings: 3,
    match: '88%',
    ingredients: [
      '2 chicken breasts, sliced into strips',
      '2 bell peppers, sliced',
      '1 onion, sliced',
      '2 tbsp olive oil',
      '1 lime, juiced',
      '2 tsp fajita seasoning',
      'Salt and pepper to taste',
      '6 small tortillas',
      'Optional: sour cream, grated cheese'
    ],
    instructions: [
      'Heat oil in a large skillet over medium-high heat.',
      'Season chicken with half the fajita seasoning, salt, and pepper.',
      'Cook chicken for 5-6 minutes until golden and cooked through, then remove from pan.',
      'Add bell peppers and onions to the same pan, cook for 4-5 minutes until softened.',
      'Return chicken to the pan, add remaining seasoning and lime juice.',
      'Stir for 1-2 minutes until everything is well combined and heated through.',
      'Serve with warm tortillas and optional toppings.'
    ]
  }
];
```

## UI Components Implementation

### 1. Camera Button
```html
<div class="chat-button" id="camera-button">📷</div>
```
```javascript
cameraButton.addEventListener('click', openCamera);
```

### 2. Camera View
```html
<div class="camera-view" id="camera-view">
    <div class="camera-header">
        <div class="camera-title">Take a photo of your fridge</div>
        <div class="camera-close" id="camera-close">✕</div>
    </div>
    
    <div class="camera-frame">
        <div class="camera-guide"></div>
        <div class="camera-help">Position your open fridge or pantry in the frame</div>
    </div>
    
    <div class="camera-controls">
        <div class="shutter-button" id="shutter-button"></div>
    </div>
</div>
```

### 3. Recipe Card
```html
<div class="recipe-card">
    <div class="recipe-image">Recipe Photo</div>
    <div class="recipe-details">
        <div class="recipe-title">${recipe.title}</div>
        <div class="recipe-meta">
            <span>⏱️ ${recipe.cookTime}</span>
            <span>👨‍👩‍👧‍👦 ${recipe.servings} servings</span>
            <span>✓ ${recipe.match} match</span>
        </div>
        <div class="recipe-action">View Recipe</div>
    </div>
</div>
```

### 4. Typing Indicator
```html
<div class="typing-indicator">
    <div class="typing-dot"></div>
    <div class="typing-dot"></div>
    <div class="typing-dot"></div>
</div>
```

### 5. Quick Reply Buttons
```html
<div class="quick-replies">
    <div class="quick-reply">Show more recipes</div>
    <div class="quick-reply">Missing any ingredients?</div>
    <div class="quick-reply">Take another photo</div>
</div>
```

## CSS Styling Guidelines

Use these color variables for consistent styling:
```css
:root {
    --primary: #10B981;
    --primary-dark: #059669;
    --primary-light: #D1FAE5;
    --background: #121212;
    --card-background: #1C1C1E;
    --text: #F3F4F6;
    --text-secondary: #9CA3AF;
    --border: rgba(255, 255, 255, 0.1);
    --user-bubble: #10B981;
    --ai-bubble: #1E3A31;
}
```

## Key JavaScript Functions for Demo

### 1. Camera Handling
```javascript
function openCamera() {
    cameraView.classList.add('active');
}

function closeCamera() {
    cameraView.classList.remove('active');
}

function handlePhotoTaken() {
    closeCamera();
    const userMsg = addMessage("Here's a photo of my fridge", 'user', createCameraPreview());
    const typingIndicator = addTypingIndicator();
    
    // Simulate processing time
    setTimeout(() => {
        typingIndicator.remove();
        showIngredientDetection();
    }, 3000);
}
```

### 2. Showing Detected Ingredients
```javascript
function showIngredientDetection() {
    // Create ingredient list
    let ingredientsList = detectedIngredients.map(ing => `• ${ing}`).join('<br>\n');
    
    const assistantMsg = addMessage(
        `I can see several ingredients in your fridge! I spotted:
        <br><br>
        ${ingredientsList}
        <br><br>
        Here are two delicious recipes you can make with these ingredients:`,
        'ai'
    );
    
    // Add recipe cards and quick replies
    addRecipeCards(assistantMsg);
    addQuickReplies(assistantMsg, [
        { text: 'Show more recipes', action: handleShowMoreRecipes },
        { text: 'Missing any ingredients?', action: handleMissingIngredients },
        { text: 'Take another photo', action: openCamera }
    ]);
}
```

### 3. Recipe Details
```javascript
function showRecipeDetails(recipe) {
    // User message requesting the recipe
    addMessage(`Show me the ${recipe.title} recipe`, 'user');
    
    // Format ingredients and instructions
    const ingredientsList = recipe.ingredients.map(ing => `• ${ing}`).join('<br>\n');
    const instructionsList = recipe.instructions.map((step, i) => `${i+1}. ${step}`).join('<br><br>\n');
    
    // Assistant response with recipe details
    const assistantMsg = addMessage(
        `<strong>${recipe.title}</strong>
        <br><br>
        <strong>Ingredients:</strong>
        <br>
        ${ingredientsList}
        <br><br>
        <strong>Instructions:</strong>
        <br>
        ${instructionsList}`,
        'ai'
    );
    
    // Add quick replies
    addQuickReplies(assistantMsg, [
        { text: 'Add ingredients to list', action: handleAddToList },
        { text: 'See other recipe', action: () => showOtherRecipe(recipe) },
        { text: 'Modify recipe', action: handleModifyRecipe }
    ]);
}
```

## Demo Testing Checklist

Ensure these interactions work correctly:
- [ ] Camera button opens camera view
- [ ] Shutter button captures "photo" and returns to chat
- [ ] Typing indicator appears after photo is taken
- [ ] Ingredient list appears after typing indicator
- [ ] Recipe cards display correctly
- [ ] Clicking "View Recipe" shows recipe details
- [ ] Quick reply buttons advance the conversation
- [ ] UI is responsive on different screen sizes

## HTML Implementation

For a complete implementation, copy the code from our shared HTML template and replace the placeholder content with the actual implementation as described above. The template includes all necessary HTML structure, CSS styles, and JavaScript interaction handlers.


## First example


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GroceryAI - AI Chef Assistant</title>
    <style>
        :root {
            --primary: #10B981;
            --primary-dark: #059669;
            --primary-light: #D1FAE5;
            --background: #121212;
            --card-background: #1C1C1E;
            --text: #F3F4F6;
            --text-secondary: #9CA3AF;
            --border: rgba(255, 255, 255, 0.1);
            --user-bubble: #10B981;
            --ai-bubble: #1E3A31;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        }
        
        body {
            background-color: var(--background);
            color: var(--text);
            min-height: 100vh;
        }
        
        /* Scroll container for demo purposes */
        .scroll-container {
            height: 100vh;
            overflow-y: auto;
            scroll-snap-type: y mandatory;
        }
        
        .screen-container {
            scroll-snap-align: start;
            height: 100vh;
        }
        
        .screen-title {
            position: absolute;
            top: 10px;
            left: 10px;
            background-color: rgba(0,0,0,0.7);
            color: white;
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 12px;
            z-index: 1000;
        }
        
        .container {
            display: flex;
            flex-direction: column;
            height: 100vh;
            max-width: 430px;
            margin: 0 auto;
            position: relative;
        }
        
        /* Status bar */
        .status-bar {
            display: flex;
            justify-content: space-between;
            padding: 10px 20px;
        }
        
        .time {
            font-weight: bold;
        }
        
        .status-icons {
            display: flex;
            gap: 5px;
        }
        
        /* Header */
        .header {
            background: linear-gradient(to bottom, var(--primary-dark), var(--primary));
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header-title {
            color: white;
            font-size: 22px;
            font-weight: bold;
            text-align: center;
            flex: 1;
        }
        
        .nav-button {
            color: white;
            width: 60px;
            font-weight: 500;
        }
        
        /* Chat container */
        .chat-container {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        
        .chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        
        .message {
            display: flex;
            flex-direction: column;
            max-width: 80%;
        }
        
        .message.user {
            align-self: flex-end;
        }
        
        .message.ai {
            align-self: flex-start;
        }
        
        .message-bubble {
            padding: 14px;
            border-radius: 18px;
            font-size: 16px;
            line-height: 1.4;
            position: relative;
        }
        
        .user .message-bubble {
            background-color: var(--user-bubble);
            color: white;
            border-bottom-right-radius: 4px;
        }
        
        .ai .message-bubble {
            background-color: var(--ai-bubble);
            color: white;
            border-bottom-left-radius: 4px;
        }
        
        .message-time {
            font-size: 12px;
            color: var(--text-secondary);
            margin-top: 5px;
            align-self: flex-end;
        }
        
        /* Camera preview */
        .camera-preview {
            width: 250px;
            height: 180px;
            border-radius: 12px;
            overflow: hidden;
            margin-top: 10px;
            background-color: #333;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .camera-preview-placeholder {
            color: #666;
            font-style: italic;
        }
        
        /* Typing indicator */
        .typing-indicator {
            display: flex;
            align-items: center;
            gap: 4px;
            padding: 12px 16px;
            background-color: var(--ai-bubble);
            border-radius: 18px;
            border-bottom-left-radius: 4px;
            width: fit-content;
            margin-top: 15px;
        }
        
        .typing-dot {
            width: 8px;
            height: 8px;
            background-color: white;
            border-radius: 50%;
            opacity: 0.6;
            animation: typingAnimation 1.4s infinite;
        }
        
        .typing-dot:nth-child(2) {
            animation-delay: 0.2s;
        }
        
        .typing-dot:nth-child(3) {
            animation-delay: 0.4s;
        }
        
        @keyframes typingAnimation {
            0% { opacity: 0.6; transform: scale(0.8); }
            50% { opacity: 1; transform: scale(1.2); }
            100% { opacity: 0.6; transform: scale(0.8); }
        }
        
        /* Quick reply buttons */
        .quick-replies {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 10px;
        }
        
        .quick-reply {
            background-color: var(--primary-light);
            color: var(--primary-dark);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
        }
        
        /* Message with recipe */
        .recipe-card {
            background-color: var(--card-background);
            border-radius: 12px;
            overflow: hidden;
            margin-top: 15px;
            width: 100%;
            max-width: 300px;
        }
        
        .recipe-image {
            height: 140px;
            background-color: #333;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #666;
            font-style: italic;
        }
        
        .recipe-details {
            padding: 15px;
        }
        
        .recipe-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 8px;
        }
        
        .recipe-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            font-size: 13px;
            color: var(--text-secondary);
            margin-bottom: 12px;
        }
        
        .recipe-action {
            background-color: var(--primary);
            color: white;
            padding: 8px 0;
            border-radius: 8px;
            text-align: center;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
        }
        
        /* Input area */
        .chat-input-container {
            padding: 15px;
            background-color: var(--card-background);
            border-top: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .chat-input {
            flex: 1;
            background-color: rgba(255, 255, 255, 0.08);
            border-radius: 24px;
            padding: 12px 20px;
            font-size: 16px;
            border: none;
            outline: none;
            color: var(--text);
        }
        
        .chat-actions {
            display: flex;
            gap: 15px;
        }
        
        .chat-button {
            width: 44px;
            height: 44px;
            border-radius: 22px;
            background-color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
            cursor: pointer;
        }
        
        /* Tab Bar */
        .tab-bar {
            display: flex;
            background-color: var(--card-background);
            border-top: 1px solid var(--border);
            padding: 10px 0;
        }
        
        .tab {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 5px;
            color: var(--text-secondary);
        }
        
        .tab.active {
            color: var(--primary);
        }
        
        .tab-icon {
            font-size: 22px;
            margin-bottom: 5px;
        }
        
        .tab-label {
            font-size: 12px;
        }
        
        /* Camera view */
        .camera-view {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #000;
            z-index: 100;
            display: flex;
            flex-direction: column;
        }
        
        .camera-header {
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .camera-title {
            color: white;
            font-size: 18px;
            font-weight: bold;
        }
        
        .camera-close {
            width: 36px;
            height: 36px;
            border-radius: 18px;
            background-color: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
        }
        
        .camera-frame {
            flex: 1;
            position: relative;
        }
        
        .camera-guide {
            position: absolute;
            top: 50px;
            left: 50px;
            right: 50px;
            bottom: 50px;
            border: 3px dashed var(--primary);
            border-radius: 20px;
        }
        
        .camera-help {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background-color: rgba(0, 0, 0, 0.7);
            padding: 12px 20px;
            border-radius: 10px;
            color: white;
            text-align: center;
            max-width: 250px;
        }
        
        .camera-controls {
            padding: 30px;
            display: flex;
            justify-content: center;
        }
        
        .shutter-button {
            width: 70px;
            height: 70px;
            border-radius: 35px;
            background-color: white;
            border: 5px solid rgba(255, 255, 255, 0.3);
        }
    </style>
</head>
<body>
    <div class="scroll-container">
        <!-- SCREEN 1: Starting the Chat -->
        <div class="screen-container">
            <div class="screen-title">SCREEN 1: Chat Interface Initial</div>
            <div class="container">
                <!-- Status Bar -->
                <div class="status-bar">
                    <div class="time">16:09</div>
                    <div class="status-icons">
                        <span>●●●●</span>
                        <span>📶</span>
                        <span>🔋</span>
                    </div>
                </div>
                
                <!-- Header -->
                <div class="header">
                    <div class="nav-button"></div>
                    <div class="header-title">AI Chef Assistant</div>
                    <div class="nav-button"></div>
                </div>
                
                <!-- Chat Container -->
                <div class="chat-container">
                    <div class="chat-messages">
                        <div class="message ai">
                            <div class="message-bubble">
                                Hi there! I'm your AI Chef Assistant. I can help you find recipes based on what's in your fridge. Just tap the camera button to take a picture!
                            </div>
                            <div class="message-time">4:05 PM</div>
                        </div>
                        
                        <div class="message user">
                            <div class="message-bubble">
                                What can you help me with?
                            </div>
                            <div class="message-time">4:06 PM</div>
                        </div>
                        
                        <div class="message ai">
                            <div class="message-bubble">
                                I can help you:
                                <br><br>
                                • Find recipes using ingredients you already have
                                <br>
                                • Suggest meals based on a photo of your fridge
                                <br>
                                • Provide step-by-step cooking instructions
                                <br>
                                • Answer cooking questions
                                <br><br>
                                Would you like to snap a photo of your fridge to see what you can make?
                            </div>
                            <div class="message-time">4:06 PM</div>
                            
                            <div class="quick-replies">
                                <div class="quick-reply">📷 Take a photo</div>
                                <div class="quick-reply">🔍 Search recipes</div>
                                <div class="quick-reply">❓ Ask cooking question</div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Input Area -->
                    <div class="chat-input-container">
                        <input type="text" class="chat-input" placeholder="Type a message...">
                        <div class="chat-actions">
                            <div class="chat-button">📷</div>
                            <div class="chat-button">➤</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- SCREEN 2: Camera View -->
        <div class="screen-container">
            <div class="screen-title">SCREEN 2: Camera View</div>
            <div class="container">
                <!-- Camera View -->
                <div class="camera-view">
                    <div class="camera-header">
                        <div class="camera-title">Take a photo of your fridge</div>
                        <div class="camera-close">✕</div>
                    </div>
                    
                    <div class="camera-frame">
                        <div class="camera-guide"></div>
                        <div class="camera-help">Position your open fridge or pantry in the frame</div>
                    </div>
                    
                    <div class="camera-controls">
                        <div class="shutter-button"></div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- SCREEN 3: Photo Sent & Processing -->
        <div class="screen-container">
            <div class="screen-title">SCREEN 3: Photo Sent & Processing</div>
            <div class="container">
                <!-- Status Bar -->
                <div class="status-bar">
                    <div class="time">16:09</div>
                    <div class="status-icons">
                        <span>●●●●</span>
                        <span>📶</span>
                        <span>🔋</span>
                    </div>
                </div>
                
                <!-- Header -->
                <div class="header">
                    <div class="nav-button"></div>
                    <div class="header-title">AI Chef Assistant</div>
                    <div class="nav-button"></div>
                </div>
                
                <!-- Chat Container -->
                <div class="chat-container">
                    <div class="chat-messages">
                        <div class="message ai">
                            <div class="message-bubble">
                                Hi there! I'm your AI Chef Assistant. I can help you find recipes based on what's in your fridge. Just tap the camera button to take a picture!
                            </div>
                            <div class="message-time">4:05 PM</div>
                        </div>
                        
                        <div class="message user">
                            <div class="message-bubble">
                                What can you help me with?
                            </div>
                            <div class="message-time">4:06 PM</div>
                        </div>
                        
                        <div class="message ai">
                            <div class="message-bubble">
                                I can help you:
                                <br><br>
                                • Find recipes using ingredients you already have
                                <br>
                                • Suggest meals based on a photo of your fridge
                                <br>
                                • Provide step-by-step cooking instructions
                                <br>
                                • Answer cooking questions
                                <br><br>
                                Would you like to snap a photo of your fridge to see what you can make?
                            </div>
                            <div class="message-time">4:06 PM</div>
                        </div>
                        
                        <div class="message user">
                            <div class="message-bubble">
                                Here's a photo of my fridge
                            </div>
                            <div class="camera-preview">
                                <div class="camera-preview-placeholder">Fridge Photo</div>
                            </div>
                            <div class="message-time">4:08 PM</div>
                        </div>
                        
                        <div class="typing-indicator">
                            <div class="typing-dot"></div>
                            <div class="typing-dot"></div>
                            <div class="typing-dot"></div>
                        </div>
                    </div>
                    
                    <!-- Input Area -->
                    <div class="chat-input-container">
                        <input type="text" class="chat-input" placeholder="Type a message...">
                        <div class="chat-actions">
                            <div class="chat-button">📷</div>
                            <div class="chat-button">➤</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- SCREEN 4: AI Response with Recipes -->
        <div class="screen-container">
            <div class="screen-title">SCREEN 4: AI Response with Recipes</div>
            <div class="container">
                <!-- Status Bar -->
                <div class="status-bar">
                    <div class="time">16:09</div>
                    <div class="status-icons">
                        <span>●●●●</span>
                        <span>📶</span>
                        <span>🔋</span>
                    </div>
                </div>
                
                <!-- Header -->
                <div class="header">
                    <div class="nav-button"></div>
                    <div class="header-title">AI Chef Assistant</div>
                    <div class="nav-button"></div>
                </div>
                
                <!-- Chat Container -->
                <div class="chat-container">
                    <div class="chat-messages">
                        <div class="message ai">
                            <div class="message-bubble">
                                Hi there! I'm your AI Chef Assistant. I can help you find recipes based on what's in your fridge. Just tap the camera button to take a picture!
                            </div>
                            <div class="message-time">4:05 PM</div>
                        </div>
                        
                        <div class="message user">
                            <div class="message-bubble">
                                What can you help me with?
                            </div>
                            <div class="message-time">4:06 PM</div>
                        </div>
                        
                        <div class="message ai">
                            <div class="message-bubble">
                                I can help you:
                                <br><br>
                                • Find recipes using ingredients you already have
                                <br>
                                • Suggest meals based on a photo of your fridge
                                <br>
                                • Provide step-by-step cooking instructions
                                <br>
                                • Answer cooking questions
                                <br><br>
                                Would you like to snap a photo of your fridge to see what you can make?
                            </div>
                            <div class="message-time">4:06 PM</div>
                        </div>
                        
                        <div class="message user">
                            <div class="message-bubble">
                                Here's a photo of my fridge
                            </div>
                            <div class="camera-preview">
                                <div class="camera-preview-placeholder">Fridge Photo</div>
                            </div>
                            <div class="message-time">4:08 PM</div>
                        </div>
                        
                        <div class="message ai">
                            <div class="message-bubble">
                                I can see several ingredients in your fridge! I spotted:
                                <br><br>
                                • Chicken breast
                                <br>
                                • Bell peppers
                                <br>
                                • Onions
                                <br>
                                • Tomatoes
                                <br>
                                • Cheese
                                <br>
                                • Pasta
                                <br><br>
                                Here are two delicious recipes you can make with these ingredients:
                            </div>
                            <div class="recipe-card">
                                <div class="recipe-image">Recipe Photo</div>
                                <div class="recipe-details">
                                    <div class="recipe-title">Chicken Pasta Primavera</div>
                                    <div class="recipe-meta">
                                        <span>⏱️ 25 min</span>
                                        <span>👨‍👩‍👧‍👦 4 servings</span>
                                        <span>✓ 95% match</span>
                                    </div>
                                    <div class="recipe-action">View Recipe</div>
                                </div>
                            </div>
                            <div style="height: 15px"></div>
                            <div class="recipe-card">
                                <div class="recipe-image">Recipe Photo</div>
                                <div class="recipe-details">
                                    <div class="recipe-title">Quick Chicken Fajitas</div>
                                    <div class="recipe-meta">
                                        <span>⏱️ 20 min</span>
                                        <span>👨‍👩‍👧‍👦 3 servings</span>
                                        <span>✓ 88% match</span>
                                    </div>
                                    <div class="recipe-action">View Recipe</div>
                                </div>
                            </div>
                            <div class="message-time">4:09 PM</div>
                            
                            <div class="quick-replies">
                                <div class="quick-reply">Show more recipes</div>
                                <div class="quick-reply">Missing any ingredients?</div>
                                <div class="quick-reply">Take another photo</div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Input Area -->
                    <div class="chat-input-container">
                        <input type="text" class="chat-input" placeholder="Type a message...">
                        <div class="chat-actions">
                            <div class="chat-button">📷</div>
                            <div class="chat-button">➤</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- SCREEN 5: Recipe Details in Chat -->
        <div class="screen-container">
            <div class="screen-title">SCREEN 5: Recipe Details in Chat</div>
            <div class="container">
                <!-- Status Bar -->
                <div class="status-bar">
                    <div class="time">16:09</div>
                    <div class="status-icons">
                        <span>●●●●</span>
                        <span>📶</span>
                        <span>🔋</span>
                    </div>
                </div>
                
                <!-- Header -->
                <div class="header">
                    <div class="nav-button"></div>
                    <div class="header-title">AI Chef Assistant</div>
                    <div class="nav-button"></div>
                </div>
                
                <!-- Chat Container -->
                <div class="chat-container">
                    <div class="chat-messages">
                        <div class="message user">
                            <div class="message-bubble">
                                Show me the Chicken Pasta Primavera recipe
                            </div>
                            <div class="message-time">4:10 PM</div>
                        </div>
                        
                        <div class="message ai">
                            <div class="message-bubble">
                                <strong>Chicken Pasta Primavera</strong>
                                <br><br>
                                <strong>Ingredients:</strong>
                                <br>
                                • 2 chicken breasts, cut into bite-sized pieces
                                <br>
                                • 250g pasta (any shape works)
                                <br>
                                • 2 bell peppers, sliced
                                <br>
                                • 1 medium onion, diced
                                <br>
                                • 2 tomatoes, diced
                                <br>
                                • 100g cheese, grated
                                <br>
                                • 2 tbsp olive oil
                                <br>
                                • 2 cloves garlic, minced
                                <br>
                                • Salt and pepper to taste
                                <br><br>
                                <strong>Instructions:</strong>
                                <br>
                                1. Boil pasta according to package instructions until al dente. Drain and set aside.
                                <br><br>
                                2. Season chicken with salt and pepper. Heat olive oil in a large pan and cook chicken for 5-6 minutes until no longer pink.
                                <br><br>
                                3. Add onions and garlic, cook for 2 minutes until fragrant.
                                <br><br>
                                4. Add bell peppers and cook for 3-4 minutes until slightly softened.
                                <br><br>
                                5. Add tomatoes and cook for another 2 minutes.
                                <br><br>
                                6. Add cooked pasta and toss to combine. Sprinkle with cheese, give a final toss, and serve hot!
                            </div>
                            <div class="message-time">4:10 PM</div>
                            
                            <div class="quick-replies">
                                <div class="quick-reply">Add ingredients to list</div>
                                <div class="quick-reply">See other recipe</div>
                                <div class="quick-reply">Modify recipe</div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Input Area -->
                    <div class="chat-input-container">
                        <input type="text" class="chat-input" placeholder="Type a message...">
                        <div class="chat-actions">
                            <div class="chat-button">📷</div>
                            <div class="chat-button">➤</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>



 ## Second Example

 <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GroceryAI - AI Chef Assistant</title>
    <style>
        :root {
            --primary: #10B981;
            --primary-dark: #059669;
            --primary-light: #D1FAE5;
            --background: #121212;
            --card-background: #1C1C1E;
            --text: #F3F4F6;
            --text-secondary: #9CA3AF;
            --border: rgba(255, 255, 255, 0.1);
            --user-bubble: #10B981;
            --ai-bubble: #1E3A31;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        }
        
        body {
            background-color: var(--background);
            color: var(--text);
            min-height: 100vh;
        }
        
        .container {
            display: flex;
            flex-direction: column;
            height: 100vh;
            max-width: 430px;
            margin: 0 auto;
            position: relative;
        }
        
        /* Status bar */
        .status-bar {
            display: flex;
            justify-content: space-between;
            padding: 10px 20px;
        }
        
        .time {
            font-weight: bold;
        }
        
        .status-icons {
            display: flex;
            gap: 5px;
        }
        
        /* Header */
        .header {
            background: linear-gradient(to bottom, var(--primary-dark), var(--primary));
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header-title {
            color: white;
            font-size: 22px;
            font-weight: bold;
            text-align: center;
            flex: 1;
        }
        
        .nav-button {
            color: white;
            width: 60px;
            font-weight: 500;
        }
        
        /* Chat container */
        .chat-container {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        
        .chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        
        .message {
            display: flex;
            flex-direction: column;
            max-width: 80%;
        }
        
        .message.user {
            align-self: flex-end;
        }
        
        .message.ai {
            align-self: flex-start;
        }
        
        .message-bubble {
            padding: 14px;
            border-radius: 18px;
            font-size: 16px;
            line-height: 1.4;
            position: relative;
        }
        
        .user .message-bubble {
            background-color: var(--user-bubble);
            color: white;
            border-bottom-right-radius: 4px;
        }
        
        .ai .message-bubble {
            background-color: var(--ai-bubble);
            color: white;
            border-bottom-left-radius: 4px;
        }
        
        .message-time {
            font-size: 12px;
            color: var(--text-secondary);
            margin-top: 5px;
            align-self: flex-end;
        }
        
        /* Camera preview */
        .camera-preview {
            width: 250px;
            height: 180px;
            border-radius: 12px;
            overflow: hidden;
            margin-top: 10px;
            background-color: #333;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .camera-preview-placeholder {
            color: #666;
            font-style: italic;
        }
        
        /* Typing indicator */
        .typing-indicator {
            display: flex;
            align-items: center;
            gap: 4px;
            padding: 12px 16px;
            background-color: var(--ai-bubble);
            border-radius: 18px;
            border-bottom-left-radius: 4px;
            width: fit-content;
            margin-top: 15px;
        }
        
        .typing-dot {
            width: 8px;
            height: 8px;
            background-color: white;
            border-radius: 50%;
            opacity: 0.6;
            animation: typingAnimation 1.4s infinite;
        }
        
        .typing-dot:nth-child(2) {
            animation-delay: 0.2s;
        }
        
        .typing-dot:nth-child(3) {
            animation-delay: 0.4s;
        }
        
        @keyframes typingAnimation {
            0% { opacity: 0.6; transform: scale(0.8); }
            50% { opacity: 1; transform: scale(1.2); }
            100% { opacity: 0.6; transform: scale(0.8); }
        }
        
        /* Quick reply buttons */
        .quick-replies {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 10px;
        }
        
        .quick-reply {
            background-color: var(--primary-light);
            color: var(--primary-dark);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
        }
        
        /* Message with recipe */
        .recipe-card {
            background-color: var(--card-background);
            border-radius: 12px;
            overflow: hidden;
            margin-top: 15px;
            width: 100%;
            max-width: 300px;
        }
        
        .recipe-image {
            height: 140px;
            background-color: #333;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #666;
            font-style: italic;
        }
        
        .recipe-details {
            padding: 15px;
        }
        
        .recipe-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 8px;
        }
        
        .recipe-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            font-size: 13px;
            color: var(--text-secondary);
            margin-bottom: 12px;
        }
        
        .recipe-action {
            background-color: var(--primary);
            color: white;
            padding: 8px 0;
            border-radius: 8px;
            text-align: center;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
        }
        
        /* Input area */
        .chat-input-container {
            padding: 15px;
            background-color: var(--card-background);
            border-top: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .chat-input {
            flex: 1;
            background-color: rgba(255, 255, 255, 0.08);
            border-radius: 24px;
            padding: 12px 20px;
            font-size: 16px;
            border: none;
            outline: none;
            color: var(--text);
        }
        
        .chat-actions {
            display: flex;
            gap: 15px;
        }
        
        .chat-button {
            width: 44px;
            height: 44px;
            border-radius: 22px;
            background-color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
            cursor: pointer;
        }
        
        /* Camera view */
        .camera-view {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #000;
            z-index: 100;
            display: flex;
            flex-direction: column;
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.3s ease;
        }
        
        .camera-view.active {
            opacity: 1;
            pointer-events: all;
        }
        
        .camera-header {
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .camera-title {
            color: white;
            font-size: 18px;
            font-weight: bold;
        }
        
        .camera-close {
            width: 36px;
            height: 36px;
            border-radius: 18px;
            background-color: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
            cursor: pointer;
        }
        
        .camera-frame {
            flex: 1;
            position: relative;
        }
        
        .camera-guide {
            position: absolute;
            top: 50px;
            left: 50px;
            right: 50px;
            bottom: 50px;
            border: 3px dashed var(--primary);
            border-radius: 20px;
        }
        
        .camera-help {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background-color: rgba(0, 0, 0, 0.7);
            padding: 12px 20px;
            border-radius: 10px;
            color: white;
            text-align: center;
            max-width: 250px;
        }
        
        .camera-controls {
            padding: 30px;
            display: flex;
            justify-content: center;
        }
        
        .shutter-button {
            width: 70px;
            height: 70px;
            border-radius: 35px;
            background-color: white;
            border: 5px solid rgba(255, 255, 255, 0.3);
            cursor: pointer;
        }
        
        /* Hidden screens */
        .screen {
            display: none;
        }
        
        .screen.active {
            display: block;
        }
        
        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .fade-in {
            animation: fadeIn 0.3s ease-out forwards;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Status Bar -->
        <div class="status-bar">
            <div class="time" id="current-time">16:09</div>
            <div class="status-icons">
                <span>●●●●</span>
                <span>📶</span>
                <span>🔋</span>
            </div>
        </div>
        
        <!-- Header -->
        <div class="header">
            <div class="nav-button"></div>
            <div class="header-title">AI Chef Assistant</div>
            <div class="nav-button"></div>
        </div>
        
        <!-- Chat Container -->
        <div class="chat-container">
            <div class="chat-messages" id="chat-messages">
                <!-- Messages will be added here dynamically -->
            </div>
            
            <!-- Input Area -->
            <div class="chat-input-container">
                <input type="text" class="chat-input" id="chat-input" placeholder="Type a message...">
                <div class="chat-actions">
                    <div class="chat-button" id="camera-button">📷</div>
                    <div class="chat-button" id="send-button">➤</div>
                </div>
            </div>
        </div>
        
        <!-- Camera View -->
        <div class="camera-view" id="camera-view">
            <div class="camera-header">
                <div class="camera-title">Take a photo of your fridge</div>
                <div class="camera-close" id="camera-close">✕</div>
            </div>
            
            <div class="camera-frame">
                <div class="camera-guide"></div>
                <div class="camera-help">Position your open fridge or pantry in the frame</div>
            </div>
            
            <div class="camera-controls">
                <div class="shutter-button" id="shutter-button"></div>
            </div>
        </div>
    </div>

    <script>
        // Current state tracking
        let currentState = 'initial';
        const states = {
            initial: 0,
            userQuery: 1,
            photoSent: 2,
            recipeSuggestions: 3,
            recipeDetails: 4
        };
        
        // Hardcoded data
        const detectedIngredients = [
            'Chicken breast',
            'Bell peppers',
            'Onions',
            'Tomatoes',
            'Cheese',
            'Pasta'
        ];
        
        const recipes = [
            {
                id: 1,
                title: 'Chicken Pasta Primavera',
                cookTime: '25 min',
                servings: 4,
                match: '95%',
                ingredients: [
                    '2 chicken breasts, cut into bite-sized pieces',
                    '250g pasta (any shape works)',
                    '2 bell peppers, sliced',
                    '1 medium onion, diced',
                    '2 tomatoes, diced',
                    '100g cheese, grated',
                    '2 tbsp olive oil',
                    '2 cloves garlic, minced',
                    'Salt and pepper to taste'
                ],
                instructions: [
                    'Boil pasta according to package instructions until al dente. Drain and set aside.',
                    'Season chicken with salt and pepper. Heat olive oil in a large pan and cook chicken for 5-6 minutes until no longer pink.',
                    'Add onions and garlic, cook for 2 minutes until fragrant.',
                    'Add bell peppers and cook for 3-4 minutes until slightly softened.',
                    'Add tomatoes and cook for another 2 minutes.',
                    'Add cooked pasta and toss to combine. Sprinkle with cheese, give a final toss, and serve hot!'
                ]
            },
            {
                id: 2,
                title: 'Quick Chicken Fajitas',
                cookTime: '20 min',
                servings: 3,
                match: '88%',
                ingredients: [
                    '2 chicken breasts, sliced into strips',
                    '2 bell peppers, sliced',
                    '1 onion, sliced',
                    '2 tbsp olive oil',
                    '1 lime, juiced',
                    '2 tsp fajita seasoning',
                    'Salt and pepper to taste',
                    '6 small tortillas',
                    'Optional: sour cream, grated cheese'
                ],
                instructions: [
                    'Heat oil in a large skillet over medium-high heat.',
                    'Season chicken with half the fajita seasoning, salt, and pepper.',
                    'Cook chicken for 5-6 minutes until golden and cooked through, then remove from pan.',
                    'Add bell peppers and onions to the same pan, cook for 4-5 minutes until softened.',
                    'Return chicken to the pan, add remaining seasoning and lime juice.',
                    'Stir for 1-2 minutes until everything is well combined and heated through.',
                    'Serve with warm tortillas and optional toppings.'
                ]
            }
        ];
        
        // DOM elements
        const chatMessages = document.getElementById('chat-messages');
        const chatInput = document.getElementById('chat-input');
        const sendButton = document.getElementById('send-button');
        const cameraButton = document.getElementById('camera-button');
        const cameraView = document.getElementById('camera-view');
        const cameraClose = document.getElementById('camera-close');
        const shutterButton = document.getElementById('shutter-button');
        const currentTimeEl = document.getElementById('current-time');
        
        // Update time
        function updateTime() {
            const now = new Date();
            const hours = now.getHours();
            const minutes = now.getMinutes().toString().padStart(2, '0');
            currentTimeEl.textContent = `${hours}:${minutes}`;
        }
        
        // Initialize time and update every minute
        updateTime();
        setInterval(updateTime, 60000);
        
        // Helper function to get current time string for messages
        function getCurrentTimeString() {
            const now = new Date();
            const hours = now.getHours();
            const minutes = now.getMinutes().toString().padStart(2, '0');
            const ampm = hours >= 12 ? 'PM' : 'AM';
            const formattedHours = hours % 12 || 12;
            return `${formattedHours}:${minutes} ${ampm}`;
        }
        
        // Add a message to the chat
        function addMessage(content, sender, extraContent = null) {
            const messageEl = document.createElement('div');
            messageEl.className = `message ${sender}`;
            
            const bubbleEl = document.createElement('div');
            bubbleEl.className = 'message-bubble';
            bubbleEl.innerHTML = content;
            messageEl.appendChild(bubbleEl);
            
            if (extraContent) {
                messageEl.appendChild(extraContent);
            }
            
            const timeEl = document.createElement('div');
            timeEl.className = 'message-time';
            timeEl.textContent = getCurrentTimeString();
            messageEl.appendChild(timeEl);
            
            chatMessages.appendChild(messageEl);
            chatMessages.scrollTop = chatMessages.scrollHeight;
            
            return messageEl;
        }
        
        // Add quick reply buttons
        function addQuickReplies(messageEl, replies) {
            const repliesEl = document.createElement('div');
            repliesEl.className = 'quick-replies';
            
            replies.forEach(reply => {
                const replyEl = document.createElement('div');
                replyEl.className = 'quick-reply';
                replyEl.textContent = reply.text;
                replyEl.addEventListener('click', () => reply.action());
                repliesEl.appendChild(replyEl);
            });
            
            messageEl.appendChild(repliesEl);
        }
        
        // Add typing indicator
        function addTypingIndicator() {
            const indicatorEl = document.createElement('div');
            indicatorEl.className = 'typing-indicator';
            
            for (let i = 0; i < 3; i++) {
                const dotEl = document.createElement('div');
                dotEl.className = 'typing-dot';
                indicatorEl.appendChild(dotEl);
            }
            
            chatMessages.appendChild(indicatorEl);
            chatMessages.scrollTop = chatMessages.scrollHeight;
            
            return indicatorEl;
        }
        
        // Create a recipe card element
        function createRecipeCard(recipe) {
            const cardEl = document.createElement('div');
            cardEl.className = 'recipe-card';
            
            cardEl.innerHTML = `
                <div class="recipe-image">Recipe Photo</div>
                <div class="recipe-details">
                    <div class="recipe-title">${recipe.title}</div>
                    <div class="recipe-meta">
                        <span>⏱️ ${recipe.cookTime}</span>
                        <span>👨‍👩‍👧‍👦 ${recipe.servings} servings</span>
                        <span>✓ ${recipe.match} match</span>
                    </div>
                    <div class="recipe-action">View Recipe</div>
                </div>
            `;
            
            // Add click handler to view recipe
            cardEl.querySelector('.recipe-action').addEventListener('click', () => {
                showRecipeDetails(recipe);
            });
            
            return cardEl;
        }
        
        // Create a camera preview element
        function createCameraPreview() {
            const previewEl = document.createElement('div');
            previewEl.className = 'camera-preview';
            
            const placeholderEl = document.createElement('div');
            placeholderEl.className = 'camera-preview-placeholder';
            placeholderEl.textContent = 'Fridge Photo';
            
            previewEl.appendChild(placeholderEl);
            return previewEl;
        }
        
        // Initialize the demo with the welcome message
        function initializeDemo() {
            // Welcome message
            const welcomeMsg = addMessage(
                "Hi there! I'm your AI Chef Assistant. I can help you find recipes based on what's in your fridge. Just tap the camera button to take a picture!",
                'ai'
            );
            
            currentState = 'initial';
        }
        
        // Handle user question about what the assistant can do
        function handleWhatCanYouDo() {
            const userMsg = addMessage('What can you help me with?', 'user');
            
            setTimeout(() => {
                const assistantMsg = addMessage(
                    `I can help you:
                    <br><br>
                    • Find recipes using ingredients you already have
                    <br>
                    • Suggest meals based on a photo of your fridge
                    <br>
                    • Provide step-by-step cooking instructions
                    <br>
                    • Answer cooking questions
                    <br><br>
                    Would you like to snap a photo of your fridge to see what you can make?`,
                    'ai'
                );
                
                addQuickReplies(assistantMsg, [
                    { 
                        text: '📷 Take a photo', 
                        action: openCamera 
                    },
                    { 
                        text: '🔍 Search recipes', 
                        action: () => addMessage("Sure, what ingredients would you like to search for?", 'ai')
                    },
                    { 
                        text: '❓ Ask cooking question', 
                        action: () => addMessage("Of course! What cooking question do you have?", 'ai')
                    }
                ]);
                
                currentState = 'userQuery';
            }, 1000);
        }
        
        // Open the camera view
        function openCamera() {
            cameraView.classList.add('active');
        }
        
        // Close the camera view
        function closeCamera() {
            cameraView.classList.remove('active');
        }
        
        // Handle when the user takes a photo
        function handlePhotoTaken() {
            closeCamera();
            
            const userMsg = addMessage("Here's a photo of my fridge", 'user', createCameraPreview());
            
            const typingIndicator = addTypingIndicator();
            
            // Simulate processing time
            setTimeout(() => {
                // Remove typing indicator
                typingIndicator.remove();
                
                // Create ingredient list
                let ingredientsList = detectedIngredients.map(ing => `• ${ing}`).join('<br>\n');
                
                const assistantMsg = addMessage(
                    `I can see several ingredients in your fridge! I spotted:
                    <br><br>
                    ${ingredientsList}
                    <br><br>
                    Here are two delicious recipes you can make with these ingredients:`,
                    'ai'
                );
                
                // Add first recipe card
                const recipe1Card = createRecipeCard(recipes[0]);
                assistantMsg.appendChild(recipe1Card);
                
                // Add spacing
                const spacer = document.createElement('div');
                spacer.style.height = '15px';
                assistantMsg.appendChild(spacer);
                
                // Add second recipe card
                const recipe2Card = createRecipeCard(recipes[1]);
                assistantMsg.appendChild(recipe2Card);
                
                // Add quick replies
                addQuickReplies(assistantMsg, [
                    { 
                        text: 'Show more recipes', 
                        action: () => addMessage("I don't have more recipes that match your ingredients right now. Would you like to try a different photo?", 'ai')
                    },
                    { 
                        text: 'Missing any ingredients?', 
                        action: () => addMessage("Based on what I see, you have all the essential ingredients for these recipes! You might want to check if you have basic spices and cooking oil.", 'ai')
                    },
                    { 
                        text: 'Take another photo', 
                        action: openCamera
                    }
                ]);
                
                currentState = 'recipeSuggestions';
                
                // Scroll to show the full message
                chatMessages.scrollTop = chatMessages.scrollHeight;
            }, 3000);
        }
        
        // Show recipe details
        function showRecipeDetails(recipe) {
            // User message requesting the recipe
            const userMsg = addMessage(`Show me the ${recipe.title} recipe`, 'user');
            
            // Format ingredients
            const ingredientsList = recipe.ingredients.map(ing => `• ${ing}`).join('<br>\n');
            
            // Format instructions
            const instructionsList = recipe.instructions.map((step, i) => `${i+1}. ${step}`).join('<br><br>\n');
            
            // Assistant response with recipe details
            const assistantMsg = addMessage(
                `<strong>${recipe.title}</strong>
                <br><br>
                <strong>Ingredients:</strong>
                <br>
                ${ingredientsList}
                <br><br>
                <strong>Instructions:</strong>
                <br>
                ${instructionsList}`,
                'ai'
            );
            
            // Add quick replies
            addQuickReplies(assistantMsg, [
                { 
                    text: 'Add ingredients to list', 
                    action: () => addMessage("I've added these ingredients to your shopping list!", 'ai')
                },
                { 
                    text: 'See other recipe', 
                    action: () => {
                        const otherRecipe = recipe.id === 1 ? recipes[1] : recipes[0];
                        showRecipeDetails(otherRecipe);
                    }
                },
                { 
                    text: 'Modify recipe', 
                    action: () => addMessage("How would you like to modify this recipe? I can help adjust ingredients or cooking methods.", 'ai')
                }
            ]);
            
            currentState = 'recipeDetails';
            
            // Scroll to show the full message
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }
        
        // Event listeners
        cameraButton.addEventListener('click', openCamera);
        cameraClose.addEventListener('click', closeCamera);
        shutterButton.addEventListener('click', handlePhotoTaken);
        
        sendButton.addEventListener('click', () => {
            const message = chatInput.value.trim();
            if (message) {
                addMessage(message, 'user');
                chatInput.value = '';
                
                // Demo flow control based on state
                if (currentState === 'initial') {
                    handleWhatCanYouDo();
                } else if (currentState === 'userQuery') {
                    openCamera();
                } else if (currentState === 'recipeSuggestions') {
                    showRecipeDetails(recipes[0]);
                } else {
                    // Generic response
                    setTimeout(() => {
                        addMessage("Is there anything else you'd like to know about these recipes?", 'ai');
                    }, 1000);
                }
            }
        });
        
        chatInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                sendButton.click();
            }
        });
        
        // Start the demo
        initializeDemo();
        
        // For demo purposes, automatically proceed after a delay
        setTimeout(() => {
            if (currentState === 'initial') {
                handleWhatCanYouDo();
            }
        }, 2000);
    </script>
</body>
</html>