import SwiftUI
import UIKit

struct MainTabView: View {
    @State private var selectedTab = 0
    
    // Create shared ViewModels
    @StateObject private var shoppingListViewModel = ShoppingListViewModel()
    @StateObject private var mealPlanViewModel: MealPlanViewModel
    
    // Instead of creating RecipeListViewModel, accept it as a parameter
    @ObservedObject var recipeListViewModel: RecipeListViewModel
    
    // Initializer to accept RecipeListViewModel
    init(recipeListViewModel: RecipeListViewModel) {
        self.recipeListViewModel = recipeListViewModel
        
        // Create shopping list view model first
        let shoppingListVM = ShoppingListViewModel()
        _shoppingListViewModel = StateObject(wrappedValue: shoppingListVM)
        
        // Initialize meal plan view model with the shopping list dependency
        _mealPlanViewModel = StateObject(wrappedValue: MealPlanViewModel(shoppingListViewModel: shoppingListVM))
    }
    
    var body: some View {
        let recipesViewModel = RecipesViewModel(recipeListViewModel: recipeListViewModel)
        
        return TabView(selection: $selectedTab) {
            NavigationStack {
                ShoppingListView(
                    viewModel: shoppingListViewModel,
                    recipesViewModel: recipesViewModel
                )
            }
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }
            .tag(0)
            
            NavigationStack {
                RecipesView(
                    shoppingListViewModel: shoppingListViewModel,
                    recipeListViewModel: recipeListViewModel,
                    recipesViewModel: recipesViewModel
                )
            }
            .tabItem {
                Label("Recipes", systemImage: "book")
            }
            .tag(1)
            
            NavigationStack {
                MealPlanView()
                    .environmentObject(mealPlanViewModel)
            }
            .tabItem {
                Label("Meal Plan", systemImage: "calendar")
            }
            .tag(2)
            
            NavigationStack {
                AIChatView()
            }
            .tabItem {
                Label("AI Chef", systemImage: "sparkle.magnifyingglass")
            }
            .tag(3)
        }
        .accentColor(AppTheme.accentTeal)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor(AppTheme.background)
            appearance.shadowColor = UIColor(AppTheme.borderColor)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // Custom styling to subtly highlight the AI Chef tab
            if let iconView = UITabBar.appearance().items?[3].value(forKey: "_view") as? UIView {
                for case let imageView as UIImageView in iconView.subviews {
                    imageView.contentMode = .center
                    imageView.layer.shadowColor = UIColor(AppTheme.accentTeal).cgColor
                    imageView.layer.shadowRadius = 4.0
                    imageView.layer.shadowOpacity = 0.6
                    imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
                    imageView.layer.masksToBounds = false
                }
            }
        }
        .environmentObject(shoppingListViewModel)
        .environmentObject(mealPlanViewModel)
    }
}

// AIChatView for the Fridge Snapshot feature demo
struct AIChatView: View {
    // State to track current view state
    @State private var showCamera = false
    @State private var isChatBusy = false
    @State private var chatMessages: [ChatMessage] = []
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    @State private var showFlash = false
    
    // Hardcoded data from design instructions
    let detectedIngredients = [
        "Chicken breast",
        "Bell peppers",
        "Onions",
        "Tomatoes",
        "Cheese",
        "Pasta"
    ]
    
