import Foundation
import SwiftData

class ProgressService {
    
    static func updateDailyProgress(
        username: String,
        modelContext: ModelContext
    ) async throws -> DailyProgress {
        let result = try await LeetCodeService.fetchDailyProgress(username: username)
        
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyProgress>(
            predicate: #Predicate { progress in
                progress.date == today
            }
        )
        
        let existingProgress = try? modelContext.fetch(descriptor).first
        
        if let existing = existingProgress {
            existing.problemsSolved = result.problemCount
            existing.isVerified = result.verified
            existing.submissions = result.uniqueProblemSlugs
            existing.lastUpdated = Date()
            return existing
        } else {
            let newProgress = DailyProgress(
                date: today,
                problemsSolved: result.problemCount,
                isVerified: result.verified,
                submissions: result.uniqueProblemSlugs
            )
            modelContext.insert(newProgress)
            return newProgress
        }
    }
    
    static func checkGoalCompletion(
        progress: DailyProgress,
        goal: Int
    ) -> Bool {
        return progress.problemsSolved >= goal
    }
    
    static func updateStreakIfNeeded(
        goalMet: Bool,
        modelContext: ModelContext
    ) {
        let descriptor = FetchDescriptor<StreakData>()
        
        if let streak = try? modelContext.fetch(descriptor).first {
            streak.updateStreak(completed: goalMet)
        } else {
            let newStreak = StreakData()
            newStreak.updateStreak(completed: goalMet)
            modelContext.insert(newStreak)
        }
        
        try? modelContext.save()
    }
    
    static func shouldApplyShields(
        settings: UserSettings,
        progress: DailyProgress
    ) -> Bool {
        guard settings.isActiveToday() else { return false }
        
        return progress.problemsSolved < settings.dailyProblemGoal
    }
}
