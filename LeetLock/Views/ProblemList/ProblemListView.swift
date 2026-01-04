import SwiftUI
import SwiftData

struct ProblemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var problemProgress: [ProblemProgress]
    @Query private var appThemeArray: [AppTheme]
    @State private var problemListState = ProblemListState()
    
    private var appTheme: AppTheme? {
        appThemeArray.first
    }
    
    @State private var problemLists: ProblemListData?
    @State private var expandedCategories: Set<String> = []
    
    private var currentList: ProblemListInfo? {
        guard let lists = problemLists else { return nil }
        return problemListState.selectedList == "blind75" ? lists.blind75 : lists.neetcode150
    }
    
    private func getProgress(for problemName: String) -> ProblemProgress? {
        // Check current list first, then check the other list for duplicate problems
        if let currentListProgress = problemProgress.first(where: { $0.problemName == problemName && $0.listType == problemListState.selectedList }) {
            return currentListProgress
        }
        
        // Check if problem exists in the other list and is completed
        let otherList = problemListState.selectedList == "blind75" ? "neetcode150" : "blind75"
        return problemProgress.first { $0.problemName == problemName && $0.listType == otherList }
    }
    
    private func toggleCompletion(for problem: Problem) {
        // Find progress in current list
        let currentListProgress = problemProgress.first { $0.problemName == problem.name && $0.listType == problemListState.selectedList }
        
        // Find progress in other list (for duplicate problems)
        let otherList = problemListState.selectedList == "blind75" ? "neetcode150" : "blind75"
        let otherListProgress = problemProgress.first { $0.problemName == problem.name && $0.listType == otherList }
        
        if let existing = currentListProgress {
            // Toggle current list progress
            existing.isCompleted.toggle()
            existing.completedDate = existing.isCompleted ? Date() : nil
            
            // Sync to other list if problem exists there
            if let otherProgress = otherListProgress {
                otherProgress.isCompleted = existing.isCompleted
                otherProgress.completedDate = existing.completedDate
            }
        } else {
            // Create new progress for current list
            let newProgress = ProblemProgress(
                problemName: problem.name,
                listType: problemListState.selectedList,
                isCompleted: true,
                completedDate: Date()
            )
            modelContext.insert(newProgress)
            
            // Create or update progress in other list if problem exists there
            if otherListProgress != nil {
                if let otherProgress = otherListProgress {
                    otherProgress.isCompleted = true
                    otherProgress.completedDate = Date()
                }
            }
        }
        
        try? modelContext.save()
    }
    
    private func toggleFlag(for problem: Problem) {
        if let existing = getProgress(for: problem.name) {
            existing.isFlagged.toggle()
        } else {
            let progress = ProblemProgress(
                problemName: problem.name,
                listType: problemListState.selectedList,
                isFlagged: true
            )
            modelContext.insert(progress)
        }
        
        try? modelContext.save()
    }
    
    private func solvedCount(for category: ProblemCategory) -> Int {
        category.problems.filter { problem in
            getProgress(for: problem.name)?.isCompleted ?? false
        }.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Menu {
                        Button(action: { problemListState.selectedList = "blind75" }) {
                            HStack {
                                Text("Blind 75")
                                    .font(.comfortaa(size: 14))
                                if problemListState.selectedList == "blind75" {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        Button(action: { problemListState.selectedList = "neetcode150" }) {
                            HStack {
                                Text("NeetCode 150")
                                    .font(.comfortaa(size: 14))
                                if problemListState.selectedList == "neetcode150" {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(problemListState.selectedList == "blind75" ? "Blind 75" : "NeetCode 150")
                                .font(.comfortaa(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .font(.comfortaa(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.darkCard)
                        .cornerRadius(8)
                    }
                    .padding()
                    
                    if let list = currentList {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(list.categories) { category in
                                    CategorySection(
                                        category: category,
                                        isExpanded: expandedCategories.contains(category.name),
                                        solvedCount: solvedCount(for: category),
                                        onToggleExpand: {
                                            if expandedCategories.contains(category.name) {
                                                expandedCategories.remove(category.name)
                                            } else {
                                                expandedCategories.insert(category.name)
                                            }
                                        },
                                        onToggleCompletion: toggleCompletion,
                                        onToggleFlag: toggleFlag,
                                        getProgress: getProgress
                                    )
                                }
                            }
                            .padding()
                        }
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .navigationTitle("Problem Lists")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if problemLists == nil {
                    problemLists = ProblemListLoader.loadProblemLists()
                }
            }
        }
    }
}

struct CategorySection: View {
    let category: ProblemCategory
    let isExpanded: Bool
    let solvedCount: Int
    let onToggleExpand: () -> Void
    let onToggleCompletion: (Problem) -> Void
    let onToggleFlag: (Problem) -> Void
    let getProgress: (String) -> ProblemProgress?
    
    @Query private var appThemeArray: [AppTheme]
    
    private var appTheme: AppTheme? {
        appThemeArray.first
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    onToggleExpand()
                }
            }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                    
                    Text(category.name)
                        .font(.comfortaa(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(solvedCount)/\(category.problems.count)")
                        .font(.comfortaa(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    if solvedCount == category.problems.count {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(appTheme?.primaryColor ?? .cyan)
                    }
                }
                .padding()
                .background(Color.darkCard)
                .cornerRadius(8)
            }
                
                if isExpanded {
                    VStack(spacing: 1) {
                        ForEach(category.problems) { problem in
                            ProblemRow(
                                problem: problem,
                                progress: getProgress(problem.name),
                                onToggleCompletion: { onToggleCompletion(problem) },
                                onToggleFlag: { onToggleFlag(problem) }
                            )
                        }
                    }
                    .background(Color.darkCard)
                    .cornerRadius(8)
                    .padding(.top, 4)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                }
            }
        }
    }
    
    struct ProblemRow: View {
        let problem: Problem
        let progress: ProblemProgress?
        let onToggleCompletion: () -> Void
        let onToggleFlag: () -> Void
        
        @Query private var appThemeArray: [AppTheme]
        
        private var appTheme: AppTheme? {
            appThemeArray.first
        }
        
        private var isCompleted: Bool {
            progress?.isCompleted ?? false
        }
        
        private var isFlagged: Bool {
            progress?.isFlagged ?? false
        }
        
        var body: some View {
            HStack(spacing: 12) {
                Button(action: onToggleCompletion) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? appTheme?.primaryColor ?? .cyan : .gray)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(problem.name)
                        .font(.comfortaa(size: 14, weight: .medium))
                        .foregroundColor(isCompleted ? .gray : .white)
                        .strikethrough(isCompleted)
                    
                    Text(problem.difficulty)
                        .font(.comfortaa(size: 12))
                        .foregroundColor(Color(hex: problem.difficultyColor))
                }
                
                Spacer()
                
                Button(action: onToggleFlag) {
                    Image(systemName: isFlagged ? "flag.fill" : "flag")
                        .foregroundColor(isFlagged ? .orange : .gray)
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.darkBackground)
        }
    }
    
    struct ProblemListView_Previews: PreviewProvider {
        static var previews: some View {
            ProblemListView()
                .modelContainer(DataStore.createModelContainer())
        }
    }
    
