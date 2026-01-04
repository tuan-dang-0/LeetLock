# LeetLock - iOS App Blocker for LeetCode

> Stay focused by locking your apps until you complete your daily LeetCode problems

## 🎯 Features

### ✅ Implemented

- **4-Page Onboarding Flow**
  - Page 1: LeetCode username verification
  - Page 2: Screen Time permission request
  - Page 3: App selection for blocking
  - Page 4: Daily goal and schedule configuration

- **Main Dashboard**
  - Giant animated lock with circular progress bar
  - Real-time progress tracking (x/x problems solved)
  - Lock unlocks and turns green when goal is complete
  - Submission heatmap showing last 49 days
  - Next problem suggestion card
  - Streak tracker with animated flame icon

- **Settings Page**
  - Change daily problem goal (1-20)
  - Configure active days (select weekdays)
  - Edit blocked apps
  - View account info

- **LeetCode GraphQL API Integration**
  - Username verification
  - Real-time submission tracking
  - Daily progress monitoring
  - Submission heatmap generation

- **Screen Time Integration**
  - FamilyControls framework for app blocking
  - Shields applied until daily goals are met
  - Automatic unlock when goals are completed

- **Streak & Progress Tracking**
  - Current and longest streak tracking
  - Daily submission history
  - Automatic streak updates

## 🏗️ Project Structure

```
LeetLock/
├── Models/
│   ├── UserSettings.swift          # User configuration
│   ├── DailyProgress.swift         # Daily problem tracking
│   ├── BlockedAppSelection.swift   # Blocked app persistence
│   └── StreakData.swift            # Streak tracking
│
├── Services/
│   ├── LeetCodeService.swift       # LeetCode GraphQL API
│   ├── AppBlockingService.swift    # Screen Time blocking
│   └── ProgressService.swift       # Progress management
│
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingContainerView.swift
│   │   ├── OnboardingPage1.swift   # Username verification
│   │   ├── OnboardingPage2.swift   # Screen Time permissions
│   │   ├── OnboardingPage3.swift   # App selection
│   │   └── OnboardingPage4.swift   # Goal configuration
│   │
│   ├── Main/
│   │   ├── MainView.swift          # Main dashboard
│   │   ├── LockProgressView.swift  # Lock & progress UI
│   │   ├── HeatmapView.swift       # Submission heatmap
│   │   └── NextProblemSuggestion.swift
│   │
│   └── Settings/
│       └── SettingsView.swift      # Settings page
│
└── Utilities/
    ├── DataStore.swift             # SwiftData container
    └── ColorExtensions.swift       # Color palette
```

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 16.0 or later (for Screen Time API)
- Valid Apple Developer account (for Screen Time entitlements)

### Setup Instructions

1. **Add Capabilities**
   - Open project in Xcode
   - Select your target → Signing & Capabilities
   - Click "+ Capability"
   - Add **"Family Controls"**

2. **Configure Info.plist**
   - The Info.plist file is already created with the required permissions
   - Ensure `NSFamilyControlsUsageDescription` is present

3. **Build and Run**
   - Select your device/simulator
   - Build and run (⌘R)
   - Complete onboarding flow

### First Launch

1. Enter your LeetCode username
2. Tap "Verify Username"
3. Grant Screen Time permissions
4. Select apps to block
5. Set your daily goal and active days
6. Start coding!

## 🎨 Design & Animations

### Color Scheme

The app uses a dark mode design with:
- **Background**: `#1A1A1A`
- **Cards**: `#2A2A2A`
- **Accent**: `#3A3A3A`
- **LeetCode Green**: `#00B8A3`
- **LeetCode Orange**: `#FFA116`
- **LeetCode Red**: `#EF4743`

### Native Animations

SwiftUI provides beautiful native animations:

1. **Lock Animation**
   - Rotates 360° when unlocked
   - Spring animation with bounce effect
   - Color gradient transition

