import SwiftUI

/// A standard header for displaying a day in the meal plan calendar
/// - Follows Apple HIG with minimum 44x44 touch targets
/// - Includes proper animation states for selection changes
struct DayHeaderView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    // Standard date formatters
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private let accessibilityDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 8) {
            // Day name (Mon, Tue, etc)
            Text(weekdayFormatter.string(from: date))
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? AppTheme.primary : AppTheme.secondaryText)
            
            // Date bubble
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 44, height: 44)  // Apple's minimum touch target size
                
                Text(dayFormatter.string(from: date))
                    .font(.headline)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(textColor)
            }
            .overlay(
                Circle()
                    .strokeBorder(isToday ? AppTheme.primary : Color.clear, lineWidth: 2)
            )
            
            // Selection indicator
            Circle()
                .fill(isSelected ? AppTheme.primary : Color.clear)
                .frame(width: 8, height: 8)
                .scaleEffect(isSelected ? 1 : 0.01)
                .opacity(isSelected ? 1 : 0)
                .animation(.spring(response: 0.3), value: isSelected)
        }
        .frame(width: 60, height: 80)
        .contentShape(Rectangle())  // Make entire area tappable
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityAddTraits(isToday ? [.isButton] : [.isButton])
    }
    
    // MARK: - Helper Properties
    
    private var backgroundColor: Color {
        if isSelected {
            return AppTheme.secondary.opacity(0.15)
        }
        return Color.clear
    }
    
    private var textColor: Color {
        if isSelected {
            return AppTheme.primary
        }
        return AppTheme.text
    }
    
    private var accessibilityLabel: String {
        let base = accessibilityDateFormatter.string(from: date)
        let modifiers = [
            isToday ? "Today" : nil,
            isSelected ? "Selected" : nil
        ].compactMap { $0 }
        
        if modifiers.isEmpty {
            return base
        }
        
        return base + ", " + modifiers.joined(separator: ", ")
    }
}

#Preview {
    HStack(spacing: 4) {
        DayHeaderView(
            date: Date(), 
            isSelected: true, 
            isToday: true, 
            onTap: {}
        )
        
        DayHeaderView(
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, 
            isSelected: false, 
            isToday: false, 
            onTap: {}
        )
        
        DayHeaderView(
            date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, 
            isSelected: false, 
            isToday: false, 
            onTap: {}
        )
    }
    .padding()
    .background(AppTheme.background)
} 