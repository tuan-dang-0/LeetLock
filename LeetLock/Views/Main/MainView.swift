import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userSettingsArray: [UserSettings]
    @Query private var dailyProgressArray: [DailyProgress]
    @Query private var streakDataArray: [StreakData]
    @Query private var appThemeArray: [AppTheme]
    
    @State private var isRefreshing = false
    
    private var userSettings: UserSettings? {
        userSettingsArray.first
    }
    
    private var todayProgress: DailyProgress? {
        dailyProgressArray.first(where: { $0.isToday() })
    }
    
    private var streakData: StreakData? {
        streakDataArray.first
    }
    
    private var appTheme: AppTheme? {
        appThemeArray.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 8) {
                        VStack(spacing: 4) {
                            Text("Swipe Down to Refresh")
                                .font(.comfortaa(size: 11))
                                .foregroundColor(.gray.opacity(0.6))
                            Image(systemName: "chevron.down")
                                .font(.comfortaa(size: 10))
                                .foregroundColor(.gray.opacity(0.6))
                        }
                        .padding(.top, 22)
                        
                        VStack(spacing: 16) {
                            if let settings = userSettings {
                                NextProblemCarousel()
                                    .padding(.horizontal, 24)
                                
                                LockProgressView(
                                    progress: todayProgress,
                                    settings: settings,
                                    streakData: streakData
                                )
                                .padding(.horizontal, 24)
                            }
                            
                            HeatmapView(username: userSettings?.leetcodeUsername ?? "")
                                .padding(.horizontal, 24)
                                .padding(.top, -8)
                                .frame(height: UIScreen.main.bounds.height * 0.25)
                        }
                    }
                }
                .refreshable {
                    await refreshProgress()
                }
                
                if isRefreshing {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: appTheme?.primaryColor ?? .cyan))
                        .scaleEffect(1.5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 75)
                        .padding(.top, 13)
                }
            }
        }
        .onAppear {
            // Configure navigation bar appearance to remove blur
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.darkBackground)
            appearance.shadowColor = .clear
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            
            AppBlockingService.initialize(modelContext: modelContext)
            // Only initialize shields, don't auto-refresh (rely on swipe down)
            updateShieldsBasedOnProgress()
        }
    }
    
    private func refreshProgress() async {
        guard let settings = userSettings,
              !settings.leetcodeUsername.isEmpty else { return }
        
        isRefreshing = true
        
        do {
            let progress = try await ProgressService.updateDailyProgress(
                username: settings.leetcodeUsername,
                modelContext: modelContext
            )
            
            let goalMet = ProgressService.checkGoalCompletion(
                progress: progress,
                goal: settings.dailyProblemGoal
            )
            
            progress.isGoalMet = goalMet
            
            ProgressService.updateStreakIfNeeded(
                goalMet: goalMet,
                modelContext: modelContext
            )
            
            try? modelContext.save()
            
            await MainActor.run {
                updateShieldsBasedOnProgress()
            }
        } catch {
            print("Failed to refresh progress: \(error)")
        }
        
        isRefreshing = false
    }
    
    private func updateShieldsBasedOnProgress() {
        guard let settings = userSettings else { return }
        
        let progress = todayProgress ?? DailyProgress()
        
        if ProgressService.shouldApplyShields(settings: settings, progress: progress) {
            AppBlockingService.applyShields()
        } else {
            AppBlockingService.removeShields()
        }
    }
}

#Preview {
    MainView()
        .modelContainer(DataStore.createModelContainer())
}
