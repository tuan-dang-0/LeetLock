import SwiftUI
import SwiftData

struct DailyLoginView: View {
    @Query private var logins: [DailyLogin]
    @Environment(\.modelContext) private var modelContext
    
    private var loginTracker: DailyLogin? {
        logins.first
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Daily Login")
                .font(.title2)
                .fontWeight(.bold)
            
            if let tracker = loginTracker {
                // Streak Display
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(tracker.consecutiveDays)")
                                .font(.system(size: 28, weight: .bold))
                            Text("Day Streak")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemOrange).opacity(0.2))
                    .cornerRadius(12)
                    
                    // Total Logins
                    HStack {
                        Image(systemName: "calendar.badge.checkmark")
                            .foregroundColor(.appAccent)
                        Text("Total Logins: \(tracker.totalLogins)")
                            .font(.headline)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Login History (Last 7 days)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent History")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(lastSevenDays(), id: \.self) { date in
                            VStack(spacing: 4) {
                                Text(dayLetter(date))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Circle()
                                    .fill(isLoggedIn(date, tracker: tracker) ? Color.green : Color(.systemGray5))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Group {
                                            if isLoggedIn(date, tracker: tracker) {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.white)
                                                    .font(.caption)
                                            }
                                        }
                                    )
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func lastSevenDays() -> [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: Date())
        }.reversed()
    }
    
    private func dayLetter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        let day = formatter.string(from: date)
        return String(day.prefix(1))
    }
    
    private func isLoggedIn(_ date: Date, tracker: DailyLogin) -> Bool {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)
        return tracker.loginDates.contains { calendar.isDate($0, inSameDayAs: targetDay) }
    }
}

#Preview {
    DailyLoginView()
        .modelContainer(DataStore.shared)
}
