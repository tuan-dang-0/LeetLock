import SwiftUI

struct NextProblemSuggestion: View {
    @State private var suggestions = [
        "Two Sum",
        "Add Two Numbers",
        "Longest Substring Without Repeating Characters",
        "Median of Two Sorted Arrays",
        "Longest Palindromic Substring"
    ]
    
    private var randomSuggestion: String {
        suggestions.randomElement() ?? "Start solving!"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.leetCodeOrange)
                Text("Next Problem")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(randomSuggestion)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
            
            Button(action: openLeetCode) {
                HStack {
                    Text("Solve on LeetCode")
                        .fontWeight(.medium)
                    Image(systemName: "arrow.up.right")
                }
                .font(.system(size: 14))
                .foregroundColor(.leetCodeGreen)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.leetCodeGreen.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.darkCard)
        .cornerRadius(12)
    }
    
    private func openLeetCode() {
        if let url = URL(string: "https://leetcode.com/problemset/") {
            UIApplication.shared.open(url)
        }
    }
}
