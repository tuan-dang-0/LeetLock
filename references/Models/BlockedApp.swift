import Foundation
import SwiftData

@Model
final class BlockedApp {
    var id: UUID
    var bundleIdentifier: String
    var displayName: String
    var isBlocked: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        bundleIdentifier: String,
        displayName: String,
        isBlocked: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
        self.isBlocked = isBlocked
        self.createdAt = createdAt
    }
}
