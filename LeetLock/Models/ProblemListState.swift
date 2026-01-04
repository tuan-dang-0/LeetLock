import SwiftUI
import SwiftData

@Observable
class ProblemListState {
    var selectedList: String = "blind75" {
        didSet {
            UserDefaults.standard.set(selectedList, forKey: "selectedProblemList")
        }
    }
    
    init() {
        if let saved = UserDefaults.standard.string(forKey: "selectedProblemList") {
            self.selectedList = saved
        }
    }
    
    func getNextProblem(
        problemLists: ProblemListData?,
        completedProblems: [ProblemProgress]
    ) -> (problem: Problem, category: String)? {
        guard let lists = problemLists else { return nil }
        
        let currentList = selectedList == "blind75" ? lists.blind75 : lists.neetcode150
        let allProblems = currentList.categories.flatMap { category -> [(Problem, String)] in
            category.problems.map { ($0, category.name) }
        }
        
        for (problem, category) in allProblems {
            let isCompleted = completedProblems.contains { progress in
                progress.problemName == problem.name &&
                progress.listType == selectedList &&
                progress.isCompleted
            }
            
            if !isCompleted {
                return (problem, category)
            }
        }
        
        return allProblems.first
    }
}