    let recipes: [DemoRecipe] = [
        DemoRecipe(
            id: 1,
            title: "Chicken Pasta Primavera",
            cookTime: "25 min",
            servings: 4,
            match: "95%",
            ingredients: [
                "2 chicken breasts, cut into bite-sized pieces",
                "250g pasta (any shape works)",
                "2 bell peppers, sliced",
                "1 medium onion, diced",
                "2 tomatoes, diced",
                "100g cheese, grated",
                "2 tbsp olive oil",
                "2 cloves garlic, minced",
                "Salt and pepper to taste"
            ],
            instructions: [
                "Boil pasta according to package instructions until al dente. Drain and set aside.",
                "Season chicken with salt and pepper. Heat olive oil in a large pan and cook chicken for 5-6 minutes until no longer pink.",
                "Add onions and garlic, cook for 2 minutes until fragrant.",
                "Add bell peppers and cook for 3-4 minutes until slightly softened.",
                "Add tomatoes and cook for another 2 minutes.",
                "Add cooked pasta and toss to combine. Sprinkle with cheese, give a final toss, and serve hot!"
            ]
        ),
        DemoRecipe(
            id: 2,
            title: "Quick Chicken Fajitas",
            cookTime: "20 min",
            servings: 3,
            match: "88%",
            ingredients: [
                "2 chicken breasts, sliced into strips",
                "2 bell peppers, sliced",
                "1 onion, sliced",
                "2 tbsp olive oil",
                "1 lime, juiced",
                "2 tsp fajita seasoning",
                "Salt and pepper to taste",
                "6 small tortillas",
                "Optional: sour cream, grated cheese"
            ],
            instructions: [
                "Heat oil in a large skillet over medium-high heat.",
                "Season chicken with half the fajita seasoning, salt, and pepper.",
                "Cook chicken for 5-6 minutes until golden and cooked through, then remove from pan.",
                "Add bell peppers and onions to the same pan, cook for 4-5 minutes until softened.",
                "Return chicken to the pan, add remaining seasoning and lime juice.",
                "Stir for 1-2 minutes until everything is well combined and heated through.",
                "Serve with warm tortillas and optional toppings."
            ]
        )
    ]
    
    var body: some View {
        ZStack {
            // Chat background
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Chat messages area
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Welcome message if no messages
                            if chatMessages.isEmpty {
                                welomeMessage
                            }
                            
                            // Display chat messages
                            ForEach(chatMessages) { message in
                                ChatMessageView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    }
                    .onChange(of: chatMessages.count) { _ in
                        // Scroll to the latest message
                        if let lastMessage = chatMessages.last {
                            withAnimation {
                                scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    // Add tap gesture to dismiss keyboard when tapping in the scroll view
                    .onTapGesture {
                        dismissKeyboard()
                    }
                }
                .environment(\.quickReplyHandler, handleQuickReply)
                .environment(\.recipeSelectionHandler, showRecipeDetails)
                
                // Input area
                chatInputView
            }
            
            // Camera overlay
            if showCamera {
                cameraView
            }
            
            // Camera flash effect
            if showFlash {
                Color.white
                    .ignoresSafeArea()
                    .opacity(0.8)
                    .transition(.opacity)
            }
        }
        .navigationTitle("AI Chef Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.3), value: showCamera)
        .onAppear {
            // Add welcome message if there are no messages
            if chatMessages.isEmpty {
                addInitialMessages()
            }
        }
        // Add a background tap gesture that covers the whole view
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
    }
    
    // Helper function to dismiss keyboard
    private func dismissKeyboard() {
        isInputFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Welcome message view
    private var welomeMessage: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hi there! I'm your AI Chef Assistant.")
                .font(.headline)
                .foregroundColor(AppTheme.primaryDark)
            
            Text("I can help you find recipes based on what's in your fridge. Just tap the camera button to take a picture!")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.backgroundGreen.opacity(0.2))
        )
    }
    
