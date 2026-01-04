import Foundation
import SwiftData

struct RequirementService {
    
    // MARK: - Check if user can redeem rewards
    
    static func canRedeemRewards(modelContext: ModelContext) async -> RedemptionResult {
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        guard let settings = try? modelContext.fetch(settingsDescriptor).first else {
            return RedemptionResult(allowed: true, reason: nil, progress: nil)
        }
        
        var blockedReasons: [String] = []
        var progressInfo: [String: String] = [:]
        
        // Check LeetCode requirement
        if settings.leetcodeEnabled && settings.leetcodeBlocksRewards {
            let progress = await checkLeetCodeProgress(settings: settings, modelContext: modelContext)
            
            if progress.current < progress.goal {
                let remaining = progress.goal - progress.current
                blockedReasons.append("Complete \(remaining) more LeetCode problem\(remaining == 1 ? "" : "s")")
                progressInfo["LeetCode"] = "\(progress.current)/\(progress.goal) problems"
            } else {
                progressInfo["LeetCode"] = "✓ \(progress.current)/\(progress.goal) problems"
            }
        }
        
        // Check Anki requirement
        if settings.ankiEnabled && settings.ankiBlocksRewards {
            let progress = await checkAnkiProgress(settings: settings, modelContext: modelContext)
            
            if progress.current < progress.goal {
                let remaining = progress.goal - progress.current
                blockedReasons.append("Review \(remaining) more Anki card\(remaining == 1 ? "" : "s")")
                progressInfo["Anki"] = "\(progress.current)/\(progress.goal) cards"
            } else {
                progressInfo["Anki"] = "✓ \(progress.current)/\(progress.goal) cards"
            }
        }
        
        if blockedReasons.isEmpty {
            return RedemptionResult(
                allowed: true,
                reason: nil,
                progress: progressInfo.isEmpty ? nil : progressInfo
            )
        } else {
            return RedemptionResult(
                allowed: false,
                reason: blockedReasons.joined(separator: "\n"),
                progress: progressInfo
            )
        }
    }
    
    // MARK: - LeetCode Progress
    
    static func checkLeetCodeProgress(settings: AppSettings, modelContext: ModelContext) async -> ProgressStatus {
        guard !settings.leetcodeUsername.isEmpty else {
            return ProgressStatus(current: 0, goal: settings.leetcodeDailyGoal, verified: false)
        }
        
        // Get or create today's progress
        let today = DailyProgress.normalizeToDay(Date())
        let progressDescriptor = FetchDescriptor<DailyProgress>(
            predicate: #Predicate<DailyProgress> { progress in
                progress.date == today
            }
        )
        
        var todayProgress: DailyProgress
        if let existing = try? modelContext.fetch(progressDescriptor).first {
            todayProgress = existing
        } else {
            todayProgress = DailyProgress(date: today)
            modelContext.insert(todayProgress)
        }
        
        // Check if we need to refresh from API (cache for 5 minutes)
        let needsRefresh = todayProgress.lastUpdated.timeIntervalSinceNow < -300 || !todayProgress.leetcodeProblemsVerified
        
        if needsRefresh {
            let result = await LeetCodeService.fetchDailyProgress(username: settings.leetcodeUsername)
            
            if result.verified {
                todayProgress.leetcodeProblems = result.problemCount
                todayProgress.leetcodeProblemsVerified = true
                todayProgress.lastUpdated = Date()
                settings.leetcodeLastChecked = Date()
                try? modelContext.save()
            }
        }
        
        return ProgressStatus(
            current: todayProgress.leetcodeProblems,
            goal: settings.leetcodeDailyGoal,
            verified: todayProgress.leetcodeProblemsVerified
        )
    }
    
    // MARK: - Anki Progress
    
    static func checkAnkiProgress(settings: AppSettings, modelContext: ModelContext) async -> ProgressStatus {
        // Get or create today's progress
        let today = DailyProgress.normalizeToDay(Date())
        let progressDescriptor = FetchDescriptor<DailyProgress>(
            predicate: #Predicate<DailyProgress> { progress in
                progress.date == today
            }
        )
        
        var todayProgress: DailyProgress
        if let existing = try? modelContext.fetch(progressDescriptor).first {
            todayProgress = existing
        } else {
            todayProgress = DailyProgress(date: today)
            modelContext.insert(todayProgress)
        }
        
        // If link code is set, try to refresh from Firebase
        if !settings.ankiLinkCode.isEmpty {
            let needsRefresh = todayProgress.lastUpdated.timeIntervalSinceNow < -300 || !todayProgress.ankiCardsVerified
            
            if needsRefresh {
                let result = await AnkiService.fetchFromFirebase(linkCode: settings.ankiLinkCode)
                
                if result.verified {
                    todayProgress.ankiCards = result.cardCount
                    todayProgress.ankiCardsVerified = true
                    todayProgress.lastUpdated = Date()
                    try? modelContext.save()
                }
            }
        }
        
        return ProgressStatus(
            current: todayProgress.ankiCards,
            goal: settings.ankiDailyGoal,
            verified: todayProgress.ankiCardsVerified
        )
    }
    
    // MARK: - Manual Refresh
    
    static func refreshLeetCodeProgress(modelContext: ModelContext) async -> ProgressStatus {
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        guard let settings = try? modelContext.fetch(settingsDescriptor).first else {
            return ProgressStatus(current: 0, goal: 3, verified: false)
        }
        
        return await checkLeetCodeProgress(settings: settings, modelContext: modelContext)
    }
    
    static func refreshAnkiProgress(modelContext: ModelContext) async -> ProgressStatus {
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        guard let settings = try? modelContext.fetch(settingsDescriptor).first else {
            return ProgressStatus(current: 0, goal: 50, verified: false)
        }
        
        return await checkAnkiProgress(settings: settings, modelContext: modelContext)
    }
}

// MARK: - Supporting Types

struct RedemptionResult {
    let allowed: Bool
    let reason: String?
    let progress: [String: String]?
}

struct ProgressStatus {
    let current: Int
    let goal: Int
    let verified: Bool
    
    var isComplete: Bool {
        return current >= goal
    }
    
    var remaining: Int {
        return max(0, goal - current)
    }
}
