import SwiftUI
import SwiftData
import FamilyControls

struct OnboardingPage3: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    
    @State private var isPickerPresented = false
    @State private var selectedApps = FamilyActivitySelection()
    @State private var blockedAppCount = 0
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
            
            Image(systemName: "app.badge.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, 20)
            
            Text("Choose Apps to Block")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text("Select the most distracting apps that you want locked until you complete your daily LeetCode goals")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 20) {
                if blockedAppCount > 0 {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.leetCodeGreen)
                        Text("\(blockedAppCount) app\(blockedAppCount == 1 ? "" : "s") selected")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.darkCard)
                    .cornerRadius(12)
                } else {
                    Text("No apps selected yet")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.darkCard)
                        .cornerRadius(12)
                }
                
                Button(action: { isPickerPresented = true }) {
                    HStack {
                        Image(systemName: blockedAppCount > 0 ? "pencil" : "plus.circle.fill")
                        Text(blockedAppCount > 0 ? "Edit Selected Apps" : "Select Apps")
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.leetCodeGreen)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .familyActivityPicker(
                    isPresented: $isPickerPresented,
                    selection: $selectedApps
                )
                
                Button(action: {
                    saveBlockedApps()
                    navigationPath.append(OnboardingStep.goalConfiguration)
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(blockedAppCount > 0 ? Color.leetCodeOrange : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(blockedAppCount == 0)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        }
        .onChange(of: selectedApps) { oldValue, newValue in
            blockedAppCount = newValue.applicationTokens.count
        }
        .onAppear {
            AppBlockingService.initialize(modelContext: modelContext)
            selectedApps = AppBlockingService.getCurrentSelection()
            blockedAppCount = selectedApps.applicationTokens.count
        }
    }
    
    private func saveBlockedApps() {
        AppBlockingService.updateBlockedAppsSelection(selectedApps)
    }
}

struct OnboardingPage3_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPage3(navigationPath: .constant(NavigationPath()))
            .modelContainer(DataStore.createModelContainer())
    }
}
