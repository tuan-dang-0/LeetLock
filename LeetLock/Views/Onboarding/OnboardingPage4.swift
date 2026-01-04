import SwiftUI
import SwiftData

struct OnboardingPage4: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    @Query private var userSettingsArray: [UserSettings]
    
    @State private var problemGoalText = "1"
    @State private var selectedDays: Set<Int> = Set([1, 2, 3, 4, 5, 6, 7])
    @FocusState private var isTextFieldFocused: Bool
    
    private var userSettings: UserSettings? {
        userSettingsArray.first
    }
    
    let weekdays = [
        (1, "Sun"),
        (2, "Mon"),
        (3, "Tue"),
        (4, "Wed"),
        (5, "Thu"),
        (6, "Fri"),
        (7, "Sat")
    ]
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
                .onTapGesture {
                    isTextFieldFocused = false
                }
            
            VStack(spacing: 30) {
                Spacer()
            
            Image(systemName: "target")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, 20)
            
            Text("Set Your Daily Goal")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text("Choose how many LeetCode problems you want to solve daily and which days apps should be blocked")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("Daily Problem Goal")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack {
                        Spacer()
                        
                        TextField("", text: $problemGoalText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(Color.darkCard)
                            .cornerRadius(12)
                            .focused($isTextFieldFocused)
                            .onChange(of: problemGoalText) { oldValue, newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                let limited = String(filtered.prefix(2))
                                if limited != newValue {
                                    problemGoalText = limited
                                }
                                if let number = Int(limited), number > 20 {
                                    problemGoalText = "20"
                                } else if limited == "0" {
                                    problemGoalText = "0"
                                } else if limited.isEmpty {
                                    problemGoalText = "0"
                                }
                            }
                        
                        Spacer()
                    }
                    
                    Text("problems per day")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 16) {
                    Text("Active Days")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        ForEach(weekdays, id: \.0) { day in
                            DayButton(
                                day: day.1,
                                isSelected: selectedDays.contains(day.0),
                                action: {
                                    if selectedDays.contains(day.0) {
                                        selectedDays.remove(day.0)
                                    } else {
                                        selectedDays.insert(day.0)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: completeOnboarding) {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.leetCodeGreen, .leetCodeOrange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        }
    }
    
    private func completeOnboarding() {
        guard let settings = userSettings else {
            print("❌ No user settings found")
            return
        }
        
        var goalValue = Int(problemGoalText) ?? 1
        if goalValue == 0 {
            goalValue = 1
        }
        
        settings.dailyProblemGoal = goalValue
        settings.activeDays = selectedDays
        settings.hasCompletedOnboarding = true
        settings.lastUpdated = Date()
        
        do {
            try modelContext.save()
            print("✅ Onboarding completed and saved successfully")
            print("   Goal: \(goalValue), Days: \(selectedDays), Completed: \(settings.hasCompletedOnboarding)")
        } catch {
            print("❌ Failed to save onboarding: \(error)")
        }
    }
}

struct DayButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(width: 44, height: 44)
                .background(isSelected ? Color.leetCodeGreen : Color.darkCard)
                .cornerRadius(22)
        }
    }
}

#Preview {
    OnboardingPage4(navigationPath: .constant(NavigationPath()))
        .modelContainer(DataStore.createModelContainer())
}
