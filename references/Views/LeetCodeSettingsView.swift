import SwiftUI
import SwiftData

struct LeetCodeSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [LeetCodeSettings]
    
    @State private var username: String = ""
    @State private var isEnabled: Bool = false
    @State private var isVerifying: Bool = false
    @State private var verificationMessage: String = ""
    @State private var showVerificationAlert: Bool = false
    
    private var leetcodeSettings: LeetCodeSettings? {
        settings.first
    }
    
    var body: some View {
        Form {
            Section {
                Text("LeetCode Integration")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Earn bonus stats when solving LeetCode problems during Intelligence blocks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Setup")) {
                HStack {
                    Text("Username")
                    Spacer()
                    TextField("LeetCode username", text: $username)
                        .multilineTextAlignment(.trailing)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                if !username.isEmpty {
                    Button(action: verifyUsername) {
                        HStack {
                            if isVerifying {
                                ProgressView()
                                    .padding(.trailing, 4)
                            }
                            Text(isVerifying ? "Verifying..." : "Verify Username")
                        }
                    }
                    .disabled(isVerifying)
                }
            }
            
            Section(header: Text("Status")) {
                Toggle("Enable Integration", isOn: $isEnabled)
                    .disabled(username.isEmpty)
                
                if let settings = leetcodeSettings, settings.isConfigured() {
                    HStack {
                        Text("Last Verified")
                        Spacer()
                        if let lastValidated = settings.lastValidated {
                            Text(lastValidated, style: .relative)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Never")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section(header: Text("Bonus Settings")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bonus per problem: 10%")
                        .font(.caption)
                    Text("Maximum bonus: 50% (5+ problems)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Section(header: Text("How It Works")) {
                VStack(alignment: .leading, spacing: 12) {
                    BenefitRow(
                        icon: "checkmark.circle.fill",
                        text: "Complete Intelligence blocks as normal"
                    )
                    BenefitRow(
                        icon: "checkmark.circle.fill",
                        text: "Solve problems on LeetCode during block time"
                    )
                    BenefitRow(
                        icon: "checkmark.circle.fill",
                        text: "Get 10% bonus stats per problem (max 50%)"
                    )
                    BenefitRow(
                        icon: "checkmark.circle.fill",
                        text: "Verification happens automatically"
                    )
                }
                .font(.caption)
            }
            
            Section(header: Text("Example")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("2-hour Intelligence block, 3 tasks completed (75%)")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text("Base: 2 hrs × 0.5 × 75% = 0.75 stats")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("With 3 LeetCode problems: 0.75 × 1.3 = 0.975 stats")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("Bonus: +0.225 Intelligence")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("LeetCode")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadSettings)
        .onChange(of: username) { _, newValue in
            saveSettings()
        }
        .onChange(of: isEnabled) { _, newValue in
            saveSettings()
        }
        .alert("Verification Result", isPresented: $showVerificationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(verificationMessage)
        }
    }
    
    private func loadSettings() {
        if let settings = leetcodeSettings {
            username = settings.username
            isEnabled = settings.isEnabled
        }
    }
    
    private func saveSettings() {
        if let settings = leetcodeSettings {
            settings.username = username
            settings.isEnabled = isEnabled && !username.isEmpty
            try? modelContext.save()
        }
    }
    
    private func verifyUsername() {
        isVerifying = true
        
        Task {
            do {
                let isValid = try await LeetCodeService.verifyUsername(username)
                
                await MainActor.run {
                    isVerifying = false
                    if isValid {
                        verificationMessage = "✓ Username '\(username)' verified!\n\nYou can now enable the integration."
                        showVerificationAlert = true
                    } else {
                        verificationMessage = "❌ Username '\(username)' not found.\n\nPlease check the spelling and try again."
                        showVerificationAlert = true
                        username = ""
                    }
                }
            } catch {
                await MainActor.run {
                    isVerifying = false
                    verificationMessage = "⚠️ Verification failed.\n\nPlease check your internet connection and try again."
                    showVerificationAlert = true
                }
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)
            Text(text)
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        LeetCodeSettingsView()
            .modelContainer(DataStore.shared)
    }
}
