import SwiftUI
import SwiftData

struct LockProgressView: View {
    let progress: DailyProgress?
    let settings: UserSettings
    let streakData: StreakData?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var appThemeArray: [AppTheme]
    
    private var appTheme: AppTheme? {
        appThemeArray.first
    }

    private let lockScale: CGFloat = 0.85
    
    private var problemsCompleted: Int {
        progress?.problemsSolved ?? 0
    }
    
    private var totalProblems: Int {
        settings.dailyProblemGoal
    }
    
    private var progressPercentage: Double {
        guard totalProblems > 0 else { return 0 }
        return min(Double(problemsCompleted) / Double(totalProblems), 1.0)
    }
    
    private var isUnlocked: Bool {
        problemsCompleted >= totalProblems
    }
    
    var body: some View {
        VStack(spacing: 30) {

            ZStack {
                // Ambient circular glow (always visible)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                (appTheme?.primaryColor ?? .cyan).opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 80 * lockScale,
                            endRadius: 160 * lockScale
                        )
                    )
                    .frame(width: 320 * lockScale, height: 320 * lockScale)
                    .blur(radius: 25 * lockScale)

                // Progress glow (appears with progress)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (appTheme?.primaryColor ?? .cyan).opacity(0.4),
                                (appTheme?.secondaryColor ?? .orange).opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 90 * lockScale,
                            endRadius: 150 * lockScale
                        )
                    )
                    .frame(width: 300 * lockScale, height: 300 * lockScale)
                    .blur(radius: 20 * lockScale)
                    .opacity(progressPercentage > 0 ? 1 : 0)

                CircularProgressBar(
                    progress: progressPercentage,
                    lineWidth: 17 * lockScale,
                    primaryColor: appTheme?.primaryColor ?? .cyan,
                    secondaryColor: appTheme?.secondaryColor ?? .orange
                )
                .frame(width: 238 * lockScale, height: 238 * lockScale)

                // Black gradient fill to hide glow behind content
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.black,
                                Color.black.opacity(0.95),
                                Color.black.opacity(0.85)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 115 * lockScale
                        )
                    )
                    .frame(width: 245 * lockScale, height: 245 * lockScale)

                VStack(spacing: 14 * lockScale) {
                    Image(systemName: isUnlocked ? "lock.open.fill" : "lock.fill")
                        .font(.system(size: 68 * lockScale))
                        .foregroundStyle(
                            LinearGradient(
                                colors: isUnlocked ? [appTheme?.primaryColor ?? .cyan, (appTheme?.primaryColor ?? .cyan).opacity(0.8)] : [.gray, .gray.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(isUnlocked ? 360 : 0))
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isUnlocked)

                    Text("\(problemsCompleted)/\(totalProblems)")
                        .font(.comfortaa(size: 41 * lockScale, weight: .bold))
                        .foregroundColor(.white)

                    Text("Problems Done")
                        .font(.comfortaa(size: 14 * lockScale, weight: .medium))
                        .foregroundColor(.gray)
                }
            }

            // Message under lock
            if isUnlocked {
                Text("🎉 Apps Unlocked! Great work today!")
                    .font(.comfortaa(size: 16, weight: .medium))
                    .foregroundColor(appTheme?.primaryColor ?? .cyan)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, -10)
            } else if problemsCompleted > 0 {
                Text("Keep going! \(totalProblems - problemsCompleted) more to unlock")
                    .font(.comfortaa(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, -10)
            } else {
                Text("Start solving to unlock your apps")
                    .font(.comfortaa(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, -10)
            }
        }
        .padding(.vertical)
    }
}

struct CircularProgressBar: View {
    let progress: Double
    let lineWidth: CGFloat
    var primaryColor: Color = .cyan
    var secondaryColor: Color = .orange
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.black, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: progress)
        }
    }
}

struct StreakBanner: View {
    let streak: Int
    
    var body: some View {
        HStack {
            Image(systemName: "flame.fill")
                .font(.system(size: 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text("\(streak) Day Streak!")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.2), Color.red.opacity(0.2)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
        )
    }
}

struct UnlockedMessageCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.leetCodeGreen)
            
            Text("Great Job!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("You've completed your daily goal. Your apps are now unlocked!")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.darkCard)
        .cornerRadius(12)
    }
}

struct MotivationCard: View {
    let remaining: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 32))
                .foregroundColor(.leetCodeOrange)
            
            Text("Keep Going!")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text("\(remaining) more problem\(remaining == 1 ? "" : "s") to unlock your apps")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.darkCard)
        .cornerRadius(12)
    }
}

#Preview {
    let settings = UserSettings()
    settings.dailyProblemGoal = 3
    
    let progress = DailyProgress()
    progress.problemsSolved = 1
    
    return LockProgressView(
        progress: progress,
        settings: settings,
        streakData: StreakData()
    )
}
