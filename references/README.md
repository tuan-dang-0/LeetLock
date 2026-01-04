# Reference Files for LeetCode App Blocker

This folder contains reference files from the ProductivityRPG app that are relevant for building a LeetCode-focused app blocker. These files provide implementations for the core features you requested.

## 📁 Folder Structure

```
references/
├── Models/          # Data models for SwiftData persistence
├── Views/           # SwiftUI view components
├── Services/        # Business logic and API integrations
└── Utilities/       # Helper functions and extensions
```

---

## 🎯 Feature Mapping

### 1. **Streak Tracking**

**Models:**
- `StreakTracker.swift` - Complete streak tracking implementation
  - Tracks current and longest streaks
  - Handles daily completion logic
  - Milestone tracking (3, 7, 14, 30, 60, 90, 180, 365 days)
  - Automatic streak reset if days are missed

**Views:**
- `DailyLoginView.swift` - Visual streak display
  - Flame icon with current streak count
  - Total logins counter
  - Last 7 days history calendar view
  - Checkmarks for completed days

---

### 2. **Achievements**

**Models:**
- `Achievement.swift` - Full achievement system
  - Multiple categories (Login Days, Work Hours, Streak, etc.)
  - Progress tracking
  - Unlock and claim states
  - Reward system (minutes, XP)
  - Progress percentage calculation

**Views:**
- `AchievementsView.swift` - Complete achievements UI
  - Grouped by category
  - Next milestone display
  - Completed achievements section
  - Claim button with rewards
  - Progress bars
  - Beautiful card-based layout

---

### 3. **Banner for Achievements / Daily Login**

**Views:**
- `FirstLoginBanner.swift` - Animated banner component
  - Appears on first login of the day
  - Gradient background (customizable)
  - Star icon with welcome message
  - Dismissible with animation
  - Slide-in from top with fade effect

**Models:**
- `DailyLogin.swift` - Daily login tracking
  - Records all login dates
  - Consecutive days counter
  - Total logins tracker
  - Automatic streak calculation

---

### 4. **Screen Time Locking**

**Models:**
- `BlockedApp.swift` - Individual app blocking model
  - Bundle identifier storage
  - Display name
  - Block status toggle
  - Creation timestamp

- `BlockedAppSelection.swift` - FamilyControls integration
  - Persists app selection data
  - Converts to/from FamilyActivitySelection
  - Last updated timestamp

**Services:**
- `AppBlockingService.swift` - Complete blocking implementation
  - Uses ManagedSettings and FamilyControls frameworks
  - Apply/remove shields dynamically
  - Persist blocked app selection
  - Count blocked apps
  - Shield reapplication after rewards

**Views:**
- `SimplifiedBlockedAppsView.swift` - App selection UI
  - Screen Time permission request
  - FamilyActivityPicker integration
  - Blocked app count display
  - Edit blocked apps functionality
  - Authorization status handling

---

### 5. **LeetCode API Validation**

**Models:**
- `LeetCodeSettings.swift` - LeetCode configuration
  - Username storage
  - Enable/disable toggle
  - Bonus multiplier settings
  - Last validation timestamp

- `DailyProgress.swift` - Daily problem tracking
  - LeetCode problems solved count
  - Verification status
  - Date normalization
  - Last updated timestamp

**Services:**
- `LeetCodeService.swift` - Complete LeetCode API integration
  - GraphQL API queries
  - Username verification
  - Recent submissions fetching
  - Daily progress tracking
  - Activity validation within timeframes
  - Bonus multiplier calculation
  - Error handling

- `RequirementService.swift` - Requirement checking logic
  - Daily goal validation
  - Progress status tracking
  - Redemption blocking
  - Cache management (5-minute refresh)
  - API result verification

**Views:**
- `LeetCodeSettingsView.swift` - Settings interface
  - Username input and verification
  - Enable/disable integration
  - Bonus calculation display
  - How it works guide
  - Example calculations
  - Last verified timestamp

---

## 🛠️ Utilities

