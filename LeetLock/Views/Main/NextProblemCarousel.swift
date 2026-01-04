import SwiftUI
import SwiftData

struct NextProblemCarousel: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var problemProgress: [ProblemProgress]
    @Query private var dailyTracking: [DailyProblemTracking]
    @Query private var appThemeArray: [AppTheme]
    @State private var problemListState = ProblemListState()
    
    private var appTheme: AppTheme? {
        appThemeArray.first
    }
    
    @State private var problemLists: ProblemListData?
    @State private var dailyProblem: String = "Loading..."
    @State private var dailyDifficulty: String = "Medium"
    @State private var dailyDate: String = ""
    @State private var isDailyCompleted = false
    @State private var isNextCompleted = false
    
    private var isDailyCompletedToday: Bool {
        dailyTracking.contains { tracking in
            tracking.isCompletedToday() && tracking.problemTitle == dailyProblem
        }
    }
    
    private var nextProblemData: (problem: Problem, category: String)? {
        problemListState.getNextProblem(
            problemLists: problemLists,
            completedProblems: problemProgress
        )
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Row 1: Daily Challenge (hide if completed today)
            if !isDailyCompleted && !isDailyCompletedToday {
                CompactProblemRow(
                    title: dailyProblem,
                    tag1: "Daily",
                    tag1Color: Color.purple,
                    tag2: dailyDifficulty,
                    tag2Color: difficultyColor(dailyDifficulty),
                    onComplete: {
                        markDailyComplete()
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
            
            // Row 2: Next Problem from List
            if !isNextCompleted {
                if let problemData = nextProblemData {
                    CompactProblemRow(
                        title: problemData.problem.name,
                        tag1: problemListState.selectedList == "blind75" ? "Blind 75" : "NC 150",
                        tag1Color: Color.blue,
                        tag2: problemData.problem.difficulty,
                        tag2Color: difficultyColor(problemData.problem.difficulty),
                        onComplete: {
                            markProblemComplete(problemData.problem)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                } else {
                    CompactProblemRow(
                        title: "Loading...",
                        tag1: "...",
                        tag1Color: Color.gray,
                        tag2: "...",
                        tag2Color: Color.gray,
                        onComplete: {}
                    )
                }
            }
        }
        .onAppear {
            if problemLists == nil {
                problemLists = ProblemListLoader.loadProblemLists()
            }
            Task {
                await fetchDailyProblem()
            }
        }
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "easy":
            return Color(hex: "00B8A3") // Green
        case "medium":
            return Color(hex: "FFA116") // Orange
        case "hard":
            return Color(hex: "EF4743") // Red
        default:
            return Color.gray
        }
    }
    
    private func fetchDailyProblem() async {
        do {
            let daily = try await LeetCodeService.getDailyQuestion()
            dailyProblem = daily.title
            dailyDifficulty = daily.difficulty
            dailyDate = daily.date
        } catch {
            print("Failed to fetch daily problem: \(error)")
            dailyProblem = "Unable to load daily"
            dailyDifficulty = "Medium"
        }
    }
    
    private func markDailyComplete() {
        withAnimation(.easeOut(duration: 0.3)) {
            isDailyCompleted = true
        }
        
        // Save to database
        let tracking = DailyProblemTracking(
            completedDate: Date(),
            problemTitle: dailyProblem
        )
        modelContext.insert(tracking)
        try? modelContext.save()
    }
    
    private func markProblemComplete(_ problem: Problem) {
        withAnimation(.easeOut(duration: 0.3)) {
            isNextCompleted = true
        }
        
        // Mark as complete in database
        let progress = problemProgress.first(where: { $0.problemName == problem.name }) ?? {
            let newProgress = ProblemProgress(
                problemName: problem.name,
                listType: problemListState.selectedList
            )
            modelContext.insert(newProgress)
            return newProgress
        }()
        
        progress.isCompleted = true
        try? modelContext.save()
        
        // Reset after animation to show next problem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isNextCompleted = false
        }
    }
}

struct CompactProblemRow: View {
    let title: String
    let tag1: String
    let tag1Color: Color
    let tag2: String
    let tag2Color: Color
    let onComplete: () -> Void
    
    @State private var isCompleting = false
    @Query private var appThemeArray: [AppTheme]
    
    private var appTheme: AppTheme? {
        appThemeArray.first
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.comfortaa(size: 14, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 6) {
                Text(tag1)
                    .font(.comfortaa(size: 10, weight: .medium))
                    .foregroundColor(tag1Color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(tag1Color.opacity(0.15))
                    .cornerRadius(4)
                
                Text(tag2)
                    .font(.comfortaa(size: 10, weight: .medium))
                    .foregroundColor(tag2Color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(tag2Color.opacity(0.15))
                    .cornerRadius(4)
                
                // Completion button
                Button(action: onComplete) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.leetCodeGreen)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

struct CompactTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.7))
            .cornerRadius(4)
    }
}

#Preview {
    NextProblemCarousel()
        .modelContainer(DataStore.createModelContainer())
}
