import Foundation
import SwiftData
import ManagedSettings
import FamilyControls

class AppBlockingService {
    private static let store = ManagedSettingsStore()
    private static var currentSelection = FamilyActivitySelection()
    private static var modelContext: ModelContext?
    
    static func initialize(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadPersistedSelection()
    }
    
    static func updateBlockedAppsSelection(_ newSelection: FamilyActivitySelection) {
        currentSelection = newSelection
        persistSelection()
        applyShields()
    }
    
    static func getCurrentSelection() -> FamilyActivitySelection {
        return currentSelection
    }
    
    static func getBlockedAppCount() -> Int {
        return currentSelection.applicationTokens.count
    }
    
    static func applyShields() {
        store.shield.applications = currentSelection.applicationTokens.isEmpty ? nil : currentSelection.applicationTokens
        store.shield.applicationCategories = currentSelection.categoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(currentSelection.categoryTokens)
    }
    
    static func removeShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
    
    static func areShieldsActive() -> Bool {
        return store.shield.applications != nil && !currentSelection.applicationTokens.isEmpty
    }
    
    private static func loadPersistedSelection() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<BlockedAppSelection>(
            sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)]
        )
        
        if let persisted = try? context.fetch(descriptor).first {
            let restored = persisted.toFamilyActivitySelection()
            if !restored.applicationTokens.isEmpty || !restored.categoryTokens.isEmpty {
                currentSelection = restored
            }
        }
    }
    
    private static func persistSelection() {
        guard let context = modelContext else { return }
        guard !currentSelection.applicationTokens.isEmpty || !currentSelection.categoryTokens.isEmpty else {
            clearPersistedSelection()
            return
        }
        
        let descriptor = FetchDescriptor<BlockedAppSelection>()
        if let existing = try? context.fetch(descriptor).first {
            context.delete(existing)
        }
        
        let newSelection = BlockedAppSelection.from(currentSelection)
        context.insert(newSelection)
        try? context.save()
    }
    
    private static func clearPersistedSelection() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<BlockedAppSelection>()
        if let existing = try? context.fetch(descriptor).first {
            context.delete(existing)
            try? context.save()
        }
    }
}
