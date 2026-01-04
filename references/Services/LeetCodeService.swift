import Foundation

struct LeetCodeService {
    static let graphQLEndpoint = "https://leetcode.com/graphql"
    
    // MARK: - Response Models
    
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
    
    // MARK: - GraphQL Response Models
    
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
    
    // MARK: - API Methods
    
    static func verifyUsername(_ username: String) async throws -> Bool {
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
    
    static func fetchUserStats(username: String) async throws -> [UserStats] {
        let query = """
        query getUserProfile($username: String!) {
          matchedUser(username: $username) {
            username
            submitStats {
              acSubmissionNum {
                difficulty
                count
              }
            }
          }
        }
        """
        
        let payload: [String: Any] = [
            "query": query,
            "variables": ["username": username]
        ]
        
        let response = try await executeGraphQLQuery(payload: payload)
        let decoded = try JSONDecoder().decode(ProfileResponse.self, from: response)
        
        guard let stats = decoded.data.matchedUser?.submitStats?.acSubmissionNum else {
            throw LeetCodeError.noStatsFound
        }
        
        return stats
    }
    
    static func fetchRecentSubmissions(username: String, limit: Int = 50) async throws -> [Submission] {
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
    
    static func validateBlockActivity(
        username: String,
        startTime: Date,
        endTime: Date
    ) async -> ValidationResult {
        do {
            let submissions = try await fetchRecentSubmissions(username: username)
            
            // Filter to accepted submissions within timeframe
            let acceptedInTimeframe = submissions.filter { submission in
                guard let timestamp = Double(submission.timestamp) else { return false }
                let submissionDate = Date(timeIntervalSince1970: timestamp)
                
                return submission.statusDisplay == "Accepted" &&
                       submissionDate >= startTime &&
                       submissionDate <= endTime
            }
            
            if acceptedInTimeframe.isEmpty {
                return ValidationResult(
                    verified: false,
                    multiplier: 1.0,
                    problemCount: 0,
                    details: "No LeetCode activity detected during block"
                )
            }
            
            // Calculate bonus: 10% per problem, capped at 50%
            let bonusPercent = min(Double(acceptedInTimeframe.count) * 0.1, 0.5)
            let multiplier = 1.0 + bonusPercent
            
            return ValidationResult(
                verified: true,
                multiplier: multiplier,
                problemCount: acceptedInTimeframe.count,
                details: "✓ \(acceptedInTimeframe.count) problem(s) solved"
            )
            
        } catch {
            print("LeetCode validation error: \(error)")
            // If API fails, default to base stats (no penalty)
            return ValidationResult(
                verified: false,
                multiplier: 1.0,
                problemCount: 0,
                details: "Validation unavailable"
            )
        }
    }
    
    static func fetchDailyProgress(username: String) async -> DailyProgressResult {
        do {
            let submissions = try await fetchRecentSubmissions(username: username, limit: 100)
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            // Filter to accepted submissions today
            let todaySubmissions = submissions.filter { submission in
                guard let timestamp = Double(submission.timestamp) else { return false }
                let submissionDate = Date(timeIntervalSince1970: timestamp)
                let submissionDay = calendar.startOfDay(for: submissionDate)
                
                return submission.statusDisplay == "Accepted" && submissionDay == today
            }
            
            // Get unique problems (same problem might have multiple submissions)
            let uniqueProblems = Set(todaySubmissions.map { $0.titleSlug })
            
            return DailyProgressResult(
                problemCount: uniqueProblems.count,
                verified: true,
                error: nil
            )
            
        } catch {
            print("LeetCode daily progress error: \(error)")
            return DailyProgressResult(
                problemCount: 0,
                verified: false,
                error: error.localizedDescription
            )
        }
    }
    
    // MARK: - Private Helper
    
    private static func executeGraphQLQuery(payload: [String: Any]) async throws -> Data {
        guard let url = URL(string: graphQLEndpoint) else {
            throw LeetCodeError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LeetCodeError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw LeetCodeError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
}

// MARK: - Supporting Types

struct ValidationResult {
    let verified: Bool
    let multiplier: Double
    let problemCount: Int
    let details: String
}

struct DailyProgressResult {
    let problemCount: Int
    let verified: Bool
    let error: String?
}

enum LeetCodeError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed
    case noStatsFound
    case usernameNotFound
}