    // Chat input view
    private var chatInputView: some View {
        HStack(spacing: 12) {
            // Camera button
            Button(action: {
                dismissKeyboard()
                showCamera = true
            }) {
                Image(systemName: "camera")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.primary)
                    .clipShape(Circle())
            }
            
            // Text input field
            TextField("Type a message...", text: $inputText)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(24)
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit {
                    if !inputText.isEmpty {
                        sendUserMessage(inputText)
                        inputText = ""
                    }
                }
            
            // Send button
            Button(action: {
                if !inputText.isEmpty {
                    sendUserMessage(inputText)
                    inputText = ""
                }
            }) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        AppTheme.primary.opacity(inputText.isEmpty ? 0.5 : 1.0)
                    )
                    .clipShape(Circle())
            }
            .disabled(inputText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.shadowColor, radius: 5, x: 0, y: -2)
        )
    }
    
    // Camera view
    private var cameraView: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Text("Take a photo of your fridge")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        showCamera = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                // Camera frame guide
                ZStack {
                    // Dashed border guide
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(style: StrokeStyle(lineWidth: 3, dash: [10]))
                        .foregroundColor(AppTheme.primary)
                        .padding(.horizontal, 50)
                    
                    // Instruction text
                    Text("Position your open fridge or pantry in the frame")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // Shutter button
                Button(action: {
                    capturePhoto()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 5)
                                .frame(width: 80, height: 80)
                        )
                }
                .padding(.bottom, 30)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    // MARK: - Actions
    
    // Add initial welcome messages
    private func addInitialMessages() {
        let welcome = ChatMessage(id: UUID(), text: "Hi there! I'm your AI Chef Assistant. I can help you find recipes based on what's in your fridge. Just tap the camera button to take a picture!", type: .assistant, extraContent: nil)
        chatMessages.append(welcome)
    }
    
    // Process user sending a text message
    private func sendUserMessage(_ text: String) {
        // Don't allow new messages while processing
        if isChatBusy {
            return
        }
        
        // Dismiss keyboard
        dismissKeyboard()
        
        let userMessage = ChatMessage(id: UUID(), text: text, type: .user, extraContent: nil)
        chatMessages.append(userMessage)
        
        isChatBusy = true
        
        // Simple flow for the demo - responding to "What can you help me with?"
        if text.lowercased().contains("what can you") || text.lowercased().contains("help") {
            respondToHelpQuery()
        } else {
            // Show typing indicator
            addTypingIndicator()
            
            // Generic response
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Remove typing indicator
                if self.chatMessages.last?.isTypingIndicator == true {
                    self.chatMessages.removeLast()
                }
                
                let response = ChatMessage(
                    id: UUID(),
                    text: "To get recipe suggestions, please take a photo of your fridge or pantry using the camera button.",
                    type: .assistant,
                    extraContent: ChatQuickReplies(replies: [
                        QuickReply(text: "📷 Take a photo", action: "take_photo")
                    ])
                )
                chatMessages.append(response)
                self.isChatBusy = false
            }
        }
    }
    
    // Respond to help query
    private func respondToHelpQuery() {
        // Show typing indicator
        addTypingIndicator()
        
        // Respond after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Remove typing indicator
            if self.chatMessages.last?.isTypingIndicator == true {
                self.chatMessages.removeLast()
            }
            
            // Add response with capabilities
            let response = ChatMessage(
                id: UUID(),
                text: "I can help you:\n\n• Find recipes using ingredients you already have\n• Suggest meals based on a photo of your fridge\n• Provide step-by-step cooking instructions\n• Answer cooking questions\n\nWould you like to snap a photo of your fridge to see what you can make?",
                type: .assistant,
                extraContent: ChatQuickReplies(replies: [
                    QuickReply(text: "📷 Take a photo", action: "take_photo"),
                    QuickReply(text: "🔍 Search recipes", action: "search_recipes"),
                    QuickReply(text: "❓ Ask cooking question", action: "ask_question")
                ])
            )
            
            self.chatMessages.append(response)
            self.isChatBusy = false
        }
    }
    
    // Show typing indicator
    private func addTypingIndicator() {
        let typingIndicator = ChatMessage(id: UUID(), text: "", type: .typingIndicator, extraContent: nil)
        chatMessages.append(typingIndicator)
    }
    
    // Capture a photo from the camera view
    private func capturePhoto() {
        // Dismiss keyboard if open
        dismissKeyboard()
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Prevent multiple photo captures while processing
        if isChatBusy {
            return
        }
        
        isChatBusy = true
        
        // Add flash effect
        withAnimation(.easeInOut(duration: 0.1)) {
            showFlash = true
        }
        
        // Close the camera view after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                showFlash = false
                showCamera = false
            }
            
            // Add user message with photo
            let photoMessage = ChatMessage(
                id: UUID(),
                text: "Here's a photo of my fridge",
                type: .user,
                extraContent: ChatPhoto(isProcessing: true)
            )
            chatMessages.append(photoMessage)
            
            // Show typing indicator
            addTypingIndicator()
            
            // Process the "photo" and respond after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                // Remove typing indicator
                if self.chatMessages.last?.isTypingIndicator == true {
                    self.chatMessages.removeLast()
                }
                
                // Update the photo to show it's been processed
                if let index = self.chatMessages.firstIndex(where: { $0.id == photoMessage.id }) {
                    self.chatMessages[index] = ChatMessage(
                        id: photoMessage.id,
                        text: photoMessage.text,
                        type: photoMessage.type,
                        extraContent: ChatPhoto(isProcessing: false)
                    )
                }
                
                // Format ingredient list with a more conversational tone
                let ingredientComments = [
                    "I notice you have some fresh chicken breast - perfect for a quick dinner!",
                    "Those colorful bell peppers will add great flavor to your dishes.",
                    "The onions and tomatoes will give a nice base for many recipes."
                ]
                let randomComment = ingredientComments.randomElement() ?? ""
                
                let ingredientsList = self.detectedIngredients.map { "• \($0)" }.joined(separator: "\n")
                
                // Respond with detected ingredients and recipe suggestions
                let responseMessage = ChatMessage(
                    id: UUID(),
                    text: "I can see several ingredients in your fridge! \(randomComment)\n\nI spotted:\n\n\(ingredientsList)\n\nHere are two delicious recipes you can make with these ingredients:",
                    type: .assistant,
                    extraContent: ChatRecipeCards(recipes: self.recipes)
                )
                
                self.chatMessages.append(responseMessage)
                self.isChatBusy = false
            }
        }
    }
    
    // Handle quick reply selection
    private func handleQuickReply(_ action: String) {
        // Dismiss keyboard if open
        dismissKeyboard()
        
        // Don't process if already busy
        if isChatBusy {
            return
        }
        
        isChatBusy = true
        
        // Add user message that shows what they selected
        var userMessage: String
        
        switch action {
        case "take_photo":
            userMessage = "I want to take a photo"
            let message = ChatMessage(
                id: UUID(),
                text: userMessage,
                type: .user,
                extraContent: nil
            )
            chatMessages.append(message)
            
            // Show response with typing indicator
            addTypingIndicator()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Remove typing indicator
                if self.chatMessages.last?.isTypingIndicator == true {
                    self.chatMessages.removeLast()
                }
                
                let response = ChatMessage(
                    id: UUID(),
                    text: "Great! I'll help you find recipes based on what's in your fridge. Please take a photo now.",
                    type: .assistant,
                    extraContent: nil
                )
                self.chatMessages.append(response)
                self.isChatBusy = false
                
                // Show camera after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showCamera = true
                }
            }
            
        case "search_recipes":
            userMessage = "I want to search for recipes"
            let message = ChatMessage(
                id: UUID(),
                text: userMessage,
                type: .user,
                extraContent: nil
            )
            chatMessages.append(message)
            
            // Show typing indicator
            addTypingIndicator()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Remove typing indicator
                if self.chatMessages.last?.isTypingIndicator == true {
                    self.chatMessages.removeLast()
                }
                
                let response = ChatMessage(
                    id: UUID(),
                    text: "Sure, what ingredients would you like to search for?",
                    type: .assistant,
                    extraContent: nil
                )
                self.chatMessages.append(response)
                self.isChatBusy = false
                
                // Focus on the text input
                self.isInputFocused = true
            }
            
        case "ask_question":
            userMessage = "I have a cooking question"
            let message = ChatMessage(
                id: UUID(),
                text: userMessage,
                type: .user,
                extraContent: nil
            )
            chatMessages.append(message)
            
            // Show typing indicator
            addTypingIndicator()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Remove typing indicator
                if self.chatMessages.last?.isTypingIndicator == true {
                    self.chatMessages.removeLast()
                }
                
                let response = ChatMessage(
                    id: UUID(),
                    text: "Of course! What cooking question do you have?",
                    type: .assistant,
                    extraContent: nil
                )
                self.chatMessages.append(response)
                self.isChatBusy = false
                
                // Focus on the text input
                self.isInputFocused = true
            }
            
        case "view_recipe":
            if let recipe = recipes.first {
                showRecipeDetails(recipe)
            }
            
        case "add_to_list":
            userMessage = "Add ingredients to my shopping list"
            let message = ChatMessage(
                id: UUID(),
                text: userMessage,
                type: .user,
                extraContent: nil
            )
            chatMessages.append(message)
            
            // Show typing indicator
            addTypingIndicator()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Remove typing indicator
                if self.chatMessages.last?.isTypingIndicator == true {
                    self.chatMessages.removeLast()
                }
                
                let response = ChatMessage(
                    id: UUID(),
                    text: "I've added the ingredients to your shopping list! You can view them in the List tab.",
                    type: .assistant,
                    extraContent: nil
                )
                self.chatMessages.append(response)
                self.isChatBusy = false
            }
            
        case "other_recipe":
            if let recipe = recipes.last {
                showRecipeDetails(recipe)
            }
            
        case "modify_recipe":
            userMessage = "Can I modify this recipe?"
            let message = ChatMessage(
                id: UUID(),
                text: userMessage,
                type: .user,
                extraContent: nil
            )
            chatMessages.append(message)
            
            // Show typing indicator
            addTypingIndicator()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Remove typing indicator
                if self.chatMessages.last?.isTypingIndicator == true {
                    self.chatMessages.removeLast()
                }
                
                let response = ChatMessage(
                    id: UUID(),
                    text: "Absolutely! What would you like to change in this recipe? You can substitute ingredients, adjust quantities, or change cooking methods.",
                    type: .assistant,
                    extraContent: nil
                )
                self.chatMessages.append(response)
                self.isChatBusy = false
                
                // Focus on the text input
                self.isInputFocused = true
            }
            
        default:
            isChatBusy = false
            break
        }
    }
    
    // Show recipe details
    private func showRecipeDetails(_ recipe: DemoRecipe) {
        // Don't process if already busy
        if isChatBusy {
            return
        }
        
        isChatBusy = true
        
        // Add user message
        let userMessage = ChatMessage(
            id: UUID(),
            text: "Show me the \(recipe.title) recipe",
            type: .user,
            extraContent: nil
        )
        chatMessages.append(userMessage)
        
        // Show typing indicator
        addTypingIndicator()
        
        // Show recipe details after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Remove typing indicator
            if self.chatMessages.last?.isTypingIndicator == true {
                self.chatMessages.removeLast()
            }
            
            // Format ingredients and instructions
            let formattedIngredients = recipe.ingredients.map { "• \($0)" }.joined(separator: "\n")
            let formattedInstructions = recipe.instructions.enumerated().map { index, step in
                "\(index + 1). \(step)"
            }.joined(separator: "\n\n")
            
            // Add recipe details message
            let recipeDetails = ChatMessage(
                id: UUID(),
                text: "**\(recipe.title)**\n\n**Ingredients:**\n\(formattedIngredients)\n\n**Instructions:**\n\(formattedInstructions)",
                type: .assistant,
                extraContent: ChatQuickReplies(replies: [
                    QuickReply(text: "Add ingredients to list", action: "add_to_list"),
                    QuickReply(text: "See other recipe", action: "other_recipe"),
                    QuickReply(text: "Modify recipe", action: "modify_recipe")
                ])
            )
            
            self.chatMessages.append(recipeDetails)
            self.isChatBusy = false
        }
    }
}

