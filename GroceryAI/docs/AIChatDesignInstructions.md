Check this HTML CODE to get an idea of the design, ui and ux:

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

