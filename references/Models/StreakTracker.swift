import Foundation
import SwiftData

@Model
final class StreakTracker {
    var id: UUID
    var currentStreak: Int
    var longestStreak: Int
    var lastCompletionDate: Date?
    var streakMilestones: [Int]
    
    init(
        id: UUID = UUID(),
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastCompletionDate: Date? = nil,
        streakMilestones: [Int] = [3, 7, 14, 30, 60, 90, 180, 365]
    ) {
        self.id = id
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastCompletionDate = lastCompletionDate
        self.streakMilestones = streakMilestones
    }
    
    var nextMilestone: Int? {
        streakMilestones.first { $0 > currentStreak }
    }
    
    func updateStreak(completedToday: Bool) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastDate = lastCompletionDate else {
            if completedToday {
                currentStreak = 1
                lastCompletionDate = today
                longestStreak = max(longestStreak, currentStreak)
            }
            return
        }
        
        let lastDay = calendar.startOfDay(for: lastDate)
        let daysSinceLastCompletion = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        if daysSinceLastCompletion == 0 {
            return
        } else if daysSinceLastCompletion == 1 && completedToday {
            currentStreak += 1
            lastCompletionDate = today
            longestStreak = max(longestStreak, currentStreak)
        } else if daysSinceLastCompletion > 1 {
            currentStreak = completedToday ? 1 : 0
            lastCompletionDate = completedToday ? today : nil
        }
    }
}
