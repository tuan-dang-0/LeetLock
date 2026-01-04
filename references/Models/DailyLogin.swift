import Foundation
import SwiftData

@Model
final class DailyLogin {
    var id: UUID
    var loginDates: [Date]
    var consecutiveDays: Int
    var totalLogins: Int
    
    init(
        id: UUID = UUID(),
        loginDates: [Date] = [],
        consecutiveDays: Int = 0,
        totalLogins: Int = 0
    ) {
        self.id = id
        self.loginDates = loginDates
        self.consecutiveDays = consecutiveDays
        self.totalLogins = totalLogins
    }
    
    func recordLogin() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastLogin = loginDates.last else {
            loginDates.append(today)
            consecutiveDays = 1
            totalLogins = 1
            return
        }
        
        let lastDay = calendar.startOfDay(for: lastLogin)
        let daysSinceLastLogin = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        if daysSinceLastLogin == 0 {
            return
        } else if daysSinceLastLogin == 1 {
            loginDates.append(today)
            consecutiveDays += 1
            totalLogins += 1
        } else {
            loginDates.append(today)
            consecutiveDays = 1
            totalLogins += 1
        }
    }
}
