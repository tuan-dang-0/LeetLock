import Foundation
import SwiftData
import ManagedSettings
import FamilyControls

class AppBlockingService {
    private static let store = ManagedSettingsStore()
    
    private static var currentSelection = FamilyActivitySelection()
    private static var modelContext: ModelContext?
    
    /// Initialize the service with persisted selection
    static func initialize(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadPersistedSelection()
    }
    
    /// Update the blocked apps selection (merges with existing)
    static func updateBlockedAppsSelection(_ newSelection: FamilyActivitySelection) {
        currentSelection.applicationTokens.formUnion(newSelection.applicationTokens)
        currentSelection.categoryTokens.formUnion(newSelection.categoryTokens)
        persistSelection()
        applyShields()
    }
    
    /// Get the current selection for editing
    static func getCurrentSelection() -> FamilyActivitySelection {
        return currentSelection
    }
    
    /// Get count of blocked apps
    static func getBlockedAppCount() -> Int {
        return currentSelection.applicationTokens.count
    }
    
    static func applyShields() {
        let store = ManagedSettingsStore()
        
        store.shield.applications = currentSelection.applicationTokens.isEmpty ? nil : currentSelection.applicationTokens
        store.shield.applicationCategories = currentSelection.categoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(currentSelection.categoryTokens)
    }
    
    /// Apply shields to all blocked apps that are toggled on
    static func applyBlockedApps(modelContext: ModelContext) {
        // This maintains the current selection and reapplies shields
        applyShields()
    }
    
    /// Temporarily remove shields (when reward minutes are redeemed)
    static func removeShields() {
        store.shield.applications = nil
    }
    
    /// Re-apply shields after reward time expires
    static func reapplyShields(modelContext: ModelContext) {
        applyBlockedApps(modelContext: modelContext)
    }
    
    /// Update shields when a specific app's blocked status changes
    static func updateAppBlockStatus(for app: BlockedApp, modelContext: ModelContext) {
        applyBlockedApps(modelContext: modelContext)
    }
    
    /// Check if shields are currently active
    static func areShieldsActive() -> Bool {
        return store.shield.applications != nil && !store.shield.applications!.isEmpty
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
                applyShields()
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
