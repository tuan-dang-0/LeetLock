import Foundation
import SwiftData

@Model
final class DailyProgress {
    var id: UUID
    var date: Date
    var problemsSolved: Int
    var isVerified: Bool
    var isGoalMet: Bool
    var lastUpdated: Date
    var submissions: [String]
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        problemsSolved: Int = 0,
        isVerified: Bool = false,
        isGoalMet: Bool = false,
        lastUpdated: Date = Date(),
        submissions: [String] = []
    ) {
        self.id = id
        self.date = Self.normalizeToDay(date)
        self.problemsSolved = problemsSolved
        self.isVerified = isVerified
        self.isGoalMet = isGoalMet
        self.lastUpdated = lastUpdated
        self.submissions = submissions
    }
    
    static func normalizeToDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    func isToday() -> Bool {
        Calendar.current.isDateInToday(date)
    }
}
