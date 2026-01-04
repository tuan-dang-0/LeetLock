import Foundation
import SwiftData
import FamilyControls

@Model
final class BlockedAppSelection {
    var id: UUID
    var selectionData: Data
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        selectionData: Data = Data(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.selectionData = selectionData
        self.lastUpdated = lastUpdated
    }
    
    func toFamilyActivitySelection() -> FamilyActivitySelection {
        guard !selectionData.isEmpty,
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: selectionData) else {
            return FamilyActivitySelection()
        }
        return selection
    }
    
    static func from(_ selection: FamilyActivitySelection) -> BlockedAppSelection {
        let data = (try? JSONEncoder().encode(selection)) ?? Data()
        return BlockedAppSelection(
            selectionData: data,
            lastUpdated: Date()
        )
    }
}
