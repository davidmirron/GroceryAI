import SwiftUI

// MARK: - Array Extensions

extension Array {
    /// Split an array into chunks of a specified size
    /// - Parameter size: The maximum size for each chunk
    /// - Returns: An array of array chunks
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0, !isEmpty else { return [self] }
        
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// Other extensions can be added here as needed 