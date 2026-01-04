import Foundation

actor RateLimiter {
    private var lastCallTime: [String: Date] = [:]
    private let minimumInterval: TimeInterval
    
    init(minimumInterval: TimeInterval = 1.0) {
        self.minimumInterval = minimumInterval
    }
    
    func waitIfNeeded(for key: String) async {
        if let lastCall = lastCallTime[key] {
            let elapsed = Date().timeIntervalSince(lastCall)
            if elapsed < minimumInterval {
                let waitTime = minimumInterval - elapsed
                try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        }
        lastCallTime[key] = Date()
    }
}
