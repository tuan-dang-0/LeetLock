import SwiftUI
import SwiftData
import FamilyControls
import Combine

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var userSettingsArray: [UserSettings]
    @Query private var settingsLockArray: [SettingsLock]
    @Query private var appThemeArray: [AppTheme]
    
    @State private var username = ""
    @State private var newUsername = ""
    @State private var showingUsernameAlert = false
    @State private var isVerifying = false
    @State private var verificationError: String?
    @State private var dailyGoal = 1
    @State private var selectedDays: Set<Int> = []
    @State private var showingAppPicker = false
    @State private var selectedApps = FamilyActivitySelection()
    @State private var blockedAppCount = 0
    @State private var currentTime = Date()
    @State private var primaryColor: Color = Color(hex: "00CED1")
    @State private var secondaryColor: Color = Color(hex: "FF8C00")
    
    private var settingsLock: SettingsLock? {
        settingsLockArray.first
    }
    
    private var isSettingsUnlocked: Bool {
        guard let lock = settingsLock else { return true }
        lock.checkAndLockIfExpired()
        return lock.isUnlocked
    }
    
    private var appTheme: AppTheme? {
        appThemeArray.first
    }
    
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
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        accountSection
                        
                        changeLockSection
                        
                        goalSection
                        
                        scheduleSection
                        
                        blockedAppsSection
                        
                        themeSection
                        
                        aboutSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            loadSettings()
            // Check lock state on appear in case time passed while away
            if let lock = settingsLock {
                lock.checkAndLockIfExpired()
                try? modelContext.save()
            }
        }
        .onDisappear {
            // Save lock state when leaving settings
            if let lock = settingsLock {
                lock.checkAndLockIfExpired()
                try? modelContext.save()
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            currentTime = Date()
            if let lock = settingsLock {
                lock.checkAndLockIfExpired()
                try? modelContext.save()
            }
        }
        .alert("Change Username", isPresented: $showingUsernameAlert) {
            TextField("New Username", text: $newUsername)
            Button("Cancel", role: .cancel) { }
            Button("Verify") {
                Task { await changeUsername() }
            }
        } message: {
            Text("Enter your new LeetCode username. We'll verify it before updating.")
        }
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Account", icon: "person.circle.fill")
            
            VStack(spacing: 12) {
                HStack {
                    Text("Username")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(username.isEmpty ? "Not set" : username)
                        .foregroundColor(.white)
                    
                    if userSettings?.isUsernameVerified == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(appTheme?.primaryColor ?? .cyan)
                    }
                }
                
                Button(action: { showingUsernameAlert = true }) {
                    Text("Change Username")
                        .font(.comfortaa(size: 14))
                        .foregroundColor(appTheme?.secondaryColor ?? .orange)
                }
            }
            .padding()
            .background(Color.darkCard)
            .cornerRadius(12)
        }
    }
    
    private var changeLockSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Change Lock", icon: "lock.fill")
            
            VStack(spacing: 16) {
                Text("Settings below are locked for stability. Unlock temporarily for emergencies only.")
                    .font(.comfortaa(size: 14))
                    .foregroundColor(.gray)
                
                if let lock = settingsLock {
                    if lock.isUnlocked, let remaining = lock.remainingUnlockTime() {
                        HStack {
                            Image(systemName: "lock.open.fill")
                                .foregroundColor(appTheme?.primaryColor ?? .cyan)
                            Text("Unlocked for \(formatTime(remaining))")
                                .font(.comfortaa(size: 14, weight: .medium))
                                .foregroundColor(appTheme?.primaryColor ?? .cyan)
                            Spacer()
                        }
                        .padding()
                        .background((appTheme?.primaryColor ?? .cyan).opacity(0.1))
                        .cornerRadius(8)
                    } else if let cooldown = lock.remainingCooldownTime() {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.orange)
                            Text("Next unlock in \(formatTime(cooldown))")
                                .font(.comfortaa(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    } else {
                        Button(action: unlockSettings) {
                            HStack {
                                Image(systemName: "lock.open.fill")
                                Text("Unlock Settings (10 min)")
                            }
                            .font(.comfortaa(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(appTheme?.secondaryColor ?? .orange)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
            .background(Color.darkCard)
            .cornerRadius(12)
        }
    }
    
    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Daily Goal", icon: "target")
            
            VStack(spacing: 16) {
                HStack {
                    Text("Problems per Day")
                        .foregroundColor(isSettingsUnlocked ? .white : .gray)
                    Spacer()
                    
                    Picker("", selection: $dailyGoal) {
                        ForEach(1...20, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(appTheme?.primaryColor ?? .cyan)
                    .disabled(!isSettingsUnlocked)
                    .onChange(of: dailyGoal) { _, newValue in
                        if let settings = userSettings {
                            settings.dailyProblemGoal = newValue
                            settings.lastUpdated = Date()
                            try? modelContext.save()
                        }
                    }
                }
            }
            .padding()
            .background(Color.darkCard)
            .cornerRadius(12)
        }
    }
    
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Active Days", icon: "calendar")
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Apps will be blocked on selected days")
                    .font(.comfortaa(size: 14))
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    ForEach(weekdays, id: \.0) { day in
                        DayToggleButton(
                            day: day.1,
                            isSelected: selectedDays.contains(day.0),
                            isEnabled: isSettingsUnlocked,
                            action: {
                                if selectedDays.contains(day.0) {
                                    selectedDays.remove(day.0)
                                } else {
                                    selectedDays.insert(day.0)
                                }
                                // Auto-save and update shields immediately
                                if let settings = userSettings {
                                    settings.activeDays = selectedDays
                                    settings.lastUpdated = Date()
                                    try? modelContext.save()
                                    AppBlockingService.initialize(modelContext: modelContext)
                                    updateShieldsBasedOnSettings()
                                }
                            }
                        )
                    }
                }
            }
            .padding()
            .background(Color.darkCard)
            .cornerRadius(12)
            .opacity(isSettingsUnlocked ? 1.0 : 0.5)
        }
    }
    
    private var blockedAppsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Blocked Apps", icon: "app.badge")
            
            VStack(spacing: 12) {
                HStack {
                    Text("Selected Apps")
                        .foregroundColor(isSettingsUnlocked ? .white : .gray)
                    Spacer()
                    Text("\(blockedAppCount) apps")
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .background(Color.darkAccent)
                
                Button(action: { showingAppPicker = true }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Blocked Apps")
                    }
                    .font(.comfortaa(size: 14))
                    .foregroundColor(isSettingsUnlocked ? appTheme?.primaryColor ?? .cyan : .gray)
                }
                .disabled(!isSettingsUnlocked)
                .familyActivityPicker(
                    isPresented: $showingAppPicker,
                    selection: $selectedApps
                )
                .onChange(of: selectedApps) { _, newSelection in
                    AppBlockingService.updateBlockedAppsSelection(newSelection)
                    blockedAppCount = newSelection.applicationTokens.count
                    updateShieldsBasedOnSettings()
                }
            }
            .padding()
            .background(Color.darkCard)
            .cornerRadius(12)
        }
    }
    
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Theme Colors", icon: "paintpalette.fill")
            
            VStack(spacing: 16) {
                ColorPickerSection(
                    primaryColor: $primaryColor,
                    secondaryColor: $secondaryColor,
                    onColorChange: saveThemeColors
                )
            }
            .padding()
            .background(Color.darkCard)
            .cornerRadius(12)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "About", icon: "info.circle.fill")
            
            VStack(spacing: 12) {
                SettingsRow(title: "Version", value: "1.0.0")
                
                Divider()
                    .background(Color.darkAccent)
                
                Button(action: { }) {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.darkCard)
            .cornerRadius(12)
        }
    }
    
    private func loadSettings() {
        if let settings = userSettings {
            username = settings.leetcodeUsername
            dailyGoal = settings.dailyProblemGoal
            selectedDays = settings.activeDays
        }
        
        // Initialize SettingsLock if it doesn't exist
        if settingsLock == nil {
            let newLock = SettingsLock()
            modelContext.insert(newLock)
            try? modelContext.save()
        }
        
        // Initialize AppTheme if it doesn't exist
        if appTheme == nil {
            let newTheme = AppTheme()
            modelContext.insert(newTheme)
            try? modelContext.save()
        }
        
        // Load theme colors
        if let theme = appTheme {
            primaryColor = theme.primaryColor
            secondaryColor = theme.secondaryColor
        }
        
        AppBlockingService.initialize(modelContext: modelContext)
        selectedApps = AppBlockingService.getCurrentSelection()
        blockedAppCount = selectedApps.applicationTokens.count
    }
    
    private func unlockSettings() {
        guard let lock = settingsLock, lock.canUnlock() else { return }
        lock.unlock()
        try? modelContext.save()
    }
    
    private func changeUsername() async {
        guard !newUsername.isEmpty else { return }
        
        isVerifying = true
        verificationError = nil
        
        do {
            let isValid = try await LeetCodeService.verifyUsername(newUsername)
            
            if isValid {
                if let settings = userSettings {
                    settings.leetcodeUsername = newUsername
                    settings.isUsernameVerified = true
                    username = newUsername
                    try? modelContext.save()
                    
                    // Refresh progress data with new username
                    _ = try await ProgressService.updateDailyProgress(
                        username: newUsername,
                        modelContext: modelContext
                    )
                    try? modelContext.save()
                }
            } else {
                verificationError = "Username not found on LeetCode"
            }
        } catch {
            verificationError = "Failed to verify username: \(error.localizedDescription)"
        }
        
        isVerifying = false
        newUsername = ""
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        } else {
            return "\(minutes)m \(secs)s"
        }
    }
    
    private func saveThemeColors() {
        guard let theme = appTheme else { return }
        theme.primaryColorHex = primaryColor.toHex()
        theme.secondaryColorHex = secondaryColor.toHex()
        try? modelContext.save()
    }
    
    private func updateShieldsBasedOnSettings() {
        guard let settings = userSettings else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyProgress>(
            predicate: #Predicate { progress in
                progress.date == today
            }
        )
        
        let progress = (try? modelContext.fetch(descriptor).first) ?? DailyProgress()
        
        if ProgressService.shouldApplyShields(settings: settings, progress: progress) {
            AppBlockingService.applyShields()
        } else {
            AppBlockingService.removeShields()
        }
    }
    
    
    private func openLeetCode() {
        if let url = URL(string: "https://leetcode.com") {
            UIApplication.shared.open(url)
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    @Query private var appThemeArray: [AppTheme]
    
    private var appTheme: AppTheme? {
        appThemeArray.first
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(appTheme?.primaryColor ?? .cyan)
            Text(title)
                .font(.comfortaa(size: 20, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct SettingsRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}

struct DayToggleButton: View {
    let day: String
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void
    @Query private var appThemeArray: [AppTheme]
    
    private var appTheme: AppTheme? {
        appThemeArray.first
    }
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(.comfortaa(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? appTheme?.primaryColor ?? .cyan : Color.darkAccent)
                .cornerRadius(8)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    SettingsView()
        .modelContainer(DataStore.createModelContainer())
}
