import Foundation
import SwiftData

@Model
final class SettingsLock {
    var id: UUID
    var isUnlocked: Bool
    var unlockTimestamp: Date?
    var lockdownUntil: Date?
    var lastUnlockDate: Date?
    
    init(
        id: UUID = UUID(),
        isUnlocked: Bool = false,
        unlockTimestamp: Date? = nil,
        lockdownUntil: Date? = nil,
        lastUnlockDate: Date? = nil
    ) {
        self.id = id
        self.isUnlocked = isUnlocked
        self.unlockTimestamp = unlockTimestamp
        self.lockdownUntil = lockdownUntil
        self.lastUnlockDate = lastUnlockDate
    }
    
    func canUnlock() -> Bool {
        // Check if we're in cooldown period
        if let lockdownUntil = lockdownUntil, Date() < lockdownUntil {
            return false
        }
        
        // Check if already unlocked within the 10-minute window
        if isUnlocked, let unlockTime = unlockTimestamp {
            let tenMinutesAgo = Date().addingTimeInterval(-600)
            if unlockTime > tenMinutesAgo {
                return false // Still in unlock window
            }
        }
        
        return true
    }
    
    func unlock() {
        isUnlocked = true
        unlockTimestamp = Date()
        lastUnlockDate = Date()
        lockdownUntil = nil
    }
    
    func checkAndLockIfExpired() {
        guard isUnlocked, let unlockTime = unlockTimestamp else { return }
        
        let tenMinutesLater = unlockTime.addingTimeInterval(600)
        if Date() >= tenMinutesLater {
            // Lock and start 24-hour cooldown
            isUnlocked = false
            lockdownUntil = Date().addingTimeInterval(86400) // 24 hours
        }
    }
    
    func remainingUnlockTime() -> TimeInterval? {
        guard isUnlocked, let unlockTime = unlockTimestamp else { return nil }
        
        let tenMinutesLater = unlockTime.addingTimeInterval(600)
        let remaining = tenMinutesLater.timeIntervalSince(Date())
        
        return remaining > 0 ? remaining : nil
    }
    
    func remainingCooldownTime() -> TimeInterval? {
        guard let lockdownUntil = lockdownUntil else { return nil }
        
        let remaining = lockdownUntil.timeIntervalSince(Date())
        return remaining > 0 ? remaining : nil
    }
}
