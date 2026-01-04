# LeetLock Setup Guide

## Step-by-Step Configuration

### 1. Xcode Project Setup

#### Add Required Capabilities

1. Open `LeetLock.xcodeproj` in Xcode
2. Select the **LeetLock** target in the project navigator
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability** button
5. Search for and add **"Family Controls"**

#### Configure Signing

1. In **Signing & Capabilities** tab
2. Select your **Team**
3. Ensure **Automatically manage signing** is checked
4. Choose a unique **Bundle Identifier** (e.g., `com.yourname.leetlock`)

### 2. Info.plist Configuration

The `Info.plist` file has been created with required permissions. Verify it contains:

```xml
<key>NSFamilyControlsUsageDescription</key>
<string>LeetLock needs Screen Time permissions to block distracting apps until you complete your daily LeetCode goals.</string>
```

### 3. File Organization

Ensure all files are added to the Xcode project:

#### Models Group
- `UserSettings.swift`
- `DailyProgress.swift`
- `BlockedAppSelection.swift`
- `StreakData.swift`

#### Services Group
- `LeetCodeService.swift`
- `AppBlockingService.swift`
- `ProgressService.swift`

#### Views Group
- `Onboarding/` folder with 5 files
- `Main/` folder with 4 files
- `Settings/` folder with 1 file

#### Utilities Group
- `DataStore.swift`
- `ColorExtensions.swift`

### 4. Build Settings

#### Minimum Deployment Target

1. Select your target
2. Go to **Build Settings**
3. Search for "Deployment Target"
4. Set **iOS Deployment Target** to **16.0** or later

#### Swift Language Version

1. In **Build Settings**
2. Search for "Swift Language Version"
3. Ensure it's set to **Swift 5** or later

### 5. Testing on Device

**Important**: Screen Time features **DO NOT** work on Simulator

1. Connect a physical iOS device (iPhone or iPad)
2. Select your device from the device menu
3. Build and run (⌘R)

### 6. Granting Permissions

When you first launch the app:

1. **Onboarding Page 1**: Enter your LeetCode username
   - Tap "Verify Username"
   - Wait for green checkmark
   - Tap "Continue"

2. **Onboarding Page 2**: Grant Screen Time access
   - Tap "Grant Access"
   - System prompt will appear
   - Tap "Continue" in the system dialog
   - Grant permission

3. **Onboarding Page 3**: Select apps to block
   - Tap "Select Apps"
   - Choose distracting apps (Instagram, TikTok, games, etc.)
   - Tap "Done" in picker
   - Tap "Continue"

4. **Onboarding Page 4**: Configure goals
   - Scroll to select daily problem count
   - Tap days of the week to toggle
   - Tap "Get Started"

### 7. Verifying Installation

After onboarding:

1. You should see the **Main Dashboard**
2. Lock icon should be visible
3. Progress shows "0/X Problems Solved"
4. Heatmap may be empty initially
5. Pull down to refresh and fetch LeetCode data

### 8. Testing App Blocking

1. Exit LeetLock
2. Try to open a blocked app
3. You should see a shield/lock screen
4. Go solve a LeetCode problem!
5. Return to LeetLock and pull to refresh
6. When goal is met, apps unlock automatically

## Common Setup Issues

### Issue: "Family Controls capability requires a development team"

**Solution**: 
- You need to be signed in with an Apple ID in Xcode
- Go to Xcode → Preferences → Accounts
- Add your Apple ID
- Select it as your team in Signing & Capabilities

### Issue: "Module 'FamilyControls' not found"

**Solution**:
- Ensure you added the Family Controls capability
- Clean build folder (Shift + ⌘K)
- Build again (⌘B)

### Issue: "Blocked apps don't stay blocked"

**Solution**:
- Screen Time features only work on physical devices
- Ensure you granted permissions
- Check that today is in your active days
- Verify your goal isn't already met

### Issue: "LeetCode username verification fails"

**Solution**:
- Check internet connection
- Ensure username is spelled correctly
- Make sure LeetCode profile is public
- Try again after a few seconds

### Issue: "Heatmap shows no data"

**Solution**:
- Pull down to refresh the main view
- Check that username is verified
- Ensure you have recent submissions on LeetCode
- Wait a few seconds for API response

## Development Tips

### Debugging

Enable detailed logging:

```swift
// In LeetCodeService.swift
print("API Response: \(String(data: data, encoding: .utf8) ?? "nil")")

// In AppBlockingService.swift
print("Shields active: \(areShieldsActive())")
print("Blocked app count: \(getBlockedAppCount())")
```

### Testing Without Real LeetCode Account

Create mock data in `ContentView.swift`:

```swift
.onAppear {
    #if DEBUG
    // Create test data
    let settings = UserSettings()
    settings.leetcodeUsername = "test_user"
    settings.isUsernameVerified = true
    settings.hasCompletedOnboarding = true
    modelContext.insert(settings)
    #endif
}
```

### Resetting Onboarding

To test onboarding again:

1. Delete app from device
2. Or modify `UserSettings.hasCompletedOnboarding` to `false`
3. Relaunch app

## Next Steps

1. ✅ Complete setup using this guide
2. 🧪 Test onboarding flow
3. 🎨 Customize colors and animations
4. 📱 Test app blocking on real device
5. 🚀 Use daily and build your streak!

## Getting Help

If you encounter issues:

1. Check console logs in Xcode
2. Review this setup guide
3. Verify all files are in project
4. Ensure capabilities are configured
5. Test on physical device, not simulator

---

**Ready to lock in and start coding!** 🔒💪
