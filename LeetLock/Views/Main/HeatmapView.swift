import SwiftUI
import SwiftData
import Lottie

struct HeatmapView: View {
    let username: String
    @State private var heatmapData: [Date: Int] = [:]
    @State private var isLoading = false
    @Query private var streakDataArray: [StreakData]
    @Query private var appThemeArray: [AppTheme]
    
    private var appTheme: AppTheme? {
        appThemeArray.first
    }

    private let totalMonths = 3

    // MARK: - 15% scale down
    private let heatmapScale: CGFloat = 0.85

    private var cellSize: CGFloat { 15 * heatmapScale }
    private var cellCornerRadius: CGFloat { 2 * heatmapScale }

    private var cellSpacing: CGFloat { 4 * heatmapScale }          // within a week column
    private var columnSpacing: CGFloat { 9 * heatmapScale }         // between week columns
    private var monthsSpacing: CGFloat { 16 * heatmapScale }        // between months
    private var weekdayToGridSpacing: CGFloat { 8 * heatmapScale }  // between weekday labels + months

    private var weekdayVSpacing: CGFloat { 7.5 * heatmapScale }
    private var weekdayFontSize: CGFloat { 10 * heatmapScale }
    private var weekdayRowHeight: CGFloat { 12 * heatmapScale }

    private var monthFontSize: CGFloat { 10 * heatmapScale }
    private var monthTopPadding: CGFloat { 4 * heatmapScale }

    private func getMonthInfo() -> [(startDate: Date, endDate: Date, columns: Int, startWeekday: Int)] {
        let calendar = Calendar.current
        let today = Date()
        var monthsInfo: [(Date, Date, Int, Int)] = []

        for monthOffset in (0..<totalMonths).reversed() {
            guard let monthStart = calendar.date(byAdding: .month, value: -monthOffset, to: today),
                  let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthStart)) else {
                continue
            }

            let lastDayOfMonth: Date
            if monthOffset == 0 {
                lastDayOfMonth = calendar.startOfDay(for: today)
            } else {
                lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth) ?? firstDayOfMonth
            }

            let fullMonthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth) ?? lastDayOfMonth
            let fullDaysInMonth = calendar.dateComponents([.day], from: firstDayOfMonth, to: fullMonthEnd).day! + 1
            let startWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1 // 0 = Sunday, 6 = Saturday
            let totalCells = startWeekday + fullDaysInMonth
            let columns = (totalCells + 6) / 7

            monthsInfo.append((firstDayOfMonth, lastDayOfMonth, columns, startWeekday))
        }

        return monthsInfo
    }

    private var streakCount: Int {
        // Use app goal streak instead of heatmap streak
        streakDataArray.first?.currentStreak ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Submission History")
                    .font(.comfortaa(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 2) {
                    LottieView(
                        animationName: "Fire Streak Orange",
                        loopMode: .loop,
                        animationSpeed: 1.0
                    )
                    .frame(width: 35, height: 35)
                    
                    Text("\(streakCount)")
                        .font(.comfortaa(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else if heatmapData.isEmpty {
                Text("No submission data yet")
                    .font(.comfortaa(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                // Center the heatmap content within the panel
                HStack {
                    Spacer(minLength: 0)

                    HStack(alignment: .top, spacing: weekdayToGridSpacing) {
                        // Weekday labels
                        VStack(spacing: weekdayVSpacing) {
                            ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { _, day in
                                Text(day)
                                    .font(.comfortaa(size: weekdayFontSize))
                                    .foregroundColor(.gray)
                                    .frame(height: weekdayRowHeight)
                            }
                        }

                        // Months
                        HStack(spacing: monthsSpacing) {
                            ForEach(Array(getMonthInfo().enumerated()), id: \.offset) { _, monthInfo in
                                let monthGridWidth =
                                    CGFloat(monthInfo.columns) * cellSize +
                                    CGFloat(max(0, monthInfo.columns - 1)) * columnSpacing

                                VStack(spacing: monthTopPadding) {
                                    HStack(spacing: columnSpacing) {
                                        ForEach(0..<monthInfo.columns, id: \.self) { column in
                                            VStack(spacing: cellSpacing) {
                                                ForEach(0..<7, id: \.self) { row in
                                                    let cellIndex = column * 7 + row
                                                    let cells = getCellsForMonth(
                                                        startDate: monthInfo.startDate,
                                                        endDate: monthInfo.endDate,
                                                        startWeekday: monthInfo.startWeekday
                                                    )

                                                    if cellIndex < cells.count, let date = cells[cellIndex].date {
                                                        HeatmapCell(
                                                            count: heatmapData[date] ?? 0,
                                                            date: date,
                                                            size: cellSize,
                                                            cornerRadius: cellCornerRadius,
                                                            primaryColor: appTheme?.primaryColor ?? .cyan
                                                        )
                                                    } else {
                                                        Color.clear
                                                            .frame(width: cellSize, height: cellSize)
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Text(getMonthLabel(for: monthInfo.startDate))
                                        .font(.comfortaa(size: monthFontSize, weight: .medium))
                                        .foregroundColor(.gray)
                                        .frame(width: monthGridWidth, alignment: .center)
                                        .padding(.top, monthTopPadding)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 0)
                }
            }
        }
        .padding()
        .background(Color.clear)
        .cornerRadius(12)
        .refreshable {
            await loadHeatmap()
        }
        .task {
            // Only load once on first appearance
            if heatmapData.isEmpty && !isLoading {
                await loadHeatmap()
            }
        }
    }

    private struct GridCell: Identifiable {
        let id = UUID()
        let date: Date?
    }

    private func getCellsForMonth(startDate: Date, endDate: Date, startWeekday: Int) -> [GridCell] {
        let calendar = Calendar.current
        var cells: [GridCell] = []

        for _ in 0..<startWeekday { cells.append(GridCell(date: nil)) }

        var currentDate = startDate
        while currentDate <= endDate {
            cells.append(GridCell(date: calendar.startOfDay(for: currentDate)))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        guard let fullMonthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) else {
            return cells
        }

        let fullDaysInMonth = calendar.dateComponents([.day], from: startDate, to: fullMonthEnd).day! + 1
        let totalCellsNeeded = startWeekday + fullDaysInMonth

        while cells.count < totalCellsNeeded {
            cells.append(GridCell(date: nil))
        }

        return cells
    }

    private func getMonthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    private func loadHeatmap() async {
        guard !username.isEmpty else { return }

        isLoading = true

        do {
            let calendar = Calendar.current
            let monthsInfo = getMonthInfo()
            guard let oldestMonth = monthsInfo.last else { return }

            let daysSinceOldest = calendar.dateComponents([.day], from: oldestMonth.startDate, to: Date()).day ?? 90
            heatmapData = try await LeetCodeService.getSubmissionHeatmap(username: username, days: daysSinceOldest + 1)
        } catch {
            print("Failed to load heatmap: \(error)")
        }

        isLoading = false
    }
}

struct HeatmapCell: View {
    let count: Int
    let date: Date

    // Scaled sizing
    let size: CGFloat
    let cornerRadius: CGFloat
    var primaryColor: Color = .cyan

    private var color: Color {
        switch count {
        case 0:
            return Color.darkAccent
        case 1:
            return primaryColor.opacity(0.3)
        case 2:
            return primaryColor.opacity(0.5)
        case 3:
            return primaryColor.opacity(0.7)
        default:
            return primaryColor
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(color)
            .frame(width: size, height: size)
    }
}

#Preview {
    VStack {
        HeatmapView(username: "testuser")
    }
    .padding()
}
