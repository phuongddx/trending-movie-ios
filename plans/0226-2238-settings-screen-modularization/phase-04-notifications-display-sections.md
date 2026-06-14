# Phase 4: Notifications & Display Sections

## Overview
Create notifications and display/accessibility settings section views.

**Priority:** Medium | **Effort:** Low | **Status:** Pending

## Files to Create

### 1. SettingsNotificationsSection.swift

```swift
// MARK: - Notifications Section
struct SettingsNotificationsSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        SettingsSectionContainer(title: "Notifications", icon: .notification) {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "Push Notifications",
                    subtitle: "Receive alerts on your device",
                    isOn: $viewModel.notificationSettings.pushEnabled
                )

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsToggleRow(
                    title: "New Releases",
                    subtitle: "Get notified about new movies and shows",
                    isOn: $viewModel.notificationSettings.newReleasesEnabled,
                    isEnabled: viewModel.notificationSettings.pushEnabled
                )

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsToggleRow(
                    title: "Recommendations",
                    subtitle: "Personalized movie suggestions",
                    isOn: $viewModel.notificationSettings.recommendationsEnabled,
                    isEnabled: viewModel.notificationSettings.pushEnabled
                )
            }
        }
    }
}
```

**Lines:** ~45

### 2. SettingsDisplaySection.swift

```swift
// MARK: - Display & Accessibility Section
struct SettingsDisplaySection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        SettingsSectionContainer(title: "Display & Accessibility", icon: .settings) {
            VStack(spacing: 0) {
                SettingsNavigationRow(
                    title: "Language",
                    value: viewModel.displaySettings.language,
                    icon: .globe
                ) {
                    viewModel.showLanguagePicker()
                }

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsToggleRow(
                    title: "Show Age Ratings",
                    subtitle: "Display content ratings on movie posters",
                    isOn: $viewModel.displaySettings.showAgeRatings
                )

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsToggleRow(
                    title: "Haptic Feedback",
                    subtitle: "Provides tactile feedback when tapping buttons",
                    isOn: $viewModel.displaySettings.hapticEnabled
                )
            }
        }
    }
}
```

**Lines:** ~45

## File Locations
```
Presentation/SwiftUI/Views/Settings/SettingsNotificationsSection.swift
Presentation/SwiftUI/Views/Settings/SettingsDisplaySection.swift
```

## Implementation Steps

### Notifications Section
1. Create SettingsNotificationsSection.swift
2. Bind to viewModel.notificationSettings
3. Add dependency logic (sub-toggles disabled when push disabled)
4. Future: Add UNUserNotificationCenter integration

### Display Section
1. Create SettingsDisplaySection.swift
2. Bind to viewModel.displaySettings
3. Connect haptic toggle to AppSettings.shared.isHapticEnabled
4. Add language picker sheet

## NotificationSettings Model

```swift
struct NotificationSettings {
    var pushEnabled: Bool
    var newReleasesEnabled: Bool
    var recommendationsEnabled: Bool

    static var `default`: NotificationSettings {
        NotificationSettings(
            pushEnabled: true,
            newReleasesEnabled: true,
            recommendationsEnabled: false
        )
    }
}
```

## DisplaySettings Model

```swift
struct DisplaySettings {
    var language: String
    var showAgeRatings: Bool
    var hapticEnabled: Bool

    static var `default`: DisplaySettings {
        DisplaySettings(
            language: "English",
            showAgeRatings: true,
            hapticEnabled: true
        )
    }
}
```

## Language Picker Implementation

```swift
// In SettingsViewModel
@Published var showLanguageSheet = false
let availableLanguages = ["English", "Spanish", "French", "German", "Japanese", "Korean"]

func showLanguagePicker() {
    showLanguageSheet = true
}
```

## Success Criteria
- [ ] Both files under 50 lines each
- [ ] Compile without errors
- [ ] Toggle dependency logic works
- [ ] Haptic setting persists

## Next Phase
→ Phase 5: Storage & About Sections
