import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var navigationPath = NavigationPath()
    @State private var userSettings: UserSettings?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                
                OnboardingPage1(navigationPath: $navigationPath, userSettings: $userSettings)
                    .navigationDestination(for: OnboardingStep.self) { step in
                        switch step {
                        case .screenTime:
                            OnboardingPage2(navigationPath: $navigationPath)
                        case .appSelection:
                            OnboardingPage3(navigationPath: $navigationPath)
                        case .goalConfiguration:
                            OnboardingPage4(navigationPath: $navigationPath)
                        }
                    }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            let descriptor = FetchDescriptor<UserSettings>()
            if let existing = try? modelContext.fetch(descriptor).first {
                userSettings = existing
            } else {
                let newSettings = UserSettings()
                modelContext.insert(newSettings)
                userSettings = newSettings
            }
        }
    }
}

enum OnboardingStep: Hashable {
    case screenTime
    case appSelection
    case goalConfiguration
}

#Preview {
    OnboardingContainerView()
        .modelContainer(DataStore.createModelContainer())
}
