import Foundation

struct DateUtils {
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    static func startOfDay(_ date: Date = Date()) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    static func createTime(hour: Int, minute: Int, date: Date = Date()) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }
    
    static func roundToNearest5Minutes(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        guard let minute = components.minute else { return date }
        
        // Round to nearest 5 minutes (0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55)
        let roundedMinute = (minute / 5) * 5
        
        var newComponents = components
        newComponents.minute = roundedMinute
        newComponents.second = 0
        
        return calendar.date(from: newComponents) ?? date
    }
}
