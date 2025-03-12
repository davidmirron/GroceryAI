import SwiftUI
import Combine
import Foundation

/// View state management for MealPlanView to consolidate UI state
class MealPlanViewState: ObservableObject {
    // UI state properties
    @Published var selectedDate = Date()
    @Published var showAddMealSheet = false
    @Published var selectedMealType: MealType
    @Published var showWeeklySummary = false
    @Published var isShoppingButtonPressed = false
    
    // Toast notification state
    @Published var isShowingToast = false
    @Published var toastMessage = ""
    @Published var toastType: ToastType = .success
    
    // Initialize with contextually relevant meal type based on time of day
    init() {
        selectedMealType = Self.contextualMealType()
    }
    
    // Toast types for different notification styles
    enum ToastType {
        case success, warning, error
        
        var color: Color {
            switch self {
            case .success: return Color.green
            case .warning: return Color.orange
            case .error: return Color.red
            }
        }
    }
    
    // Timer for auto-dismissing toasts
    private var toastTimer: AnyCancellable?
    
    /// Shows a toast notification with the provided message and type
    func showToast(message: String, type: ToastType = .success, duration: TimeInterval = 2.5) {
        // Cancel any existing timer
        toastTimer?.cancel()
        
        // Update toast properties
        withAnimation {
            self.toastMessage = message
            self.toastType = type
            self.isShowingToast = true
        }
        
        // Set up timer to dismiss
        toastTimer = Timer.publish(every: duration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                withAnimation {
                    self?.isShowingToast = false
                }
                self?.toastTimer?.cancel()
            }
    }
    
    /// Select a specific date and optionally a meal type for adding
    func selectDate(_ date: Date, mealType: MealType? = nil) {
        withAnimation {
            self.selectedDate = date
        }
        
        if let mealType = mealType {
            self.selectedMealType = mealType
            self.showAddMealSheet = true
        }
    }
    
    /// Toggle the weekly summary view
    func toggleWeeklySummary() {
        withAnimation {
            showWeeklySummary.toggle()
        }
    }
    
    /// Determine the most appropriate meal type based on the current time of day
    static func contextualMealType() -> MealType {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<10:  // Early morning (midnight to 10am)
            return .breakfast
        case 10..<15: // Late morning to early afternoon (10am to 3pm)
            return .lunch
        case 15..<20: // Late afternoon to evening (3pm to 8pm)
            return .dinner
        default:      // Late evening (8pm to midnight)
            return .snack
        }
    }
    
    /// Select the most contextually relevant meal type based on time of day
    func selectContextualMealType() {
        selectedMealType = Self.contextualMealType()
    }
} 