**ColorExtensions.swift**
- Hex color initialization
- Pastel and dark mode color palettes
- Luminance calculation
- Contrasting text color logic
- App accent color from UserDefaults

**DateUtils.swift**
- Same day comparison
- Start of day calculation
- Time creation helpers
- 5-minute rounding

**Formatters.swift**
- Time and date formatters
- Time range formatting
- Percentage formatting

**ModelContainer.swift**
- SwiftData schema configuration
- Model container creation
- Database initialization
- Schema migration handling
- Error recovery with database reset

---

## 🔧 Implementation Notes

### For Your LeetCode App Blocker:

1. **Core Flow:**
   - User sets daily LeetCode problem goal (e.g., 3 problems)
   - Apps are blocked by default using `AppBlockingService`
   - `LeetCodeService` validates progress throughout the day
   - Apps unlock when goal is reached via `RequirementService`
   - Streak continues if daily goal is met

2. **Key Integrations:**
   - **FamilyControls** - Required for app blocking (iOS 15+)
   - **ManagedSettings** - Shield application and management
   - **SwiftData** - Modern persistence framework
   - **LeetCode GraphQL API** - No authentication required for public profiles

3. **SwiftData Models to Use:**
   ```swift
   - StreakTracker
   - Achievement
   - DailyLogin
   - DailyProgress
   - LeetCodeSettings
   - BlockedApp
   - BlockedAppSelection
   ```

4. **Essential Services:**
   ```swift
   - AppBlockingService (manages shields)
   - LeetCodeService (API calls)
   - RequirementService (validates daily goals)
   ```

5. **Permission Requirements:**
   - Screen Time API authorization (FamilyControls)
   - Add to Info.plist:
     ```xml
     <key>NSFamilyControlsUsageDescription</key>
     <string>Required to block apps until daily goals are met</string>
     ```

---

## 📱 Recommended App Architecture

```
LeetCodeBlockerApp/
├── Models/
│   ├── StreakTracker.swift
│   ├── DailyProgress.swift
│   ├── Achievement.swift
│   ├── BlockedAppSelection.swift
│   └── AppSettings.swift
│
├── Views/
│   ├── HomeView.swift (show progress, streak, unlock status)
│   ├── BlockedAppsView.swift (app selection)
│   ├── AchievementsView.swift (milestones)
│   ├── StreakView.swift (calendar)
│   └── SettingsView.swift (goals, LeetCode username)
│
├── Services/
│   ├── LeetCodeService.swift (API validation)
│   ├── AppBlockingService.swift (shield management)
│   └── ProgressService.swift (daily goal checking)
│
└── Utilities/
    ├── DateUtils.swift
    ├── ColorExtensions.swift
    └── Formatters.swift
```

---

## 🚀 Quick Start Checklist

- [ ] Copy models to your new project
- [ ] Set up SwiftData container with required models
- [ ] Request Screen Time authorization
- [ ] Implement app blocking with FamilyControls
- [ ] Integrate LeetCode API service
- [ ] Create daily progress tracking
- [ ] Add streak tracking logic
- [ ] Build achievement system
- [ ] Design unlock flow based on daily goal
- [ ] Add celebration banners and animations

---

## 💡 Feature Ideas for Your App

1. **Progressive Unlocking**: Unlock apps one at a time as you solve problems
2. **Weekend Mode**: Different goals for weekends
3. **Difficulty Bonuses**: Extra unlocks for Hard problems
4. **Study Streaks**: Bonus time for maintaining streaks
5. **Achievement Rewards**: Unlock permanent features
6. **Leaderboards**: Compare with friends (optional)
7. **Custom Schedules**: Different goals for different days
8. **Emergency Override**: Unlock for X minutes with penalty

---

## 📚 Additional Resources

- [FamilyControls Documentation](https://developer.apple.com/documentation/familycontrols)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [LeetCode GraphQL API](https://leetcode.com/graphql)
- [ManagedSettings Framework](https://developer.apple.com/documentation/managedsettings)

---

**Note**: All files have been tested and are production-ready from the ProductivityRPG application. Adjust as needed for your specific use case.
