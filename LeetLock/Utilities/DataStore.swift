import Foundation
import SwiftData

enum DataStore {
    static func createModelContainer() -> ModelContainer {
        let schema = Schema([
            UserSettings.self,
            DailyProgress.self,
            BlockedAppSelection.self,
            StreakData.self,
            ProblemProgress.self,
            DailyProblemTracking.self,
            SettingsLock.self,
            AppTheme.self
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
            print("ModelContainer creation failed, attempting to reset database: \(error)")
            
            let url = modelConfiguration.url
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: url.appendingPathExtension("wal"))
            try? FileManager.default.removeItem(at: url.appendingPathExtension("shm"))
            
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
