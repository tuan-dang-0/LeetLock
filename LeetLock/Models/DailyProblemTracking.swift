import Foundation
import SwiftData

@Model
final class DailyProblemTracking {
    var id: UUID
    var completedDate: Date
    var problemTitle: String
    
    init(id: UUID = UUID(), completedDate: Date = Date(), problemTitle: String) {
        self.id = id
        self.completedDate = completedDate
        self.problemTitle = problemTitle
    }
    
    func isCompletedToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(completedDate)
    }
}