// MARK: - Supporting Types

// Recipe model for demo
struct DemoRecipe: Identifiable {
    let id: Int
    let title: String
    let cookTime: String
    let servings: Int
    let match: String
    let ingredients: [String]
    let instructions: [String]
}

// Chat message model
struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let type: ChatMessageType
    let extraContent: ChatExtraContent?
    
    var isTypingIndicator: Bool {
        return type == .typingIndicator
    }
}

// Chat message types
enum ChatMessageType {
    case user
    case assistant
    case typingIndicator
}

// Protocol for different types of extra content
protocol ChatExtraContent {}

// Photo content
struct ChatPhoto: ChatExtraContent {
    var isProcessing: Bool = false
}

// Recipe cards content
struct ChatRecipeCards: ChatExtraContent {
    let recipes: [DemoRecipe]
}

// Quick replies content
struct ChatQuickReplies: ChatExtraContent {
    let replies: [QuickReply]
}

// Quick reply model
struct QuickReply: Identifiable {
    let id = UUID()
    let text: String
    let action: String
}

// Environment key for quick reply handler
struct QuickReplyHandlerKey: EnvironmentKey {
    static let defaultValue: (String) -> Void = { _ in }
}

// Environment key for recipe selection handler
struct RecipeSelectionHandlerKey: EnvironmentKey {
    static let defaultValue: (DemoRecipe) -> Void = { _ in }
}

