import SwiftUI
import SwiftData
import FamilyControls

struct OnboardingPage2: View {
    @Binding var navigationPath: NavigationPath
    @State private var authorizationStatus: AuthorizationStatus = .notDetermined
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
            
            Image(systemName: "hourglass.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, 20)
            
            Text("Screen Time Access")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text("LeetLock needs Screen Time permissions to block your selected apps until you complete your daily goals")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "lock.shield",
                    title: "Secure Blocking",
                    description: "Apps stay locked until goals are met"
                )
                
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Progress",
                    description: "Monitor your daily achievements"
                )
                
                FeatureRow(
                    icon: "flame.fill",
                    title: "Build Streaks",
                    description: "Stay motivated with daily streaks"
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 16) {
                if authorizationStatus == .approved {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.leetCodeGreen)
                        Text("Screen Time Access Granted")
                            .foregroundColor(.leetCodeGreen)
                    }
                    .font(.system(size: 16, weight: .medium))
                }
                
                Button(action: requestAuthorization) {
                    Text(authorizationStatus == .approved ? "Continue" : "Grant Access")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(authorizationStatus == .approved ? Color.leetCodeOrange : Color.leetCodeGreen)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        }
        .onAppear {
            checkAuthorizationStatus()
        }
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }
    
    private func requestAuthorization() {
        if authorizationStatus == .approved {
            navigationPath.append(OnboardingStep.appSelection)
        } else {
            Task {
                do {
                    try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                    await MainActor.run {
                        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
                        if authorizationStatus == .approved {
                            navigationPath.append(OnboardingStep.appSelection)
                        }
                    }
                } catch {
                    print("Authorization failed: \(error)")
                }
            }
        }
    }
}

#Preview {
    OnboardingPage2(navigationPath: .constant(NavigationPath()))
        .modelContainer(DataStore.createModelContainer())
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.leetCodeGreen)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.darkCard)
        .cornerRadius(12)
    }
}
