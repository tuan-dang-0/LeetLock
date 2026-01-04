import Foundation
import SwiftData

@Model
final class StreakData {
    var id: UUID
    var currentStreak: Int
    var longestStreak: Int
    var lastCompletionDate: Date?
    var totalDaysCompleted: Int
    var submissionHistory: [Date]
    
    init(
        id: UUID = UUID(),
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastCompletionDate: Date? = nil,
        totalDaysCompleted: Int = 0,
        submissionHistory: [Date] = []
    ) {
        self.id = id
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastCompletionDate = lastCompletionDate
        self.totalDaysCompleted = totalDaysCompleted
        self.submissionHistory = submissionHistory
    }
    
    func updateStreak(completed: Bool) {
        let today = Calendar.current.startOfDay(for: Date())
        
        if completed {
            if let lastDate = lastCompletionDate {
                let lastDay = Calendar.current.startOfDay(for: lastDate)
                let daysDifference = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
                
                if daysDifference == 1 {
                    currentStreak += 1
                } else if daysDifference > 1 {
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            
            lastCompletionDate = today
            totalDaysCompleted += 1
            
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
            
            if !submissionHistory.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                submissionHistory.append(today)
            }
        }
    }
}