2. **Progress Bar**
   - Circular progress with gradient stroke
   - Smooth spring animation
   - Round line caps

3. **Streak Flame**
   - SF Symbol with gradient fill
   - Orange to red gradient
   - Pulsing effect possible

### Enhancing Visuals

To add more 3D-ish effects and animations:

```swift
// 3D Rotation Effect
.rotation3DEffect(.degrees(30), axis: (x: 1, y: 0, z: 0))

// Shadow for depth
.shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

// Particles for celebrations
// Use SwiftUI Particles or custom particle systems

// Lottie Animations (Optional)
// Add Lottie-iOS package for JSON animations
// Great for fire effects, confetti, etc.
```

### Recommended Enhancement Packages

1. **[Lottie-iOS](https://github.com/airbnb/lottie-ios)** - JSON-based animations
2. **[SwiftUI-Introspect](https://github.com/siteline/SwiftUI-Introspect)** - Access UIKit views
3. **[ConfettiSwiftUI](https://github.com/simibac/ConfettiSwiftUI)** - Celebration effects

## 📱 How It Works

### Daily Flow

1. **Morning**: Apps are blocked based on your schedule
2. **Solve Problems**: Open LeetCode and solve problems
3. **Pull to Refresh**: Update your progress in the app
4. **Unlock**: Apps unlock automatically when goal is met
5. **Streak**: Maintain streaks by completing daily goals

### API Integration

The app uses LeetCode's public GraphQL API:

```graphql
query getRecentSubmissions($username: String!, $limit: Int!) {
  recentSubmissionList(username: $username, limit: $limit) {
    title
    titleSlug
    timestamp
    statusDisplay
    lang
  }
}
```

### App Blocking

Uses Apple's FamilyControls and ManagedSettings frameworks:

```swift
// Apply shields
store.shield.applications = selectedApps

// Remove shields
store.shield.applications = nil
```

## 🔧 Customization

### Changing Daily Goal Range

In `OnboardingPage4.swift` and `SettingsView.swift`:

```swift
ForEach(1...20, id: \.self) { number in
    // Change to 1...50 for more options
}
```

### Modifying Heatmap Duration

In `HeatmapView.swift`:

```swift
private let daysToShow = 49  // Change to 365 for full year
```

### Adding Problem Difficulty Tracking

Extend `DailyProgress` model:

```swift
var easyCount: Int = 0
var mediumCount: Int = 0
var hardCount: Int = 0
```

## 🐛 Troubleshooting

### Screen Time Permission Not Working

- Ensure Family Controls capability is added
- Check Info.plist has usage description
- Device must be running iOS 16.0+
- Restart app after granting permissions

### LeetCode API Not Responding

- Check internet connection
- Verify username is correct
- LeetCode profile must be public
- Try again after a few seconds

### Apps Not Blocking

- Verify Screen Time permissions are granted
- Check if today is in active days
- Ensure apps are selected in settings
- Try restarting the device

## 🎯 Future Enhancement Ideas

1. **Progressive Unlocking**: Unlock apps one at a time as you solve problems
2. **Difficulty Bonuses**: Different points for Easy/Medium/Hard problems
3. **Weekly Challenges**: Special goals for weekends
4. **Friend Leaderboards**: Compare progress with friends
5. **Achievement System**: Badges for milestones
6. **Emergency Override**: Temporary unlock with streak penalty
7. **Widget Support**: Home screen widget showing progress
8. **Custom Problem Lists**: Focus on specific topics
9. **Study Timer**: Pomodoro-style timer integrated with blocking
10. **Dark/Light Mode Toggle**: Additional theme options

## 📚 Resources

- [LeetCode GraphQL API](https://leetcode.com/graphql)
- [FamilyControls Documentation](https://developer.apple.com/documentation/familycontrols)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [SwiftUI Animations](https://developer.apple.com/tutorials/swiftui/animating-views-and-transitions)

**Built with SwiftUI, SwiftData, and determination** 🔥
