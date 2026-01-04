import SwiftUI
import SwiftData

@Model
final class AppTheme {
    var id: UUID
    var primaryColorHex: String
    var secondaryColorHex: String
    
    init(
        id: UUID = UUID(),
        primaryColorHex: String = "#00CED1", // Cyan
        secondaryColorHex: String = "#FF8C00" // Orange
    ) {
        self.id = id
        self.primaryColorHex = primaryColorHex
        self.secondaryColorHex = secondaryColorHex
    }
    
    var primaryColor: Color {
        Color(hex: primaryColorHex)
    }
    
    var secondaryColor: Color {
        Color(hex: secondaryColorHex)
    }
}
