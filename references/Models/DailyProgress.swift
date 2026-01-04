import Foundation
import SwiftData

@Model
final class DailyProgress {
    var id: UUID
    var date: Date
    var leetcodeProblems: Int
    var leetcodeProblemsVerified: Bool
    var ankiCards: Int
    var ankiCardsVerified: Bool
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        leetcodeProblems: Int = 0,
        leetcodeProblemsVerified: Bool = false,
        ankiCards: Int = 0,
        ankiCardsVerified: Bool = false,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.date = Self.normalizeToDay(date)
        self.leetcodeProblems = leetcodeProblems
        self.leetcodeProblemsVerified = leetcodeProblemsVerified
        self.ankiCards = ankiCards
        self.ankiCardsVerified = ankiCardsVerified
        self.lastUpdated = lastUpdated
    }
    
    // Helper to normalize date to midnight for consistent day tracking
    static func normalizeToDay(_ date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }
    
    func isToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
}
