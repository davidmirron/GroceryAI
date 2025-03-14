import SwiftUI
import UIKit

// MARK: - Shared Formatters
// These formatters are used across the entire file to improve performance
private let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E"
    return formatter
}()

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter
}()

private let dayOfWeekFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE" // Full day name
    return formatter
}()

private let shortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter
}()

private let fullDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

private let accessibilityDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
}()

// MARK: - Time Formatting
extension TimeInterval {
    var formattedTimeString: String {
        let minutes = Int(self) / 60
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours) hr \(remainingMinutes) min"
            }
        }
    }
}

// MARK: - Recipe Helper Extensions
extension Recipe {
    var estimatedTimeString: String {
        // Use prepTime directly which is already in seconds
        return prepTime.formattedTimeString
    }
    
    var difficultyText: String {
        return difficulty.rawValue
    }
}

/// Main view for the meal planning feature
/// - Simplified component hierarchy
/// - Consistent visual language
/// - Optimized rendering with minimal state
/// - Proper animations for state changes
struct MealPlanView: View {
    // Local or injected ViewModel
    @StateObject private var localViewModel = MealPlanViewModel()
    
    // Environment object for when used within MainTabView
    @EnvironmentObject private var envViewModel: MealPlanViewModel
    
    // Computed property to use the appropriate view model
    private var viewModel: MealPlanViewModel {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            // In preview, use the local view model
            return localViewModel
            } else {
            // In the app, check for environment
            return environmentObjectAvailable ? envViewModel : localViewModel
        }
    }
    
    // Detect if the environment object is available
    @State private var environmentObjectAvailable = false
    
    @State private var selectedDate = Date()
    @State private var weekStartDate: Date = {
        let date = Date()
        // Use explicit method from MealPlanViewModel's extension
        return date.startOfWeek()
    }()
    @State private var isPerformingQuickFill = false
    @State private var showingActionFeedback = false
    @State private var actionFeedbackText = ""
    @State private var selectionKey = UUID() // For preserving selection state
    
    // Initialize the view model with a shopping list view model
    init(shoppingListViewModel: ShoppingListViewModel? = nil) {
        if let shoppingListVM = shoppingListViewModel {
            self._localViewModel = StateObject(wrappedValue: MealPlanViewModel(shoppingListViewModel: shoppingListVM))
        }
    }
    
    // Get the user's calendar
    private var calendar: Calendar {
        // Use the user's calendar settings with their first day of week preference
        var calendar = Calendar.current
        return calendar
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Week Navigation Header
                    weekNavigationHeader
                        .background(
                            Rectangle()
                                .fill(AppTheme.cardBackground)
                                .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
                        )
                    
                    // MARK: - Day Selection
                    weekdaySelectionView
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                        .background(AppTheme.cardBackground)
                    
                    // MARK: - Actions Bar
                    actionsBar
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    
                    // MARK: - Meal Plan Content
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(MealType.allCases, id: \.self) { mealType in
                                MealTimeSectionView(
                                    mealType: mealType,
                                    date: selectedDate,
                                    meals: viewModel.meals(for: selectedDate, type: mealType),
                                    viewModel: viewModel
                                )
                            }
                        }
                        .padding(16)
                        .id(selectionKey) // Helps preserve scroll position when switching dates
                        .animation(.spring(response: 0.3), value: selectedDate)
                    }
                    .background(AppTheme.background)
                }
                
                // Feedback toast
                if showingActionFeedback {
                    VStack {
                Spacer()
                        Text(actionFeedbackText)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.7))
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 32)
                    }
                    .transition(.opacity)
                    .zIndex(100)
                }
                
                // Loading overlay for quick fill
                if isPerformingQuickFill {
                    ZStack {
                        Color.black.opacity(0.2)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(AppTheme.primary)
                            
                            Text("Generating meal plan...")
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.cardBackground)
                                .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 4)
                        )
                    }
                    .transition(.opacity)
                }
            }
            .navigationTitle("Meal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Reset to today
                        withAnimation(.spring(response: 0.3)) {
                            selectedDate = Date()
                            let today = Date()
                            weekStartDate = today.startOfWeek()
                            selectionKey = UUID() // Reset scroll position
                        }
                    } label: {
                        Text("Today")
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .onAppear {
                // Check if environment object is available
                let mirror = Mirror(reflecting: self)
                environmentObjectAvailable = mirror.children.contains { child in
                    return child.label == "_envViewModel"
                }
                viewModel.loadData()
            }
            .overlay(alignment: .bottom) {
                // Shopping List Feedback Toast
                if let feedback = viewModel.shoppingListFeedback {
                    VStack {
                        Text(feedback.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(feedback.message)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppTheme.primary.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.3), value: viewModel.shoppingListFeedback != nil)
                }
            }
            // Save state when app moves to background
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                saveState()
            }
            // Restore state when app becomes active
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                restoreState()
            }
        }
    }
    
    // MARK: - Component Views
    
    private var weekNavigationHeader: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    weekStartDate = calendar.date(byAdding: .weekOfYear, value: -1, to: weekStartDate)!
                    // Select the first day of the new week
                    selectedDate = weekStartDate
                    selectionKey = UUID() // Reset scroll position for new week
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Previous week")
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("Week of")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
                
                Text(fullDateFormatter.string(from: weekStartDate))
                    .font(.headline)
                    .foregroundColor(AppTheme.text)
            }
                
                Spacer()
                
            Button {
                withAnimation(.spring(response: 0.3)) {
                    weekStartDate = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStartDate)!
                    // Select the first day of the new week
                    selectedDate = weekStartDate
                    selectionKey = UUID() // Reset scroll position for new week
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Next week")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
    
    private var weekdaySelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(getWeekDates(from: weekStartDate), id: \.self) { date in
                    DayHeaderView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        onTap: {
                            // Provide haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            
                            withAnimation(.spring(response: 0.3)) {
                                selectedDate = date
                                selectionKey = UUID() // Reset scroll position for new day
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        // Smoother transitions when navigating between weeks
        .id(weekStartDate)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: weekStartDate)
    }
    
    private var actionsBar: some View {
        HStack(spacing: 16) {
            Button {
                // Show the loading indicator
                withAnimation(.spring(response: 0.3)) {
                    isPerformingQuickFill = true
                }
                
                // Slight delay to allow animation to show
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Perform the quick fill
                    viewModel.quickFillWeek(for: selectedDate)
                    
                    // Provide haptic feedback
                    let impactGenerator = UINotificationFeedbackGenerator()
                    impactGenerator.notificationOccurred(.success)
                    
                    // Hide loading after a small delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation(.spring(response: 0.3)) {
                            isPerformingQuickFill = false
                            
                            // Show success toast
                            actionFeedbackText = "Weekly meal plan generated!"
                            showingActionFeedback = true
                            
                            // Hide toast after a delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showingActionFeedback = false
                                }
                            }
                        }
                    }
                }
            } label: {
                Label("Quick Fill", systemImage: "sparkles")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Capsule().fill(AppTheme.primary))
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 3, x: 0, y: 2)
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityLabel("Quick fill this week")
            
            Spacer()
            
            Button {
                let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
                impactGenerator.prepare()
                
                // Clear the selected day's meals
                withAnimation(.spring(response: 0.3)) {
                    viewModel.clearMeals(for: selectedDate)
                    impactGenerator.impactOccurred()
                    
                    // Show feedback toast
                    actionFeedbackText = "Meals cleared for \(shortDateFormatter.string(from: selectedDate))"
                    showingActionFeedback = true
                    
                    // Hide toast after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showingActionFeedback = false
                        }
                    }
                }
            } label: {
                Label("Clear Day", systemImage: "trash")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(AppTheme.destructive)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .stroke(AppTheme.destructive, lineWidth: 1.5)
                            .background(
                                Capsule()
                                    .fill(AppTheme.destructive.opacity(0.05))
                            )
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityLabel("Clear all meals for this day")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get dates for the week using the user's calendar settings
    private func getWeekDates(from startDate: Date) -> [Date] {
        var weekDates: [Date] = []
        
        for day in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: day, to: startDate) {
                weekDates.append(date)
            }
        }
        
        return weekDates
    }
    
    /// Save current state when app goes to background
    private func saveState() {
        // In a real app, you would save this to UserDefaults or other storage
        // For now, we'll rely on state being preserved in memory
    }
    
    /// Restore state when app returns from background
    private func restoreState() {
        // In a real app, you would restore from UserDefaults or other storage
        // For now, we'll rely on state being preserved in memory
    }
}

// MARK: - Preview
#Preview {
    // Create a ShoppingListViewModel for the preview
    let shoppingListViewModel = ShoppingListViewModel()
    
    return MealPlanView(shoppingListViewModel: shoppingListViewModel)
}
