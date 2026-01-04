import SwiftUI
import SwiftData
import FamilyControls
import ManagedSettings
import Combine

struct SimplifiedBlockedAppsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @State private var showingAppPicker = false
    @State private var selection = FamilyActivitySelection()
    @State private var refreshTrigger = false
    
    var blockedAppCount: Int {
        _ = refreshTrigger // Trigger recomputation
        return AppBlockingService.getBlockedAppCount()
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !screenTimeManager.isAuthorized {
                    Section {
                        permissionBanner
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                Section {
                    Text("Select apps to block at all times. You'll need reward minutes to access them.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Blocked Apps") {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.orange)
                        Text("\(blockedAppCount) app\(blockedAppCount == 1 ? "" : "s") blocked")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    if screenTimeManager.isAuthorized {
                        Button(action: {
                            selection = AppBlockingService.getCurrentSelection()
                            showingAppPicker = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Blocked Apps")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Blocked Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .familyActivityPicker(isPresented: $showingAppPicker, selection: $selection)
            .onChange(of: selection) { oldValue, newValue in
                // Update the blocking service with the new selection
                AppBlockingService.updateBlockedAppsSelection(newValue)
                refreshTrigger.toggle()
            }
        }
    }
    
    private var permissionBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "hourglass.badge.plus")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Screen Time Permission Required")
                .font(.headline)
            
            Text("Grant Screen Time permission to browse and select apps from your device")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    await screenTimeManager.requestAuthorization()
                }
            }) {
                Text("Grant Permission")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
    }
}

class ScreenTimeManager: ObservableObject {
    @Published var isAuthorized = false
    private let center = AuthorizationCenter.shared
    
    init() {
        Task {
            await checkAuthorizationAsync()
        }
    }
    
    func checkAuthorization() {
        isAuthorized = center.authorizationStatus == .approved
    }
    
    @MainActor
    func checkAuthorizationAsync() async {
        isAuthorized = center.authorizationStatus == .approved
    }
    
    func requestAuthorization() async {
        do {
            try await center.requestAuthorization(for: .individual)
            await MainActor.run {
                checkAuthorization()
            }
        } catch {
            print("Failed to request Screen Time authorization: \(error)")
        }
    }
}
