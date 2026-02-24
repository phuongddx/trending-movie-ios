---
title: "Phase 1: Haptic Feedback System + Settings"
description: "Implement centralized haptic feedback with user configuration using iOS 17 native APIs"
status: completed
priority: P1
effort: 2h
phase: 1 of 6
---

# Phase 1: Haptic Feedback System + Settings

## Context Links

- Research: [Haptics & Accessibility Research](./research/researcher-01-haptics-accessibility.md)
- Related: `View+Extensions.swift`, `DSActionButton.swift`, `DSIconButton.swift`, `CategoryTabs.swift`
- Validation: iOS 17.0+, Medium impact default, User-configurable

## Overview

Implement a centralized `HapticManager` with user preferences using iOS 17 native `.sensoryFeedback()` modifier. Add Settings screen to allow users to toggle haptic feedback.

## Key Insights

- iOS 17+ has native `.sensoryFeedback()` modifier - simpler than UIKit wrapper
- User preference stored via `@AppStorage` for persistence
- Medium impact as default (validated)
- Test on real devices only - simulators don't support haptics

## Requirements

### Functional
- Centralized `HapticManager` with impact, selection, and notification methods
- User preference storage (`@AppStorage`) for enabling/disabling haptics
- Settings screen with haptic toggle
- Haptic feedback on all button taps (when enabled)
- Selection feedback for tab/category changes

### Non-Functional
- Zero latency on feedback
- Graceful degradation when disabled
- Persistent user preference

## Architecture

```
AppSettings (ObservableObject + @AppStorage)
├── isHapticEnabled: Bool

HapticManager (Singleton)
├── impact(style: SensoryFeedback)  // iOS 17 native
├── selection()
├── success()
├── warning()
└── error()

SettingsView
├── Haptic toggle
└── Link to system accessibility
```

## Related Code Files

### Files to Create
- `trending-movie-ios/Presentation/Utils/Services/HapticManager.swift`
- `trending-movie-ios/Presentation/Utils/Services/AppSettings.swift`
- `trending-movie-ios/Presentation/SwiftUI/Views/SettingsView.swift`

### Files to Modify
- `trending-movie-ios/Presentation/Utils/Extensions/View+Extensions.swift`
- `trending-movie-ios/Presentation/DesignSystem/Components/DSActionButton.swift`
- `trending-movie-ios/Presentation/SwiftUI/Components/CategoryTabs.swift`
- `trending-movie-ios/Presentation/SwiftUI/Navigation/TabNavigation.swift` - Add settings tab

## Implementation Steps

### Step 1: Create AppSettings.swift

```swift
// Path: trending-movie-ios/Presentation/Utils/Services/AppSettings.swift
import SwiftUI
import Combine

/// App-wide user settings with persistence
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true

    private init() {}
}
```

### Step 2: Create HapticManager.swift

```swift
// Path: trending-movie-ios/Presentation/Utils/Services/HapticManager.swift
import SwiftUI

/// Centralized haptic feedback service using iOS 17 native APIs
@available(iOS 17.0, *)
final class HapticManager {
    static let shared = HapticManager()
    private let settings = AppSettings.shared

    private init() {}

    // MARK: - Impact Feedback

    /// Medium impact - standard interactions (default)
    func mediumImpact() {
        guard settings.isHapticEnabled else { return }
        // Will be triggered via .sensoryFeedback modifier
    }

    /// Light impact - subtle UI elements
    func lightImpact() {
        guard settings.isHapticEnabled else { return }
    }

    /// Heavy impact - significant actions
    func heavyImpact() {
        guard settings.isHapticEnabled else { return }
    }

    // MARK: - Selection Feedback

    /// Selection changed - tabs, pickers
    func selection() {
        guard settings.isHapticEnabled else { return }
    }

    // MARK: - Notification Feedback

    func success() { guard settings.isHapticEnabled else { return } }
    func warning() { guard settings.isHapticEnabled else { return } }
    func error() { guard settings.isHapticEnabled else { return } }

    // MARK: - Check if enabled

    var isEnabled: Bool {
        settings.isHapticEnabled
    }
}
```

### Step 3: Create SettingsView.swift

```swift
// Path: trending-movie-ios/Presentation/SwiftUI/Views/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = AppSettings.shared

    var body: some View {
        List {
            Section("Accessibility") {
                Toggle("Haptic Feedback", isOn: $settings.isHapticEnabled)
                    .tint(DSColors.accentSwiftUI)

                Text("Provides tactile feedback when tapping buttons and switching tabs.")
                    .font(.caption)
                    .foregroundColor(DSColors.tertiaryTextSwiftUI)
            }

            Section {
                Link(destination: URL(string: "App-prefs:root=ACCESSIBILITY")!) {
                    HStack {
                        Text("System Accessibility Settings")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(DSColors.tertiaryTextSwiftUI)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .background(DSColors.backgroundSwiftUI)
    }
}
```

### Step 4: Update DSActionButton with iOS 17 sensoryFeedback

```swift
// In DSActionButton body:
var body: some View {
    Button(action: action) {
        HStack(spacing: 8) {
            // ... existing content
        }
        // ... existing modifiers
    }
    .disabled(isDisabled)
    // Add iOS 17 haptic feedback
    .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: UUID()) {
        AppSettings.shared.isHapticEnabled && isPressed
    }
    // ... existing onLongPressGesture
}
```

**Alternative for button action haptic:**

```swift
// Wrap action with haptic check
Button(action: {
    if AppSettings.shared.isHapticEnabled {
        // Haptic triggered by system on tap
    }
    action()
}) {
    // ...
}
.sensoryFeedback(.impact(weight: .medium), trigger: UUID())
```

### Step 5: Update CategoryTabs

```swift
// In CategoryTab:
Button(action: {
    withAnimation(.easeInOut(duration: 0.2)) {
        selectedCategory = category
    }
}) {
    // ... existing content
}
.sensoryFeedback(.selection, trigger: selectedCategory == category)
```

### Step 6: Add Settings to TabNavigation

```swift
// Add settings tab to TabNavigation.swift
Tab(value: .settings) {
    SettingsView()
        .navigationTitle("Settings")
} label: {
    TabNavigation.TabItem(
        icon: .settings,
        title: "Settings",
        isSelected: selectedTab == .settings
    )
}
```

## Todo List

- [ ] Create `AppSettings.swift` with @AppStorage
- [ ] Create `HapticManager.swift` for iOS 17
- [ ] Create `SettingsView.swift` with haptic toggle
- [ ] Update `DSActionButton` with `.sensoryFeedback`
- [ ] Update `DSIconButton` with `.sensoryFeedback`
- [ ] Update `CategoryTabs` with selection feedback
- [ ] Add Settings tab to `TabNavigation`
- [ ] Build and verify no compile errors
- [ ] Test on physical device

## Success Criteria

- [ ] Settings screen accessible from tab bar
- [ ] Haptic toggle persists across app launches
- [ ] All buttons produce haptic when enabled
- [ ] No haptic when disabled
- [ ] No compile errors
- [ ] Works on iOS 17+

## Testing Notes

**CRITICAL**: Haptic feedback only works on physical devices.

Test checklist on device:
1. Verify Settings tab exists
2. Toggle haptics OFF - no feedback on button taps
3. Toggle haptics ON - feel medium impact on button taps
4. Switch category tabs - feel selection tick
5. Kill and relaunch app - setting persists

## Next Steps

After completion:
- Proceed to Phase 2: Touch Target Compliance
- Touch targets affect the same components (DSIconButton)

---

*Phase 1 of 6 | Estimated: 2h*
