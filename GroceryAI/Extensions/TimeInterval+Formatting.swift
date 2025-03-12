import Foundation

extension TimeInterval {
    /// Formats a time interval (in seconds) to a human-readable string (e.g., "30m", "1h 15m", "2h")
    func formattedDuration() -> String {
        let minutes = Int(self / 60)
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes == 0 ? "\(hours)h" : "\(hours)h \(remainingMinutes)m"
        }
    }
} 