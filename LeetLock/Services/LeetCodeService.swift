import Foundation

struct LeetCodeService {
    static let graphQLEndpoint = "https://leetcode.com/graphql"
    static let rateLimiter = RateLimiter(minimumInterval: 1.0)
    
    struct Submission: Codable {
        let title: String
        let titleSlug: String
        let timestamp: String
        let statusDisplay: String
        let lang: String?
    }
    
    struct UserStats: Codable {
        let difficulty: String
        let count: Int
    }
    
    struct ProblemRecommendation: Codable {
        let title: String
        let titleSlug: String
        let difficulty: String
        let topicTags: [String]
    }
    
    struct DailyQuestion: Codable {
        let title: String
        let difficulty: String
        let date: String
        let link: String
    }
    
    private struct SubmissionsResponse: Codable {
        let data: DataContainer
        
        struct DataContainer: Codable {
            let recentSubmissionList: [Submission]
        }
    }
    
    private struct ProfileResponse: Codable {
        let data: DataContainer
        
        struct DataContainer: Codable {
            let matchedUser: UserProfile?
        }
        
        struct UserProfile: Codable {
            let username: String
            let submitStats: SubmitStats?
            
            struct SubmitStats: Codable {
                let acSubmissionNum: [UserStats]
            }
        }
    }
    
    static func verifyUsername(_ username: String) async throws -> Bool {
        await rateLimiter.waitIfNeeded(for: "verifyUsername")
        
        let query = """
        query getUserProfile($username: String!) {
          matchedUser(username: $username) {
            username
          }
        }
        """
        
        let payload: [String: Any] = [
            "query": query,
            "variables": ["username": username]
        ]
        
        let response = try await executeGraphQLQuery(payload: payload)
        let decoded = try JSONDecoder().decode(ProfileResponse.self, from: response)
        
        return decoded.data.matchedUser != nil
    }
    
    static func fetchRecentSubmissions(username: String, limit: Int = 100) async throws -> [Submission] {
        await rateLimiter.waitIfNeeded(for: "fetchRecentSubmissions")
        
        let query = """
        query getRecentSubmissions($username: String!, $limit: Int!) {
          recentSubmissionList(username: $username, limit: $limit) {
            title
            titleSlug
            timestamp
            statusDisplay
            lang
          }
        }
        """
        
        let payload: [String: Any] = [
            "query": query,
            "variables": [
                "username": username,
                "limit": limit
            ]
        ]
        
        let response = try await executeGraphQLQuery(payload: payload)
        let decoded = try JSONDecoder().decode(SubmissionsResponse.self, from: response)
        
        return decoded.data.recentSubmissionList
    }
    
    static func fetchDailyProgress(username: String) async throws -> DailyProgressResult {
        let submissions = try await fetchRecentSubmissions(username: username, limit: 100)
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todaySubmissions = submissions.filter { submission in
            guard let timestamp = Double(submission.timestamp) else { return false }
            let submissionDate = Date(timeIntervalSince1970: timestamp)
            let submissionDay = calendar.startOfDay(for: submissionDate)
            
            return submission.statusDisplay == "Accepted" && submissionDay == today
        }
        
        let uniqueProblems = Set(todaySubmissions.map { $0.titleSlug })
        
        return DailyProgressResult(
            problemCount: uniqueProblems.count,
            verified: true,
            uniqueProblemSlugs: Array(uniqueProblems),
            error: nil
        )
    }
    
    static func getSubmissionHeatmap(username: String, days: Int = 365) async throws -> [Date: Int] {
        let submissions = try await fetchRecentSubmissions(username: username, limit: 1000)
        
        let calendar = Calendar.current
        var heatmap: [Date: Int] = [:]
        
        for submission in submissions where submission.statusDisplay == "Accepted" {
            guard let timestamp = Double(submission.timestamp) else { continue }
            let submissionDate = Date(timeIntervalSince1970: timestamp)
            let day = calendar.startOfDay(for: submissionDate)
            
            heatmap[day, default: 0] += 1
        }
        
        return heatmap
    }
    
    static func getDailyQuestion() async throws -> DailyQuestion {
        await rateLimiter.waitIfNeeded(for: "getDailyQuestion")
        
        let query = """
        query questionOfToday {
          activeDailyCodingChallengeQuestion {
            date
            link
            question {
              title
              difficulty
            }
          }
        }
        """
        
        let payload: [String: Any] = [
            "query": query,
            "operationName": "questionOfToday"
        ]
        
        let response = try await executeGraphQLQuery(payload: payload)
        
        // Parse the response
        guard let json = try JSONSerialization.jsonObject(with: response) as? [String: Any],
              let data = json["data"] as? [String: Any],
              let daily = data["activeDailyCodingChallengeQuestion"] as? [String: Any],
              let question = daily["question"] as? [String: Any],
              let title = question["title"] as? String,
              let difficulty = question["difficulty"] as? String,
              let date = daily["date"] as? String,
              let link = daily["link"] as? String else {
            throw LeetCodeError.decodingFailed
        }
        
        return DailyQuestion(
            title: title,
            difficulty: difficulty,
            date: date,
            link: link
        )
    }
    
    private static func executeGraphQLQuery(payload: [String: Any]) async throws -> Data {
        guard let url = URL(string: graphQLEndpoint) else {
            throw LeetCodeError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
        request.timeoutInterval = 30.0
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LeetCodeError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw LeetCodeError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
}

struct DailyProgressResult {
    let problemCount: Int
    let verified: Bool
    let uniqueProblemSlugs: [String]
    let error: String?
}

enum LeetCodeError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed
    case noStatsFound
    case usernameNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid LeetCode API URL"
        case .invalidResponse:
            return "Invalid response from LeetCode"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingFailed:
            return "Failed to decode response"
        case .noStatsFound:
            return "No statistics found for user"
        case .usernameNotFound:
            return "Username not found"
        }
    }
}
