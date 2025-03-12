<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GroceryAI Meal Plan UI Redesign</title>
    <style>
        :root {
            --primary: #00A676;
            --primary-light: #1FB786;
            --primary-dark: #008F66;
            --background: #121212;
            --card-bg: #1E1E1E;
            --text: #FFFFFF;
            --text-secondary: #AAAAAA;
            --border: #333333;
            --breakfast: #FF9500;
            --lunch: #0A84FF;
            --dinner: #BF5AF2;
            --snack: #30D158;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #000;
            color: var(--text);
        }
        
        .container {
            max-width: 375px;
            margin: 0 auto;
            background-color: var(--background);
            min-height: 100vh;
            position: relative;
            overflow: hidden;
        }
        
        .status-bar {
            display: flex;
            justify-content: space-between;
            padding: 10px 15px;
            font-size: 14px;
            font-weight: bold;
        }
        
        .status-bar .time {
            flex: 1;
        }
        
        .status-bar .icons {
            display: flex;
            gap: 5px;
        }
        
        .header {
            text-align: center;
            padding: 10px 15px;
            font-size: 17px;
            font-weight: bold;
            border-bottom: 1px solid #333;
        }
        
        /* Week Selector Styles */
        .week-selector {
            background-color: var(--primary);
            border-radius: 12px;
            padding: 12px;
            margin: 15px;
            color: white;
        }
        
        .month-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .month-title {
            font-size: 20px;
            font-weight: 600;
        }
        
        .days-row {
            display: flex;
            justify-content: space-around;
            margin-bottom: 8px;
        }
        
        .day-abbr {
            font-size: 12px;
            opacity: 0.8;
            text-align: center;
            width: 36px;
        }
        
        .days-container {
            display: flex;
            justify-content: space-around;
        }
        
        .day-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 40px;
        }
        
        .day-number {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 17px;
            margin-bottom: 4px;
        }
        
        .day-selected {
            background-color: rgba(0, 0, 0, 0.2);
        }
        
        .day-today {
            border: 2px solid rgba(255, 255, 255, 0.5);
        }
        
        .meal-indicators {
            display: flex;
            gap: 3px;
        }
        
        .indicator {
            width: 6px;
            height: 6px;
            border-radius: 50%;
        }
        
        .indicator-filled {
            background-color: white;
        }
        
        .indicator-empty {
            background-color: rgba(255, 255, 255, 0.3);
        }
        
        /* Week Summary Styles */
        .week-summary {
            background-color: var(--card-bg);
            border-radius: 12px;
            padding: 15px;
            margin: 15px;
        }
        
        .summary-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
        }
        
        .completion-circles {
            display: flex;
            gap: 3px;
            margin-bottom: 12px;
        }
        
        .day-completion {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 2px;
        }
        
        .day-letter {
            font-size: 10px;
            color: var(--text-secondary);
        }
        
        .completion-circle {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            border: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            font-weight: bold;
        }
        
        .circle-filled {
            background-color: var(--primary);
            color: white;
            border: none;
        }
        
        .circle-partial {
            background-color: var(--primary-light);
            color: white;
            border: none;
        }
        
        .stats-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
        }
        
        .stat {
            font-weight: bold;
            color: var(--primary);
        }
        
        .actions-row {
            display: flex;
            gap: 10px;
        }
        
        .action-button {
            flex: 1;
            background-color: rgba(255, 255, 255, 0.05);
            border-radius: 8px;
            padding: 12px 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
        }
        
        .action-icon {
            color: var(--primary);
            font-size: 20px;
        }
        
        .action-label {
            font-size: 12px;
            color: var(--primary);
        }
        
        /* Day Card Styles */
        .day-card {
            background-color: var(--card-bg);
            border-radius: 12px;
            margin: 15px;
            overflow: hidden;
        }
        
        .day-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px;
        }
        
        .day-title {
            display: flex;
            flex-direction: column;
        }
        
        .day-name {
            font-size: 18px;
            font-weight: 600;
        }
        
        .day-date {
            font-size: 14px;
            color: var(--text-secondary);
        }
        
        .today-label {
            color: var(--primary);
        }
        
        .day-actions {
            display: flex;
            gap: 10px;
        }
        
        .icon-button {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }
        
        .primary-button {
            background-color: var(--primary);
            color: white;
        }
        
        .secondary-button {
            background-color: rgba(255, 255, 255, 0.05);
            color: var(--text);
        }
        
        .meal-list {
            padding: 0 15px 15px;
        }
        
        .meal-row {
            display: flex;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid var(--border);
        }
        
        .meal-row:last-child {
            border-bottom: none;
        }
        
        .meal-type-indicator {
            display: flex;
            align-items: center;
            width: 100px;
        }
        
        .meal-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 10px;
        }
        
        .meal-type-name {
            font-weight: 500;
        }
        
        .meal-content {
            flex: 1;
        }
        
        .meal-name {
            font-weight: 500;
        }
        
        .meal-details {
            font-size: 12px;
            color: var(--text-secondary);
            margin-top: 2px;
        }
        
        .add-meal-button {
            background-color: var(--primary);
            color: white;
            border-radius: 20px;
            padding: 6px 12px;
            font-size: 14px;
            font-weight: 500;
        }
        
        .remove-button {
            color: var(--text-secondary);
            margin-left: 10px;
        }
        
        /* Collapsed Day Card */
        .collapsed-day {
            background-color: var(--card-bg);
            border-radius: 12px;
            margin: 15px;
            padding: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .collapsed-indicators {
            display: flex;
            gap: 6px;
        }
        
        /* Shopping List Button */
        .floating-button {
            position: fixed;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            background-color: var(--primary);
            color: white;
            border-radius: 30px;
            padding: 15px 25px;
            font-size: 16px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
            width: 80%;
            justify-content: center;
            z-index: 100;
        }
        
        /* Add Meal Sheet */
        .add-meal-sheet {
            background-color: var(--background);
            border-radius: 12px 12px 0 0;
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 90%;
            z-index: 1000;
        }
        
        .sheet-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px;
            border-bottom: 1px solid var(--border);
        }
        
        .segmented-control {
            display: flex;
            margin: 15px;
            border-radius: 8px;
            overflow: hidden;
            background-color: rgba(255, 255, 255, 0.05);
        }
        
        .segment {
            flex: 1;
            text-align: center;
            padding: 10px 0;
            font-size: 14px;
        }
        
        .segment-selected {
            background-color: var(--primary);
            color: white;
        }
        
        .search-bar {
            margin: 15px;
            background-color: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 10px 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .search-icon {
            color: var(--text-secondary);
        }
        
        .search-input {
            flex: 1;
            background: none;
            border: none;
            color: var(--text);
            font-size: 16px;
            outline: none;
        }
        
        .quick-suggestions {
            display: flex;
            overflow-x: auto;
            gap: 10px;
            padding: 0 15px 15px;
        }
        
        .suggestion-chip {
            background-color: rgba(255, 255, 255, 0.05);
            border-radius: 20px;
            padding: 8px 15px;
            font-size: 14px;
            white-space: nowrap;
        }
        
        .recipe-list {
            overflow-y: auto;
            height: calc(100% - 200px);
        }
        
        .recipe-item {
            display: flex;
            padding: 15px;
            border-bottom: 1px solid var(--border);
        }
        
        .recipe-image {
            width: 60px;
            height: 60px;
            border-radius: 8px;
            margin-right: 15px;
            background-color: rgba(255, 255, 255, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .recipe-details {
            flex: 1;
        }
        
        .recipe-name {
            font-size: 16px;
            font-weight: 500;
            margin-bottom: 4px;
        }
        
        .recipe-meta {
            font-size: 12px;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .selected-indicator {
            color: var(--primary);
            font-size: 20px;
        }
        
        .bottom-button {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            padding: 15px;
            background-color: var(--background);
            border-top: 1px solid var(--border);
        }
        
        .primary-action-button {
            background-color: var(--primary);
            color: white;
            border-radius: 10px;
            padding: 15px 0;
            text-align: center;
            font-size: 16px;
            font-weight: 500;
        }
        
        .demo-button {
            position: fixed;
            top: 10px;
            right: 10px;
            background-color: rgba(0,0,0,0.5);
            color: white;
            border: none;
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 12px;
            cursor: pointer;
        }
        
        /* Notes and annotations */
        .annotation {
            position: absolute;
            background-color: rgba(255, 255, 255, 0.95);
            color: black;
            padding: 10px;
            border-radius: 8px;
            font-size: 12px;
            max-width: 200px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
            z-index: 500;
        }
        
        .annotation-line {
            position: absolute;
            background-color: rgba(255, 255, 255, 0.7);
            z-index: 499;
        }
        
        .spacer {
            height: 80px;
        }
        
        /* Toast Notification */
        .toast {
            position: fixed;
            top: 40px;
            left: 50%;
            transform: translateX(-50%);
            background-color: rgba(0, 0, 0, 0.8);
            color: white;
            padding: 10px 20px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
            z-index: 2000;
        }
        
        .tab-bar {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            background-color: var(--card-bg);
            display: flex;
            padding: 10px 0;
            justify-content: space-around;
        }
        
        .tab-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 5px 0;
            font-size: 10px;
            color: var(--text-secondary);
        }
        
        .tab-icon {
            font-size: 22px;
            margin-bottom: 2px;
        }
        
        .tab-active {
            color: var(--primary);
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Status Bar -->
        <div class="status-bar">
            <div class="time">14:18</div>
            <div class="icons">
                <span>●●●●</span>
                <span>📶</span>
                <span>🔋</span>
            </div>
        </div>
        
        <!-- Header -->
        <div class="header">Meal Plan</div>
        
        <!-- Week Selector - IMPROVED -->
        <div class="week-selector">
            <div class="month-nav">
                <div>◀</div>
                <div class="month-title">March 2025</div>
                <div>▶</div>
            </div>
            
            <div class="days-row">
                <div class="day-abbr">M</div>
                <div class="day-abbr">T</div>
                <div class="day-abbr">W</div>
                <div class="day-abbr">T</div>
                <div class="day-abbr">F</div>
                <div class="day-abbr">S</div>
                <div class="day-abbr">S</div>
            </div>
            
            <div class="days-container">
                <div class="day-item">
                    <div class="day-number">10</div>
                    <div class="meal-indicators">
                        <div class="indicator indicator-filled" style="background-color: var(--breakfast);"></div>
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                    </div>
                </div>
                <div class="day-item">
                    <div class="day-number day-selected day-today">11</div>
                    <div class="meal-indicators">
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                    </div>
                </div>
                <div class="day-item">
                    <div class="day-number">12</div>
                    <div class="meal-indicators">
                        <div class="indicator indicator-filled" style="background-color: var(--breakfast);"></div>
                        <div class="indicator indicator-filled" style="background-color: var(--lunch);"></div>
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                    </div>
                </div>
                <div class="day-item">
                    <div class="day-number">13</div>
                    <div class="meal-indicators">
                        <div class="indicator indicator-filled" style="background-color: var(--breakfast);"></div>
                        <div class="indicator indicator-filled" style="background-color: var(--lunch);"></div>
                        <div class="indicator indicator-filled" style="background-color: var(--dinner);"></div>
                        <div class="indicator indicator-empty"></div>
                    </div>
                </div>
                <div class="day-item">
                    <div class="day-number">14</div>
                    <div class="meal-indicators">
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                    </div>
                </div>
                <div class="day-item">
                    <div class="day-number">15</div>
                    <div class="meal-indicators">
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-filled" style="background-color: var(--snack);"></div>
                    </div>
                </div>
                <div class="day-item">
                    <div class="day-number">16</div>
                    <div class="meal-indicators">
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                        <div class="indicator indicator-empty"></div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Week Summary - IMPROVED -->
        <div class="week-summary">
            <div class="summary-header">
                <div style="font-weight: 600;">Week Planning</div>
                <div style="font-weight: 600;">This Week</div>
            </div>
            
            <!-- Day-by-day completion circles -->
            <div class="completion-circles">
                <div class="day-completion">
                    <div class="day-letter">M</div>
                    <div class="completion-circle circle-partial">1</div>
                </div>
                <div class="day-completion">
                    <div class="day-letter">T</div>
                    <div class="completion-circle">0</div>
                </div>
                <div class="day-completion">
                    <div class="day-letter">W</div>
                    <div class="completion-circle circle-partial">2</div>
                </div>
                <div class="day-completion">
                    <div class="day-letter">T</div>
                    <div class="completion-circle circle-filled">3</div>
                </div>
                <div class="day-completion">
                    <div class="day-letter">F</div>
                    <div class="completion-circle">0</div>
                </div>
                <div class="day-completion">
                    <div class="day-letter">S</div>
                    <div class="completion-circle circle-partial">1</div>
                </div>
                <div class="day-completion">
                    <div class="day-letter">S</div>
                    <div class="completion-circle">0</div>
                </div>
            </div>
            
            <div class="stats-row">
                <div>
                    <span class="stat">7 meals</span>
                </div>
                <div>
                    <span class="stat">5 recipes</span>
                </div>
            </div>
            
            <div class="actions-row">
                <div class="action-button">
                    <div class="action-icon">+</div>
                    <div class="action-label">Today</div>
                </div>
                <div class="action-button">
                    <div class="action-icon">↻</div>
                    <div class="action-label">Quick Fill</div>
                </div>
                <div class="action-button">
                    <div class="action-icon">🛒</div>
                    <div class="action-label">Shopping</div>
                </div>
            </div>
        </div>
        
        <!-- Day Card - IMPROVED -->
        <div class="day-card">
            <div class="day-header">
                <div class="day-title">
                    <div class="day-name">Tuesday</div>
                    <div class="day-date today-label">Today</div>
                </div>
                <div class="day-actions">
                    <div class="icon-button primary-button">+</div>
                    <div class="icon-button secondary-button">▼</div>
                </div>
            </div>
            
            <div class="meal-list">
                <!-- Breakfast Row -->
                <div class="meal-row">
                    <div class="meal-type-indicator">
                        <div class="meal-dot" style="background-color: var(--breakfast);"></div>
                        <div class="meal-type-name">Breakfast:</div>
                    </div>
                    <div class="meal-content">
                    </div>
                    <div class="add-meal-button">Add</div>
                </div>
                
                <!-- Lunch Row -->
                <div class="meal-row">
                    <div class="meal-type-indicator">
                        <div class="meal-dot" style="background-color: var(--lunch);"></div>
                        <div class="meal-type-name">Lunch:</div>
                    </div>
                    <div class="meal-content">
                    </div>
                    <div class="add-meal-button">Add</div>
                </div>
                
                <!-- Dinner Row -->
                <div class="meal-row">
                    <div class="meal-type-indicator">
                        <div class="meal-dot" style="background-color: var(--dinner);"></div>
                        <div class="meal-type-name">Dinner:</div>
                    </div>
                    <div class="meal-content">
                    </div>
                    <div class="add-meal-button">Add</div>
                </div>
                
                <!-- Snack Row -->
                <div class="meal-row">
                    <div class="meal-type-indicator">
                        <div class="meal-dot" style="background-color: var(--snack);"></div>
                        <div class="meal-type-name">Snack:</div>
                    </div>
                    <div class="meal-content">
                    </div>
                    <div class="add-meal-button">Add</div>
                </div>
            </div>
        </div>
        
        <!-- Collapsed Day Card - IMPROVED -->
        <div class="collapsed-day">
            <div class="day-title">
                <div class="day-name">Wednesday</div>
                <div class="day-date">Mar 12</div>
            </div>
            
            <div class="collapsed-indicators">
                <div class="meal-dot" style="background-color: var(--breakfast);"></div>
                <div class="meal-dot" style="background-color: var(--lunch);"></div>
                <div class="meal-dot" style="background-color: var(--border);"></div>
                <div class="meal-dot" style="background-color: var(--border);"></div>
            </div>
            
            <div class="day-actions">
                <div class="icon-button primary-button">+</div>
                <div class="icon-button secondary-button">▼</div>
            </div>
        </div>
        
        <!-- Another Collapsed Day Card -->
        <div class="collapsed-day">
            <div class="day-title">
                <div class="day-name">Thursday</div>
                <div class="day-date">Mar 13</div>
            </div>
            
            <div class="collapsed-indicators">
                <div class="meal-dot" style="background-color: var(--breakfast);"></div>
                <div class="meal-dot" style="background-color: var(--lunch);"></div>
                <div class="meal-dot" style="background-color: var(--dinner);"></div>
                <div class="meal-dot" style="background-color: var(--border);"></div>
            </div>
            
            <div class="day-actions">
                <div class="icon-button primary-button">+</div>
                <div class="icon-button secondary-button">▼</div>
            </div>
        </div>
        
        <div class="spacer"></div>
        
        <!-- Floating Shopping List Button -->
        <div class="floating-button">
            🛒 Create Shopping List
        </div>
        
        <!-- Tab Bar -->
        <div class="tab-bar">
            <div class="tab-item">
                <div class="tab-icon">≡</div>
                <div>List</div>
            </div>
            <div class="tab-item">
                <div class="tab-icon">📖</div>
                <div>Recipes</div>
            </div>
            <div class="tab-item tab-active">
                <div class="tab-icon">📆</div>
                <div>Meal Plan</div>
            </div>
            <div class="tab-item">
                <div class="tab-icon">💡</div>
                <div>Tips</div>
            </div>
        </div>
        
        <!-- Annotations -->
        <div class="annotation" style="top: 140px; left: 10px;">
            1. SIMPLIFIED WEEK VIEW<br>
            - Show only one row of days<br>
            - Include meal dots for each day<br>
            - Highlight today and selected day differently
        </div>
        
        <div class="annotation" style="top: 280px; left: 150px;">
            2. IMPROVED PROGRESS TRACKING<br>
            - Visual circles for each day<br>
            - Numbers show completed meals<br>
            - Color-coded by completion level
        </div>
        
        <div class="annotation" style="top: 450px; left: 10px;">
            3. ENHANCED DAY CARDS<br>
            - Clear meal type indicators<br>
            - Today highlighted in primary color<br>
            - Consistent add buttons<br>
            - Subtle dividers between meals
        </div>
        
        <div class="annotation" style="top: 580px; left: 120px;">
            4. COLLAPSED DAY CARDS<br>
            - Show just the essential info<br>
            - Status dots for quick reference<br>
            - Saves vertical space
        </div>
        
        <div class="annotation" style="bottom: 70px; left: 150px;">
            5. FLOATING ACTION BUTTON<br>
            - Always accessible<br>
            - Clear purpose with icon<br>
            - Stands out visually
        </div>
    </div>
    
    <!-- ADD MEAL SHEET VIEW (separate screen) -->
    <div class="container" style="margin-top: 50px;">
        <div class="status-bar">
            <div class="time">14:18</div>
            <div class="icons">
                <span>●●●●</span>
                <span>📶</span>
                <span>🔋</span>
            </div>
        </div>
        
        <div class="add-meal-sheet">
            <div class="sheet-header">
                <div style="font-weight: 600;">Add Breakfast</div>
                <div style="color: var(--primary);">Cancel</div>
            </div>
            
            <div class="segmented-control">
                <div class="segment segment-selected">From Recipes</div>
                <div class="segment">Custom Meal</div>
            </div>
            
            <div class="search-bar">
                <div class="search-icon">🔍</div>
                <input class="search-input" placeholder="Search recipes">
            </div>
            
            <!-- Quick Suggestions -->
            <div class="quick-suggestions">
                <div class="suggestion-chip">Oatmeal</div>
                <div class="suggestion-chip">Scrambled Eggs</div>
                <div class="suggestion-chip">Yogurt & Fruit</div>
                <div class="suggestion-chip">Toast & Jam</div>
                <div class="suggestion-chip">Smoothie</div>
            </div>
            
            <div class="recipe-list">
                <!-- Recipe Item -->
                <div class="recipe-item">
                    <div class="recipe-image">🍳</div>
                    <div class="recipe-details">
                        <div class="recipe-name">Classic Pancakes</div>
                        <div class="recipe-meta">
                            <span>⏱️ 25 min</span>
                            <span>•</span>
                            <span>Easy</span>
                        </div>
                    </div>
                    <div class="selected-indicator">✓</div>
                </div>
                
                <!-- Recipe Item -->
                <div class="recipe-item">
                    <div class="recipe-image">🍇</div>
                    <div class="recipe-details">
                        <div class="recipe-name">Fruit & Yogurt Bowl</div>
                        <div class="recipe-meta">
                            <span>⏱️ 5 min</span>
                            <span>•</span>
                            <span>Easy</span>
                        </div>
                    </div>
                </div>
                
                <!-- Recipe Item -->
                <div class="recipe-item">
                    <div class="recipe-image">🥄</div>
                    <div class="recipe-details">
                        <div class="recipe-name">Overnight Oats</div>
                        <div class="recipe-meta">
                            <span>⏱️ 5 min + overnight</span>
                            <span>•</span>
                            <span>Easy</span>
                        </div>
                    </div>
                </div>
                
                <!-- Recipe Item -->
                <div class="recipe-item">
                    <div class="recipe-image">🍞</div>
                    <div class="recipe-details">
                        <div class="recipe-name">Avocado Toast</div>
                        <div class="recipe-meta">
                            <span>⏱️ 10 min</span>
                            <span>•</span>
                            <span>Easy</span>
                        </div>
                    </div>
                </div>
                
                <!-- Recipe Item -->
                <div class="recipe-item">
                    <div class="recipe-image">🍳</div>
                    <div class="recipe-details">
                        <div class="recipe-name">Veggie Omelette</div>
                        <div class="recipe-meta">
                            <span>⏱️ 15 min</span>
                            <span>•</span>
                            <span>Medium</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="bottom-button">
                <div class="primary-action-button">Add to Meal Plan</div>
            </div>
        </div>
        
        <!-- Annotations for Add Meal Screen -->
        <div class="annotation" style="top: 140px; right: 10px;">
            1. MEAL TYPE CONTEXT<br>
            - Header clearly shows meal type<br>
            - Sets expectations for content
        </div>
        
        <div class="annotation" style="top: 220px; left: 10px;">
            2. QUICK SUGGESTIONS<br>
            - Common choices for breakfast<br>
            - One-tap addition for speed<br>
            - Contextual to meal type
        </div>
        
        <div class="annotation" style="top: 380px; right: 10px;">
            3. VISUAL RECIPE LIST<br>
            - Icons represent food types<br>
            - Clear selection indicator<br>
            - Prep time and difficulty shown
        </div>
        
        <!-- Toast Notification -->
        <div class="toast">
            ✓ Shopping list created with 15 items
        </div>
    </div>
    
    <!-- CUSTOM MEAL ENTRY VIEW -->
    <div class="container" style="margin-top: 50px;">
        <div class="status-bar">
            <div class="time">14:18</div>
            <div class="icons">
                <span>●●●●</span>
                <span>📶</span>
                <span>🔋</span>
            </div>
        </div>
        
        <div class="add-meal-sheet">
            <div class="sheet-header">
                <div style="font-weight: 600;">Add Lunch</div>
                <div style="color: var(--primary);">Cancel</div>
            </div>
            
            <div class="segmented-control">
                <div class="segment">From Recipes</div>
                <div class="segment segment-selected">Custom Meal</div>
            </div>
            
            <div style="padding: 20px;">
                <div style="margin-bottom: 10px; color: var(--text-secondary);">Custom meal name</div>
                <div class="search-bar" style="margin: 0 0 20px 0;">
                    <input class="search-input" placeholder="Enter meal name" value="Leftover Pizza">
                </div>
                
                <div style="margin-bottom: 10px; color: var(--text-secondary);">Recently added custom meals</div>
                
                <div style="display: flex; flex-wrap: wrap; gap: 10px;">
                    <div class="suggestion-chip">Salad & Sandwich</div>
                    <div class="suggestion-chip">Leftovers</div>
                    <div class="suggestion-chip">Take-out</div>
                    <div class="suggestion-chip">Eating Out</div>
                    <div class="suggestion-chip">Burrito Bowl</div>
                </div>
            </div>
            
            <div class="bottom-button">
                <div class="primary-action-button">Add to Meal Plan</div>
            </div>
        </div>
        
        <!-- Annotations for Custom Meal Screen -->
        <div class="annotation" style="top: 200px; left: 150px;">
            1. CUSTOM MEAL ENTRY<br>
            - Simple text field for quick entry<br>
            - Recently used custom meals for quick reuse<br>
            - Maintains consistent UI with recipe view
        </div>
    </div>
    
    <div style="margin: 50px; color: white; font-size: 14px; line-height: 1.5;">
        <h2>Implementation Notes for Developers</h2>
        
        <h3>👨‍💻 Week Selector Component</h3>
        <ol>
            <li>Replace the current calendar-style week selector with this simpler, more visual approach</li>
            <li>Each day shows colored dots indicating which meals are planned</li>
            <li>Today has a subtle border to distinguish it</li>
            <li>Selected day has a darker background</li>
            <li>Only show one week at a time with arrows to navigate weeks</li>
            <li>Remove the duplicate weekday headers you currently have</li>
        </ol>
        
        <h3>📊 Day Completion Meter</h3>
        <ol>
            <li>Replace the current progress bar with individual day circles</li>
            <li>Show the count of meals planned in each circle</li>
            <li>Use color coding: empty = no meals, light green = some meals, dark green = all meals</li>
            <li>Keep the existing action buttons but make them more visually consistent</li>
        </ol>
        
        <h3>📝 Day Cards</h3>
        <ol>
            <li>For the current day, show the expanded view with all meal types</li>
            <li>Use colored dots before each meal type label for visual consistency</li>
            <li>Make "Add" buttons more prominent with rounded shapes</li>
            <li>Add subtle dividers between meal rows</li>
            <li>For future days, use the collapsed card view to save space</li>
            <li>In collapsed view, show status dots for all meal types</li>
        </ol>
        
        <h3>🛒 Shopping List Button</h3>
        <ol>
            <li>Move from bottom of content to a floating button</li>
            <li>Use a capsule shape with icon for better visibility</li>
            <li>Add shadow for elevation effect</li>
            <li>Position it to be always accessible without scrolling</li>
        </ol>
        
        <h3>🍽️ Add Meal Sheet</h3>
        <ol>
            <li>Keep the segmented control for toggling between recipes and custom meals</li>
            <li>Add quick suggestion chips for common meals based on meal type</li>
            <li>Add visual elements to recipe list (icons or placeholder images)</li>
            <li>Show recent custom meal suggestions on the custom tab</li>
            <li>Use consistent styling with the rest of the app</li>
        </ol>
        
        <h3>🎨 Color & Visual Guidelines</h3>
        <ol>
            <li>Primary Color: The green from your current app (#00A676)</li>
            <li>Meal Type Colors:
                <ul>
                    <li>Breakfast: Orange (#FF9500)</li>
                    <li>Lunch: Blue (#0A84FF)</li>
                    <li>Dinner: Purple (#BF5AF2)</li>
                    <li>Snack: Green (#30D158)</li>
                </ul>
            </li>
            <li>Background: Dark theme as per your current app</li>
            <li>Card Background: Slightly lighter than the main background</li>
            <li>Text: White for primary text, light gray for secondary text</li>
            <li>Rounded corners on all cards and buttons (12px radius for cards, 20-30px for buttons)</li>
        </ol>
        
        <h3>⚙️ Implementation Priorities</h3>
        <ol>
            <li><strong>Phase 1 (1 day):</strong>
                <ul>
                    <li>Fix the week selector</li>
                    <li>Implement the floating shopping list button</li>
                    <li>Add colored indicators to meal types</li>
                </ul>
            </li>
            <li><strong>Phase 2 (1-2 days):</strong>
                <ul>
                    <li>Implement day completion circles</li>
                    <li>Create the collapsible day cards</li>
                    <li>Enhance meal addition screen with quick suggestions</li>
                </ul>
            </li>
        </ol>
    </div>
</body>
</html>