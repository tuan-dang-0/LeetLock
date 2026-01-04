import Foundation
import SwiftData

enum DataStore {
    static func createModelContainer() -> ModelContainer {
        let schema = Schema([
            TimeBlock.self,
            TaskItem.self,
            FocusSession.self,
            RewardWallet.self,
            Category.self,
            Subcategory.self,
            UserProfile.self,
            StatHistory.self,
            BlockedApp.self,
            BlockedAppSelection.self,
            DailyQuest.self,
            StreakTracker.self,
            Achievement.self,
            DailyLogin.self,
            UnlockableSprite.self,
            RecurringBlock.self,
            WeekendBonus.self,
            LeetCodeSettings.self,
            AppSettings.self,
            DailyProgress.self,
            TutorialState.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema, 
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            // If schema migration fails, delete the old database and create a new one
            print("ModelContainer creation failed, attempting to reset database: \(error)")
            
            // Delete existing database files
            let url = modelConfiguration.url
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: url.appendingPathExtension("wal"))
            try? FileManager.default.removeItem(at: url.appendingPathExtension("shm"))
            
            // Try creating container again with fresh database
            do {
                let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                return container
            } catch {
                fatalError("Failed to create ModelContainer even after reset: \(error)")
            }
        }
    }
    
    static let shared: ModelContainer = createModelContainer()
}
