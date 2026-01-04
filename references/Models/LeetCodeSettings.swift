import Foundation
import SwiftData

@Model
final class LeetCodeSettings {
    var id: UUID
    var isEnabled: Bool
    var username: String
    var bonusPerProblem: Double
    var maxBonusMultiplier: Double
    var lastValidated: Date?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        isEnabled: Bool = false,
        username: String = "",
        bonusPerProblem: Double = 0.1,
        maxBonusMultiplier: Double = 0.5,
        lastValidated: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.isEnabled = isEnabled
        self.username = username
        self.bonusPerProblem = bonusPerProblem
        self.maxBonusMultiplier = maxBonusMultiplier
        self.lastValidated = lastValidated
        self.createdAt = createdAt
    }
    
    // Validation helpers
    func isConfigured() -> Bool {
        return isEnabled && !username.isEmpty
    }
    
    func calculateMultiplier(problemCount: Int) -> Double {
        let bonus = Double(problemCount) * bonusPerProblem
        let cappedBonus = min(bonus, maxBonusMultiplier)
        return 1.0 + cappedBonus
    }
}