// Environment extension
extension EnvironmentValues {
    var quickReplyHandler: (String) -> Void {
        get { self[QuickReplyHandlerKey.self] }
        set { self[QuickReplyHandlerKey.self] = newValue }
    }
    
    var recipeSelectionHandler: (DemoRecipe) -> Void {
        get { self[RecipeSelectionHandlerKey.self] }
        set { self[RecipeSelectionHandlerKey.self] = newValue }
    }
}

// MARK: - Supporting Views

// Chat message view
struct ChatMessageView: View {
    let message: ChatMessage
    @Environment(\.quickReplyHandler) private var quickReplyHandler
    @Environment(\.recipeSelectionHandler) private var recipeSelectionHandler
    
    var body: some View {
        VStack(alignment: message.type == .user ? .trailing : .leading, spacing: 8) {
            if message.type == .typingIndicator {
                TypingIndicator()
                    .padding(.leading, 16)
            } else {
                // Message bubble
                messageBubble
                
                // Extra content below the message
                if let extraContent = message.extraContent {
                    if let photo = extraContent as? ChatPhoto {
                        photoView(photo)
                    } else if let recipeCards = extraContent as? ChatRecipeCards {
                        recipeCardsView(recipeCards.recipes)
                    } else if let quickReplies = extraContent as? ChatQuickReplies {
                        quickRepliesView(quickReplies.replies)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.type == .user ? .trailing : .leading)
    }
    
    // Message bubble view
    private var messageBubble: some View {
        Text(LocalizedStringKey(message.text))
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                message.type == .user ? AppTheme.primary : AppTheme.cardBackground
            )
            .foregroundColor(message.type == .user ? .white : AppTheme.text)
            .cornerRadius(18)
            .cornerRadius(message.type == .user ? 4 : 18, corner: message.type == .user ? .bottomRight : .bottomLeft)
    }
    
    // Photo view for camera capture
    private func photoView(_ photo: ChatPhoto) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(width: 250, height: 180)
            
            if photo.isProcessing {
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                    
                    Text("Analyzing ingredients...")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
            } else {
                Text("Fridge Photo")
                    .foregroundColor(Color(.systemGray))
                    .italic()
            }
        }
        .padding(.top, 8)
        .transition(.opacity)
    }
    
