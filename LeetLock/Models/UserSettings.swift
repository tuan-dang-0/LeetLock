import Foundation
import SwiftData

@Model
final class UserSettings {
    var id: UUID
    var leetcodeUsername: String
    var isUsernameVerified: Bool
    var dailyProblemGoal: Int
    var activeDays: Set<Int>
    var hasCompletedOnboarding: Bool
    var createdAt: Date
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        leetcodeUsername: String = "",
        isUsernameVerified: Bool = false,
        dailyProblemGoal: Int = 1,
        activeDays: Set<Int> = Set([1, 2, 3, 4, 5, 6, 7]),
        hasCompletedOnboarding: Bool = false,
        createdAt: Date = Date(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.leetcodeUsername = leetcodeUsername
        self.isUsernameVerified = isUsernameVerified
        self.dailyProblemGoal = dailyProblemGoal
        self.activeDays = activeDays
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = createdAt
        self.lastUpdated = lastUpdated
    }
    
    func isActiveToday() -> Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return activeDays.contains(weekday)
    }
}
