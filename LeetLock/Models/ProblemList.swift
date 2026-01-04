import Foundation
import SwiftData

struct ProblemListData: Codable {
    let blind75: ProblemListInfo
    let neetcode150: ProblemListInfo
}

struct ProblemListInfo: Codable {
    let meta: ProblemListMeta
    let categories: [ProblemCategory]
}

struct ProblemListMeta: Codable {
    let total: Int
    let difficultyCounts: [String: Int]
}

struct ProblemCategory: Codable, Identifiable {
    var id: String { name }
    let name: String
    let problems: [Problem]
}

struct Problem: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let difficulty: String
    
    var difficultyColor: String {
        switch difficulty.lowercased() {
        case "easy":
            return "00B8A3"
        case "medium":
            return "FFA116"
        case "hard":
            return "EF4743"
        default:
            return "808080"
        }
    }
}

@Model
final class ProblemProgress {
    var id: UUID
    var problemName: String
    var listType: String
    var isCompleted: Bool
    var isFlagged: Bool
    var completedDate: Date?
    var notes: String
    
    init(
        id: UUID = UUID(),
        problemName: String,
        listType: String,
        isCompleted: Bool = false,
        isFlagged: Bool = false,
        completedDate: Date? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.problemName = problemName
        self.listType = listType
        self.isCompleted = isCompleted
        self.isFlagged = isFlagged
        self.completedDate = completedDate
        self.notes = notes
    }
}

class ProblemListLoader {
    static func loadProblemLists() -> ProblemListData? {
        guard let url = Bundle.main.url(forResource: "problem_list", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to load problem_list.json")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let problemLists = try decoder.decode(ProblemListData.self, from: data)
            print("✅ Loaded problem lists: Blind75(\(problemLists.blind75.meta.total)), NeetCode150(\(problemLists.neetcode150.meta.total))")
            return problemLists
        } catch {
            print("❌ Failed to decode problem_list.json: \(error)")
            return nil
        }
    }
}