    // Recipe cards view
    private func recipeCardsView(_ recipes: [DemoRecipe]) -> some View {
        VStack(spacing: 16) {
            ForEach(recipes) { recipe in
                recipeCard(recipe)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(.top, 8)
    }
    
    // Individual recipe card
    private func recipeCard(_ recipe: DemoRecipe) -> some View {
        Button(action: {
            // Make the entire card tappable to show recipe details
            recipeSelectionHandler(recipe)
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Recipe image placeholder
                ZStack {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 140)
                    
                    Text("Recipe Photo")
                        .foregroundColor(Color(.systemGray))
                        .italic()
                }
                
                // Recipe details
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title)
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                    
                    // Recipe metadata
                    HStack(spacing: 12) {
                        Label(recipe.cookTime, systemImage: "clock")
                        Label("\(recipe.servings) servings", systemImage: "person.2")
                        Label(recipe.match, systemImage: "checkmark.circle")
                    }
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    
                    // View recipe button
                    Button(action: {
                        // Connect to show recipe details
                        recipeSelectionHandler(recipe)
                    }) {
                        Text("View Recipe")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppTheme.primary)
                            .cornerRadius(8)
                    }
                    .padding(.top, 4)
                }
                .padding(12)
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
            .frame(width: 300)
            .shadow(color: AppTheme.shadowColor, radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle()) // Prevents button styling on the outer button
    }
    
    // Quick replies view
    private func quickRepliesView(_ replies: [QuickReply]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(replies) { reply in
                    Button(action: {
                        // Connect to handleQuickReply function
                        quickReplyHandler(reply.action)
                    }) {
                        Text(reply.text)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(AppTheme.backgroundGreen.opacity(0.3))
                            )
                            .foregroundColor(AppTheme.primaryDark)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

// Typing indicator view
struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(AppTheme.textSecondary)
                    .frame(width: 8, height: 8)
                    .offset(y: animationOffset(for: index))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .cornerRadius(18)
        .cornerRadius(4, corner: .bottomLeft)
        .onAppear {
            // Improved bouncy animation
            withAnimation(Animation.easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true)) {
                animationOffset = 5
            }
        }
    }
    
    private func animationOffset(for index: Int) -> CGFloat {
        let delay = Double(index) * 0.2
        return sin(animationOffset + CGFloat(delay)) * 5
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corner: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corner))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(recipeListViewModel: RecipeListViewModel())
            .preferredColorScheme(.dark)
    }
} 
