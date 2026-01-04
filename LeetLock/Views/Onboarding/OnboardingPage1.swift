import SwiftUI
import SwiftData

struct OnboardingPage1: View {
    @Binding var navigationPath: NavigationPath
    @Binding var userSettings: UserSettings?
    
    @State private var username = ""
    @State private var isVerifying = false
    @State private var verificationError: String?
    @State private var isVerified = false
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.leetCodeGreen, .leetCodeOrange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, 20)
            
            Text("Welcome to LeetLock")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text("Stay focused by locking your apps until you complete your daily LeetCode problems")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("LeetCode Username")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    HStack {
                        TextField("Enter username", text: $username)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color.darkCard)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .onChange(of: username) { oldValue, newValue in
                                isVerified = false
                                verificationError = nil
                            }
                        
                        if isVerified {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.leetCodeGreen)
                                .font(.system(size: 24))
                        }
                    }
                }
                
                if let error = verificationError {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.leetCodeRed)
                }
                
                Button(action: verifyUsername) {
                    HStack {
                        if isVerifying {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Verify Username")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(username.isEmpty ? Color.gray : Color.leetCodeGreen)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(username.isEmpty || isVerifying)
                
                Button(action: {
                    if isVerified {
                        navigationPath.append(OnboardingStep.screenTime)
                    }
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isVerified ? Color.leetCodeOrange : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isVerified)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        }
    }
    
    private func verifyUsername() {
        guard !username.isEmpty else { return }
        
        isVerifying = true
        verificationError = nil
        
        Task {
            do {
                let verified = try await LeetCodeService.verifyUsername(username)
                
                await MainActor.run {
                    isVerifying = false
                    if verified {
                        isVerified = true
                        userSettings?.leetcodeUsername = username
                        userSettings?.isUsernameVerified = true
                    } else {
                        verificationError = "Username not found"
                    }
                }
            } catch {
                await MainActor.run {
                    isVerifying = false
                    verificationError = "Failed to verify username"
                }
            }
        }
    }
}

#Preview {
    OnboardingPage1(
        navigationPath: .constant(NavigationPath()),
        userSettings: .constant(UserSettings())
    )
    .modelContainer(DataStore.createModelContainer())
}
