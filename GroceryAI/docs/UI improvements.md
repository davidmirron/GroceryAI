<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GroceryAI UX Improvements</title>
    <style>
        :root {
            --primary: #10B981;
            --primary-dark: #059669;
            --primary-light: #D1FAE5;
            --background: #F9FAFB;
            --text: #1F2937;
            --text-secondary: #64748B;
            --border: #E5E7EB;
            --card-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'Helvetica Neue', Arial, sans-serif;
        }
        
        body {
            background-color: var(--background);
            color: var(--text);
            line-height: 1.6;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .title {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 10px;
            color: var(--primary-dark);
        }
        
        .subtitle {
            font-size: 18px;
            color: var(--text-secondary);
            max-width: 700px;
            margin: 0 auto;
        }
        
        .section {
            background: white;
            border-radius: 12px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: var(--card-shadow);
        }
        
        .section-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 20px;
            color: var(--primary-dark);
            display: flex;
            align-items: center;
        }
        
        .section-title svg {
            margin-right: 10px;
        }
        
        .improvement-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }
        
        .improvement-card {
            background-color: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            border: 1px solid var(--border);
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        
        .card-header {
            padding: 15px;
            background-color: var(--primary-light);
            border-bottom: 1px solid var(--border);
        }
        
        .card-title {
            font-size: 18px;
            font-weight: 600;
            color: var(--primary-dark);
        }
        
        .card-body {
            padding: 15px;
            flex-grow: 1;
        }
        
        .card-description {
            color: var(--text);
            margin-bottom: 15px;
        }
        
        .reference {
            color: var(--text-secondary);
            font-size: 14px;
            font-style: italic;
        }
        
        .compare-container {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-top: 20px;
        }
        
        .compare-item {
            flex: 1;
            min-width: 300px;
        }
        
        .compare-label {
            font-weight: 600;
            margin-bottom: 10px;
            color: var(--text);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .phone-mockup {
            border: 10px solid #1F2937;
            border-radius: 36px;
            overflow: hidden;
            width: 100%;
            max-width: 300px;
            height: 580px;
            background: white;
            margin: 0 auto;
            position: relative;
        }
        
        .phone-screen {
            height: 100%;
            width: 100%;
            background-color: var(--background);
            overflow: hidden;
            position: relative;
        }
        
        .status-bar {
            height: 44px;
            background-color: var(--primary);
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 15px;
            color: white;
            font-size: 14px;
            font-weight: 600;
        }
        
        .header-bar {
            height: 50px;
            background-color: var(--primary);
            display: flex;
            justify-content: center;
            align-items: center;
            color: white;
            font-size: 18px;
            font-weight: 600;
        }
        
        .nav-bar {
            height: 60px;
            background-color: white;
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            display: flex;
            justify-content: space-around;
            align-items: center;
            border-top: 1px solid var(--border);
        }
        
        .nav-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            font-size: 12px;
            color: var(--text-secondary);
        }
        
        .nav-item.active {
            color: var(--primary);
        }
        
        .nav-icon {
            font-size: 22px;
            margin-bottom: 4px;
        }
        
        .content {
            padding: 15px;
            height: calc(100% - 154px);
            overflow-y: auto;
        }
        
        .tab-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 15px;
        }
        
        .list-suggestions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 15px;
        }
        
        .suggestion-chip {
            background-color: var(--primary-light);
            border-radius: 20px;
            padding: 8px 15px;
            font-size: 14px;
            color: var(--primary-dark);
        }
        
        .category-header {
            font-size: 15px;
            font-weight: 600;
            color: var(--primary-dark);
            margin: 15px 0 10px 0;
            padding: 6px 12px;
            background-color: var(--primary-light);
            border-radius: 8px;
            display: inline-block;
        }
        
        .list-item {
            display: flex;
            align-items: center;
            padding: 12px;
            background-color: white;
            border-radius: 10px;
            margin-bottom: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        
        .item-checkbox {
            width: 22px;
            height: 22px;
            border-radius: 6px;
            border: 2px solid var(--primary);
            margin-right: 12px;
        }
        
        .item-checkbox.checked {
            background-color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        
        .item-name {
            flex-grow: 1;
        }
        
        .item-quantity {
            color: var(--text-secondary);
            font-size: 14px;
        }
        
        .add-button {
            position: absolute;
            bottom: 70px;
            right: 15px;
            width: 56px;
            height: 56px;
            border-radius: 28px;
            background-color: var(--primary);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .recipe-card {
            background-color: white;
            border-radius: 12px;
            overflow: hidden;
            margin-bottom: 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        
        .recipe-image {
            height: 120px;
            background-color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
        }
        
        .recipe-details {
            padding: 12px;
        }
        
        .recipe-title {
            font-weight: 600;
            margin-bottom: 5px;
        }
        
        .recipe-meta {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: var(--text-secondary);
            margin-bottom: 5px;
        }
        
        .missing-ingredient {
            font-size: 14px;
            color: #EF4444;
            margin-bottom: 5px;
        }
        
        .add-ingredient {
            font-size: 14px;
            color: var(--primary);
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .example-image {
            width: 100%;
            border-radius: 8px;
            box-shadow: var(--card-shadow);
            margin-bottom: 15px;
        }
        
        .guidelines {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid var(--border);
        }
        
        .guidelines-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 10px;
            color: var(--primary-dark);
        }
        
        .guidelines-list {
            list-style: none;
            margin-left: 0;
        }
        
        .guidelines-list li {
            padding-left: 20px;
            position: relative;
            margin-bottom: 8px;
        }
        
        .guidelines-list li::before {
            content: "•";
            color: var(--primary);
            position: absolute;
            left: 0;
            top: 0;
        }
        
        .animation-demo {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-top: 20px;
            justify-content: center;
        }
        
        .animation-item {
            width: 240px;
            text-align: center;
        }
        
        .animation-title {
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .animation-box {
            width: 100%;
            height: 150px;
            border-radius: 10px;
            background-color: white;
            box-shadow: var(--card-shadow);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }
        
        .swipe-indicator {
            position: absolute;
            width: 30px;
            height: 30px;
            background-color: var(--primary-light);
            border-radius: 50%;
            opacity: 0.7;
            animation: swipe 2s infinite;
        }
        
        @keyframes swipe {
            0% { transform: translateX(-100px); opacity: 0; }
            20% { opacity: 0.7; }
            80% { opacity: 0.7; }
            100% { transform: translateX(100px); opacity: 0; }
        }
        
        .fade-item {
            display: flex;
            align-items: center;
            background-color: white;
            padding: 10px;
            border-radius: 8px;
            border: 1px solid var(--border);
            animation: fade 3s infinite;
        }
        
        @keyframes fade {
            0% { opacity: 1; text-decoration: none; }
            50% { opacity: 0.5; text-decoration: line-through; }
            100% { opacity: 1; text-decoration: none; }
        }
        
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }
        
        .pulse-button {
            background-color: var(--primary);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            animation: pulse 2s infinite;
        }
        
        .typography-example {
            margin-top: 20px;
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: var(--card-shadow);
        }
        
        .typography-row {
            display: flex;
            margin-bottom: 15px;
            align-items: center;
        }
        
        .typography-label {
            width: 120px;
            font-weight: 600;
            color: var(--text-secondary);
        }
        
        .typography-sample {
            flex-grow: 1;
        }
        
        .typography-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--text);
        }
        
        .typography-heading {
            font-size: 20px;
            font-weight: 600;
            color: var(--text);
        }
        
        .typography-subheading {
            font-size: 17px;
            font-weight: 600;
            color: var(--text);
        }
        
        .typography-body {
            font-size: 16px;
            font-weight: 400;
            color: var(--text);
        }
        
        .typography-caption {
            font-size: 14px;
            font-weight: 400;
            color: var(--text-secondary);
        }
        
        .spacing-example {
            margin-top: 20px;
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: var(--card-shadow);
        }
        
        .spacing-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }
        
        .spacing-box {
            background-color: var(--primary-light);
            border-radius: 8px;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        
        .spacing-label {
            background-color: var(--primary);
            color: white;
            text-align: center;
            padding: 8px;
            font-size: 14px;
        }
        
        .spacing-content {
            padding: 16px;
            text-align: center;
            font-size: 14px;
        }
        
        .footer {
            text-align: center;
            margin-top: 60px;
            padding-top: 20px;
            border-top: 1px solid var(--border);
            color: var(--text-secondary);
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1 class="title">GroceryAI UX Improvements</h1>
            <p class="subtitle">Enhancing the user experience according to Apple's design philosophy: simplicity, clarity, and efficiency.</p>
        </header>
        
        <!-- Navigation & Structure -->
        <section class="section">
            <h2 class="section-title">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
                1. Navigation & Structure
            </h2>
            
            <div class="improvement-grid">
                <div class="improvement-card">
                    <div class="card-header">
                        <h3 class="card-title">Quantity Adjustment</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Add inline quantity controls to quickly adjust amounts without opening a detailed view.</p>
                        <p class="reference">Reference: Apple Human Interface Guidelines - Controls</p>
                        
                        <div class="compare-container">
                            <div class="compare-item">
                                <div class="compare-label">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                                    Current
                                </div>
                                <div style="background-color: white; border-radius: 8px; padding: 12px; display: flex; align-items: center;">
                                    <div style="width: 24px; height: 24px; border: 2px solid #10B981; border-radius: 6px; margin-right: 12px;"></div>
                                    <div style="flex-grow: 1;">Milk</div>
                                    <div style="color: #64748B;">1.0 liters</div>
                                </div>
                            </div>
                            <div class="compare-item">
                                <div class="compare-label">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="8" y1="12" x2="16" y2="12"></line><line x1="12" y1="16" x2="12" y2="8"></line></svg>
                                    Improved
                                </div>
                                <div style="background-color: white; border-radius: 8px; padding: 12px; display: flex; align-items: center;">
                                    <div style="width: 24px; height: 24px; border: 2px solid #10B981; border-radius: 6px; margin-right: 12px;"></div>
                                    <div style="flex-grow: 1;">Milk</div>
                                    <div style="display: flex; align-items: center; background-color: #F8FAFC; border-radius: 6px; overflow: hidden;">
                                        <div style="width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; color: #10B981; cursor: pointer;">−</div>
                                        <div style="padding: 0 8px; color: #1F2937;">1.0 L</div>
                                        <div style="width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; color: #10B981; cursor: pointer;">+</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="improvement-card">
                    <div class="card-header">
                        <h3 class="card-title">Item Organization</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Implement drag-and-drop reordering to let users organize items according to their shopping path through the store.</p>
                        <p class="reference">Reference: Apple Human Interface Guidelines - Drag and Drop</p>
                        
                        <div style="background-color: white; border-radius: 8px; padding: 15px; margin-top: 15px;">
                            <div style="margin-bottom: 10px; text-align: center; color: #64748B;">
                                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"></path></svg>
                                Drag to reorder items
                            </div>
                            
                            <div style="display: flex; align-items: center; background-color: #f8fafc; border-radius: 8px; padding: 12px; margin-bottom: 8px; border: 2px dashed #10B981;">
                                <div style="color: #64748B; margin-right: 10px;">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><polyline points="19 12 12 19 5 12"></polyline></svg>
                                </div>
                                <div style="width: 24px; height: 24px; border: 2px solid #10B981; border-radius: 6px; margin-right: 12px;"></div>
                                <div style="flex-grow: 1;">Milk</div>
                                <div style="color: #64748B;">1.0 liters</div>
                            </div>
                            
                            <div style="display: flex; align-items: center; background-color: white; border-radius: 8px; padding: 12px; margin-bottom: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                                <div style="color: #64748B; margin-right: 10px;">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="19" x2="12" y2="5"></line><polyline points="5 12 12 5 19 12"></polyline></svg>
                                </div>
                                <div style="width: 24px; height: 24px; border: 2px solid #10B981; border-radius: 6px; margin-right: 12px;"></div>
                                <div style="flex-grow: 1;">Eggs</div>
                                <div style="color: #64748B;">12 pcs</div>
                            </div>
                            
                            <div style="display: flex; align-items: center; background-color: white; border-radius: 8px; padding: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                                <div style="color: #64748B; margin-right: 10px;">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="19" x2="12" y2="5"></line><polyline points="5 12 12 5 19 12"></polyline></svg>
                                </div>
                                <div style="width: 24px; height: 24px; border: 2px solid #10B981; border-radius: 6px; margin-right: 12px;"></div>
                                <div style="flex-grow: 1;">Bread</div>
                                <div style="color: #64748B;">1 loaf</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        
        <!-- Recipe Integration -->
        <section class="section">
            <h2 class="section-title">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 11h.01"></path><path d="M11 15h.01"></path><path d="M16 16h.01"></path><path d="m2 16 20 6-6-20A10 10 0 0 0 2 16Z"></path></svg>
                3. Recipe Integration
            </h2>
            
            <div class="improvement-grid">
                <div class="improvement-card">
                    <div class="card-header">
                        <h3 class="card-title">Recipe Details View</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Add a detailed recipe view with ingredients, preparation steps, and nutrition information accessible by tapping any recipe.</p>
                        <p class="reference">Reference: Apple Human Interface Guidelines - Navigation</p>
                        
                        <div class="phone-mockup" style="max-width: 240px; height: 400px;">
                            <div class="phone-screen">
                                <div class="status-bar">
                                    <div>9:41</div>
                                    <div>📶</div>
                                </div>
                                <div class="header-bar" style="display: flex; justify-content: space-between; padding: 0 15px;">
                                    <div>&lt; Back</div>
                                    <div style="font-size: 16px;">Recipe</div>
                                    <div></div>
                                </div>
                                <div class="content" style="padding: 0; height: calc(100% - 94px);">
                                    <div style="height: 160px; background-color: var(--primary); display: flex; align-items: center; justify-content: center; color: white; font-size: 32px;">
                                        🍝
                                    </div>
                                    <div style="padding: 15px;">
                                        <h3 style="font-size: 20px; margin-bottom: 10px;">Creamy Spinach Pasta</h3>
                                        <div style="display: flex; gap: 10px; margin-bottom: 15px;">
                                            <div style="background-color: #f8fafc; border-radius: 15px; padding: 5px 10px; font-size: 12px;">25 mins</div>
                                            <div style="background-color: #f8fafc; border-radius: 15px; padding: 5px 10px; font-size: 12px;">4 servings</div>
                                            <div style="background-color: #f8fafc; border-radius: 15px; padding: 5px 10px; font-size: 12px;">Easy</div>
                                        </div>
                                        
                                        <div style="font-weight: 600; margin-bottom: 10px;">Ingredients</div>
                                        <ul style="list-style-type: none; margin: 0; padding: 0; margin-bottom: 15px;">
                                            <li style="display: flex; align-items: center; margin-bottom: 8px;">
                                                <div style="width: 8px; height: 8px; border-radius: 4px; background-color: var(--primary); margin-right: 8px;"></div>
                                                <div>250g pasta</div>
                                            </li>
                                            <li style="display: flex; align-items: center; margin-bottom: 8px;">
                                                <div style="width: 8px; height: 8px; border-radius: 4px; background-color: var(--primary); margin-right: 8px;"></div>
                                                <div>200g fresh spinach</div>
                                            </li>
                                            <li style="display: flex; align-items: center; margin-bottom: 8px;">
                                                <div style="width: 8px; height: 8px; border-radius: 4px; background-color: var(--primary); margin-right: 8px;"></div>
                                                <div>2 cloves garlic</div>
                                            </li>
                                            <li style="display: flex; align-items: center; margin-bottom: 8px; color: #EF4444;">
                                                <div style="width: 8px; height: 8px; border-radius: 4px; background-color: #EF4444; margin-right: 8px;"></div>
                                                <div>200ml heavy cream (missing)</div>
                                            </li>
                                        </ul>
                                        
                                        <div style="font-weight: 600; margin-bottom: 10px;">Instructions</div>
                                        <div style="height: 60px; overflow: hidden; position: relative; color: #64748B; font-size: 14px;">
                                            1. Cook pasta according to package instructions.<br>
                                            2. In a large pan, sauté garlic in olive oil.<br>
                                            3. Add spinach and cook until wilted.<br>
                                            <div style="position: absolute; bottom: 0; left: 0; right: 0; height: 40px; background: linear-gradient(transparent, white);"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="improvement-card">
                    <div class="card-header">
                        <h3 class="card-title">Enhanced Recipe Visuals</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Replace placeholder emoji images with high-quality food photography or stylized illustrations to increase appeal.</p>
                        <p class="reference">Reference: Apple Human Interface Guidelines - Imagery</p>
                        
                        <div class="compare-container">
                            <div class="compare-item">
                                <div class="compare-label">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                                    Current
                                </div>
                                <div style="border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                                    <div style="height: 120px; background-color: var(--primary); display: flex; align-items: center; justify-content: center; color: white; font-size: 36px;">
                                        🍝
                                    </div>
                                    <div style="padding: 10px; background-color: white;">
                                        <div style="font-weight: 600; margin-bottom: 5px;">Creamy Spinach Pasta</div>
                                        <div style="color: #64748B; font-size: 14px;">25 mins • 4 servings</div>
                                    </div>
                                </div>
                            </div>
                            <div class="compare-item">
                                <div class="compare-label">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="8" y1="12" x2="16" y2="12"></line><line x1="12" y1="16" x2="12" y2="8"></line></svg>
                                    Improved
                                </div>
                                <div style="border-radius: 12px; overflow: hidden; box-shadow: 0 4px 8px rgba(0,0,0,0.1); position: relative;">
                                    <div style="height: 120px; background: linear-gradient(rgba(0,0,0,0.2), rgba(0,0,0,0.2)), url('https://images.unsplash.com/photo-1601944979212-2451697bc30f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80'); background-size: cover; background-position: center;"></div>
                                    <div style="position: absolute; top: 10px; right: 10px; background-color: rgba(255,255,255,0.9); border-radius: 20px; padding: 5px 10px; font-size: 12px; color: var(--primary-dark);">
                                        25 mins
                                    </div>
                                    <div style="padding: 12px; background-color: white;">
                                        <div style="font-weight: 600; margin-bottom: 5px;">Creamy Spinach Pasta</div>
                                        <div style="display: flex; justify-content: space-between; align-items: center;">
                                            <div style="color: #64748B; font-size: 14px;">4 servings</div>
                                            <div style="color: var(--primary); font-size: 14px; font-weight: 500;">View Recipe →</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="improvement-card">
                    <div class="card-header">
                        <h3 class="card-title">Recipe Filtering</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Add filtering options to recipe views to help users quickly find recipes that match their preferences or dietary needs.</p>
                        <p class="reference">Reference: Apple Human Interface Guidelines - Search and Filter</p>
                        
                        <div style="background-color: white; border-radius: 12px; padding: 15px; margin-top: 15px; box-shadow: 0 2px 5px rgba(0,0,0,0.05);">
                            <div style="margin-bottom: 15px; font-weight: 600;">Filter Recipes</div>
                            <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 15px;">
                                <div style="background-color: var(--primary); color: white; padding: 8px 12px; border-radius: 20px; font-size: 14px;">
                                    Quick Meals
                                </div>
                                <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; color: #64748B; padding: 8px 12px; border-radius: 20px; font-size: 14px;">
                                    Vegetarian
                                </div>
                                <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; color: #64748B; padding: 8px 12px; border-radius: 20px; font-size: 14px;">
                                    Low Carb
                                </div>
                                <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; color: #64748B; padding: 8px 12px; border-radius: 20px; font-size: 14px;">
                                    Family Friendly
                                </div>
                                <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; color: #64748B; padding: 8px 12px; border-radius: 20px; font-size: 14px;">
                                    Budget
                                </div>
                            </div>
                            <div style="color: var(--primary); font-weight: 500; display: flex; justify-content: center; margin-top: 10px;">
                                Apply Filters
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        
        <!-- User Experience Enhancements -->
        <section class="section">
            <h2 class="section-title">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                5. User Experience Enhancements
            </h2>
            
            <div class="improvement-grid">
                <div class="improvement-card">
                    <div class="card-header">
                        <h3 class="card-title">Onboarding Flow</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Create a simple onboarding process to highlight key features for new users and reduce learning curve.</p>
                        <p class="reference">Reference: Apple Human Interface Guidelines - Onboarding</p>
                        
                        <div style="display: flex; gap: 10px; overflow-x: auto; padding: 15px 0; margin-top: 15px;">
                            <div style="min-width: 200px; background-color: white; border-radius: 12px; padding: 15px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); text-align: center;">
                                <div style="color: var(--primary); font-size: 32px; margin-bottom: 15px;">📋</div>
                                <div style="font-weight: 600; margin-bottom: 8px;">Smart Lists</div>
                                <div style="color: #64748B; font-size: 14px;">Your grocery lists automatically organize by category as you add items.</div>
                            </div>
                            <div style="min-width: 200px; background-color: white; border-radius: 12px; padding: 15px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); text-align: center;">
                                <div style="color: var(--primary); font-size: 32px; margin-bottom: 15px;">🍳</div>
                                <div style="font-weight: 600; margin-bottom: 8px;">Recipe Discovery</div>
                                <div style="color: #64748B; font-size: 14px;">Discover recipes you can make with what's already on your list.</div>
                            </div>
                            <div style="min-width: 200px; background-color: white; border-radius: 12px; padding: 15px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); text-align: center;">
                                <div style="color: var(--primary); font-size: 32px; margin-bottom: 15px;">🤖</div>
                                <div style="font-weight: 600; margin-bottom: 8px;">AI Assistant</div>
                                <div style="color: #64748B; font-size: 14px;">Get personalized meal suggestions and shopping advice.</div>
                            </div>
                        </div>
                        <div style="margin-top: 15px; display: flex; justify-content: center; gap: 5px;">
                            <div style="width: 8px; height: 8px; border-radius: 4px; background-color: var(--primary);"></div>
                            <div style="width: 8px; height: 8px; border-radius: 4px; background-color: #e2e8f0;"></div>
                            <div style="width: 8px; height: 8px; border-radius: 4px; background-color: #e2e8f0;"></div>
                        </div>
                    </div>
                </div>
                
                <div class="improvement-card">
                    <div class="card-header">
                        <h3 class="card-title">Haptic Feedback</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Implement subtle haptic feedback for important actions to provide physical confirmation and improve the tactile experience.</p>
                        <p class="reference">Reference: Apple Human Interface Guidelines - Haptics</p>
                        
                        <table style="width: 100%; border-collapse: collapse; margin-top: 15px; background-color: white; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                            <thead>
                                <tr>
                                    <th style="padding: 10px; text-align: left; border-bottom: 1px solid #e2e8f0;">Action</th>
                                    <th style="padding: 10px; text-align: left; border-bottom: 1px solid #e2e8f0;">Haptic Type</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td style="padding: 10px; border-bottom: 1px solid #e2e8f0;">Checking off item</td>
                                    <td style="padding: 10px; border-bottom: 1px solid #e2e8f0;">Light impact</td>
                                </tr>
                                <tr>
                                    <td style="padding: 10px; border-bottom: 1px solid #e2e8f0;">Adding to list</td>
                                    <td style="padding: 10px; border-bottom: 1px solid #e2e8f0;">Light impact</td>
                                </tr>
                                <tr>
                                    <td style="padding: 10px; border-bottom: 1px solid #e2e8f0;">Creating meal plan</td>
                                    <td style="padding: 10px; border-bottom: 1px solid #e2e8f0;">Medium impact</td>
                                </tr>
                                <tr>
                                    <td style="padding: 10px;">Error state</td>
                                    <td style="padding: 10px;">Error feedback</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <div class="improvement-card">
                    <div class="card-header">
                        <h3 class="card-title">Empty States</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Design friendly empty states for all views to guide users on first use and provide a more polished experience.</p>
                        <p class="reference">Reference: Apple Human Interface Guidelines - Empty States</p>
                        
                        <div style="background-color: white; border-radius: 12px; padding: 20px; margin-top: 15px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); text-align: center;">
                            <div style="margin-bottom: 15px; color: var(--primary-light);">
                                <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg>
                            </div>
                            <div style="font-weight: 600; margin-bottom: 8px; color: var(--text);">Your grocery list is empty</div>
                            <div style="color: #64748B; font-size: 14px; margin-bottom: 20px;">Add your first items to get started with smart suggestions and recipe ideas.</div>
                            <button style="background-color: var(--primary); color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 500;">Add First Item</button>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        
        <!-- Visual Refinements -->
        <section class="section">
            <h2 class="section-title">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
                7. Visual Refinements
            </h2>
            
            <div class="improvement-grid">
                <div class="improvement-card">
                    <div class="card-header">
                        <h3 class="card-title">Typography Refinement</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Use SF Pro consistently across the app with appropriate size and weight hierarchy for better readability and visual harmony.</p>
                d-header">
                        <h3 class="card-title">Tab Bar Refinement</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Replace basic text icons with Apple's SF Symbols for a more polished, consistent look that follows iOS standards.</p>
                        <p class="reference">Reference: Apple Human Interface Guidelines - Tab Bars</p>
                        
                        <div class="compare-container">
                            <div class="compare-item">
                                <div class="compare-label">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                                    Current
                                </div>
                                <div style="background-color: white; border-radius: 8px; padding: 10px; display: flex; justify-content: space-around; width: 100%;">
                                    <div style="display: flex; flex-direction: column; align-items: center; color: #10B981;">
                                        <div style="font-size: 20px;">📋</div>
                                        <div style="font-size: 12px;">List</div>
                                    </div>
                                    <div style="display: flex; flex-direction: column; align-items: center; color: #64748B;">
                                        <div style="font-size: 20px;">🔍</div>
                                        <div style="font-size: 12px;">Recipes</div>
                                    </div>
                                    <div style="display: flex; flex-direction: column; align-items: center; color: #64748B;">
                                        <div style="font-size: 20px;">📅</div>
                                        <div style="font-size: 12px;">Meal Plan</div>
                                    </div>
                                    <div style="display: flex; flex-direction: column; align-items: center; color: #64748B;">
                                        <div style="font-size: 20px;">🛒</div>
                                        <div style="font-size: 12px;">Assistant</div>
                                    </div>
                                </div>
                            </div>
                            <div class="compare-item">
                                <div class="compare-label">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="8" y1="12" x2="16" y2="12"></line><line x1="12" y1="16" x2="12" y2="8"></line></svg>
                                    Improved
                                </div>
                                <div style="background-color: white; border-radius: 8px; padding: 10px; display: flex; justify-content: space-around; width: 100%;">
                                    <div style="display: flex; flex-direction: column; align-items: center; color: #10B981;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg>
                                        <div style="font-size: 12px; margin-top: 4px;">List</div>
                                    </div>
                                    <div style="display: flex; flex-direction: column; align-items: center; color: #64748B;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3c.132.323.217.682.217 1.055 0 1.743-1.467 3.158-3.283 3.158-1.815 0-3.283-1.415-3.283-3.158 0-.373.085-.732.217-1.055"></path><path d="m17.822 9.982-.505 5.062a.92.92 0 0 1-1.151.805l-3.113-.787a1.17 1.17 0 0 0-.576 0l-3.113.787a.92.92 0 0 1-1.151-.805l-.505-5.062a.92.92 0 0 1 .924-.997H16.9a.92.92 0 0 1 .923.997Z"></path><path d="M8 15h8"></path><path d="M12 15v3"></path><path d="M8 3h8"></path></svg>
                                        <div style="font-size: 12px; margin-top: 4px;">Recipes</div>
                                    </div>
                                    <div style="display: flex; flex-direction: column; align-items: center; color: #64748B;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                                        <div style="font-size: 12px; margin-top: 4px;">Meal Plan</div>
                                    </div>
                                    <div style="display: flex; flex-direction: column; align-items: center; color: #64748B;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
                                        <div style="font-size: 12px; margin-top: 4px;">Assistant</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="improvement-card">
                    <div class="card-header">
                        <h3 class="card-title">Header Accessibility</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Optimize the green header contrast with white text for better readability and accessibility compliance.</p>
                        <p class="reference">Reference: WCAG 2.1 Contrast Guidelines</p>
                        
                        <div class="compare-container">
                            <div class="compare-item">
                                <div class="compare-label">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                                    Current
                                </div>
                                <div style="background-color: #10B981; color: white; border-radius: 8px 8px 0 0; padding: 15px; text-align: center; font-weight: 600;">
                                    GroceryAI
                                </div>
                            </div>
                            <div class="compare-item">
                                <div class="compare-label">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="8" y1="12" x2="16" y2="12"></line><line x1="12" y1="16" x2="12" y2="8"></line></svg>
                                    Improved
                                </div>
                                <div style="background: linear-gradient(to bottom, #059669, #10B981); color: white; border-radius: 8px 8px 0 0; padding: 15px; text-align: center; font-weight: 600; position: relative; overflow: hidden;">
                                    <div style="position: absolute; width: 100px; height: 100px; background-color: rgba(255,255,255,0.1); border-radius: 50%; top: -50px; right: -20px;"></div>
                                    <div style="position: relative; z-index: 2;">GroceryAI</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="improvement-card">
                    <div class="card-header">
                        <h3 class="card-title">Gesture Navigation</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Add intuitive swipe gestures between related screens for fluid, iOS-native navigation.</p>
                        <p class="reference">Reference: Apple Human Interface Guidelines - Gestures</p>
                        
                        <div class="animation-demo">
                            <div class="animation-box">
                                <div class="swipe-indicator"></div>
                                <div style="position: relative; z-index: 2;">Swipe between days in Meal Plan</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        
        <!-- List Improvements -->
        <section class="section">
            <h2 class="section-title">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg>
                2. List Improvements
            </h2>
            
            <div class="improvement-grid">
                <div class="improvement-card">
                    <div class="card-header">
                        <h3 class="card-title">Checkbox Animation</h3>
                    </div>
                    <div class="card-body">
                        <p class="card-description">Add subtle animations when checking items off the list for better feedback and a more polished experience.</p>
                        <p class="reference">Reference: Apple Human Interface Guidelines - Feedback</p>
                        
                        <div class="animation-box" style="margin-top: 20px;">
                            <div class="fade-item">
                                <div style="width: 24px; height: 24px; border-radius: 6px; border: 2px solid var(--primary); margin-right: 12px; display: flex; align-items: center; justify-content: center; color: white; background-color: var(--primary);">✓</div>
                                <div>Milk</div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="improvement-card">
                    <div class="car