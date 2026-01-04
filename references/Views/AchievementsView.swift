import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query private var achievements: [Achievement]
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var wallets: [RewardWallet]
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var wallet: RewardWallet? {
        wallets.first
    }
    
    private var achievementsByCategory: [(category: AchievementCategory, achievements: [Achievement])] {
        let grouped = Dictionary(grouping: achievements, by: { $0.category })
        return grouped.map { (category: $0.key, achievements: $0.value.sorted { achievement1, achievement2 in
            // Completed/claimable first, then by requirement
            if achievement1.canClaim != achievement2.canClaim {
                return achievement1.canClaim
            }
            if achievement1.isClaimed != achievement2.isClaimed {
                return achievement1.isClaimed && !achievement2.isClaimed
            }
            return achievement1.requirement < achievement2.requirement
        }) }
            .sorted { $0.category < $1.category }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Achievements")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Login Days
                if let loginAchievements = achievementsByCategory.first(where: { $0.category == .loginDays })?.achievements {
                    achievementSection(title: "Login Milestones", achievements: loginAchievements)
                }
                
                // Work Hours
                if let workAchievements = achievementsByCategory.first(where: { $0.category == .workHours })?.achievements {
                    achievementSection(title: "Work Hour Milestones", achievements: workAchievements)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func achievementSection(title: String, achievements: [Achievement]) -> some View {
        let sortedAchievements = achievements.sorted { $0.requirement < $1.requirement }
        let nextMilestone = sortedAchievements.first { !$0.isClaimed }
        let completedMilestones = sortedAchievements.filter { $0.isClaimed }
        
        // Find previous milestone requirement for progress calculation
        let previousRequirement: Int = {
            if let next = nextMilestone,
               let index = sortedAchievements.firstIndex(where: { $0.id == next.id }),
               index > 0 {
                return sortedAchievements[index - 1].requirement
            }
            return 0
        }()
        
        return VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            // Show next unclaimed milestone
            if let next = nextMilestone {
                AchievementRow(
                    achievement: next,
                    previousRequirement: previousRequirement,
                    onClaim: {
                        claimAchievement(next)
                    }
                )
            } else {
                Text("All milestones completed! 🎉")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            // Show completed section if any
            if !completedMilestones.isEmpty {
                DisclosureGroup {
                    ForEach(completedMilestones.indices, id: \.self) { index in
                        let achievement = completedMilestones[index]
                        let prevReq = index > 0 ? completedMilestones[index - 1].requirement : 0
                        AchievementRow(
                            achievement: achievement,
                            previousRequirement: prevReq,
                            onClaim: {
                                claimAchievement(achievement)
                            }
                        )
                    }
                } label: {
                    HStack {
                        Text("Completed (\(completedMilestones.count))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func claimAchievement(_ achievement: Achievement) {
        guard achievement.canClaim, let profile = profile, let wallet = wallet else { return }
        
        // Award rewards
        for reward in achievement.rewards {
            switch reward {
            case .minutes(let amount):
                wallet.availableMinutes += amount
            case .xp(let amount):
                profile.addBonusExperience(amount, modelContext: modelContext)
            }
        }
        
        achievement.isClaimed = true
        try? modelContext.save()
    }
}

struct AchievementRow: View {
    @Bindable var achievement: Achievement
    let previousRequirement: Int
    let onClaim: () -> Void
    
    private var displayProgress: Int {
        max(0, achievement.currentProgress - previousRequirement)
    }
    
    private var displayTarget: Int {
        achievement.requirement - previousRequirement
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row: Title and progress
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.title)
                        .font(.headline)
                    
                    Text(achievement.achievementDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(displayProgress)/\(displayTarget)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            // Rewards and claim button row
            HStack(spacing: 12) {
                // Reward icons
                ForEach(achievement.rewards.indices, id: \.self) { index in
                    let reward = achievement.rewards[index]
                    HStack(spacing: 4) {
                        Image(systemName: reward.iconName)
                            .foregroundColor(rewardColor(reward))
                        Text(reward.displayText)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(rewardColor(reward).opacity(0.2))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Claim button
                if achievement.canClaim {
                    Button(action: onClaim) {
                        Text("Claim")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                } else if achievement.isClaimed {
                    Text("Claimed")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                } else {
                    Text("Locked")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
            }
            
            // Progress bar
            ProgressView(value: achievement.progressPercent)
                .tint(achievement.isUnlocked ? .green : .appAccent)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func rewardColor(_ reward: AchievementReward) -> Color {
        switch reward {
        case .minutes:
            return .appAccent
        case .xp:
            return .purple
        }
    }
}

#Preview {
    AchievementsView()
        .modelContainer(DataStore.shared)
}
