import Foundation
import SwiftData

@Model
final class Achievement {
    var id: UUID
    var title: String
    var achievementDescription: String
    var iconName: String
    var category: AchievementCategory
    var requirement: Int
    var currentProgress: Int
    var isUnlocked: Bool
    var isClaimed: Bool
    var unlockedDate: Date?
    var rewardsData: Data?
    
    init(
        id: UUID = UUID(),
        title: String,
        achievementDescription: String,
        iconName: String,
        category: AchievementCategory,
        requirement: Int,
        currentProgress: Int = 0,
        isUnlocked: Bool = false,
        isClaimed: Bool = false,
        unlockedDate: Date? = nil,
        rewards: [AchievementReward] = []
    ) {
        self.id = id
        self.title = title
        self.achievementDescription = achievementDescription
        self.iconName = iconName
        self.category = category
        self.requirement = requirement
        self.currentProgress = currentProgress
        self.isUnlocked = isUnlocked
        self.isClaimed = isClaimed
        self.unlockedDate = unlockedDate
        self.rewardsData = try? JSONEncoder().encode(rewards)
    }
    
    var rewards: [AchievementReward] {
        get {
            guard let data = rewardsData else { return [] }
            return (try? JSONDecoder().decode([AchievementReward].self, from: data)) ?? []
        }
        set {
            rewardsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var progressPercent: Double {
        guard requirement > 0 else { return 0 }
        return min(Double(currentProgress) / Double(requirement), 1.0)
    }
    
    var canClaim: Bool {
        return isUnlocked && !isClaimed
    }
}

enum AchievementCategory: String, Codable, Comparable {
    case loginDays = "Login Days"
    case workHours = "Work Hours"
    case streak = "Streak"
    case completion = "Completion"
    case perfection = "Perfection"
    case dedication = "Dedication"
    
    static func < (lhs: AchievementCategory, rhs: AchievementCategory) -> Bool {
        let order: [AchievementCategory] = [.loginDays, .workHours, .streak, .completion, .perfection, .dedication]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

enum AchievementReward: Codable {
    case minutes(Int)
    case xp(Int)
    
    var displayText: String {
        switch self {
        case .minutes(let amount):
            return "\(amount) min"
        case .xp(let amount):
            return "\(amount) XP"
        }
    }
    
    var iconName: String {
        switch self {
        case .minutes:
            return "clock.fill"
        case .xp:
            return "sparkles"
        }
    }
}
