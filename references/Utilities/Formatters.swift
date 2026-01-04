import Foundation

struct Formatters {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static func formatTimeRange(start: Date, end: Date) -> String {
        let startStr = timeFormatter.string(from: start)
        let endStr = timeFormatter.string(from: end)
        return "\(startStr) – \(endStr)"
    }
    
    static func formatPercent(_ value: Double) -> String {
        let percentValue = Int(value * 100)
        return "\(percentValue)%"
    }
}
