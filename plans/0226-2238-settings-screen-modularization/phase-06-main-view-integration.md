# Phase 6: Main SettingsView Integration

## Overview
Refactor main SettingsView to use modular components and ViewModel.

**Priority:** High | **Effort:** Low | **Status:** Pending

## Target File: SettingsView.swift

### Before (473 lines) → After (~80 lines)

```swift
import SwiftUI

// MARK: - Settings View
@available(iOS 15.0, *)
struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: SettingsViewModel())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    SettingsProfileSection(viewModel: viewModel)

                    // Video Playback
                    SettingsVideoSection(viewModel: viewModel)

                    // Notifications
                    SettingsNotificationsSection(viewModel: viewModel)

                    // Display & Accessibility
                    SettingsDisplaySection(viewModel: viewModel)

                    // Data & Storage
                    SettingsStorageSection(viewModel: viewModel)

                    // About
                    SettingsAboutSection(viewModel: viewModel)

                    // Actions
                    actionsSection

                    Spacer(minLength: 100)
                }
                .padding(20)
            }
            .background(DSColors.backgroundSwiftUI)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Sign Out", isPresented: $viewModel.showSignOutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    Task { await viewModel.signOut() }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            DSActionButton(
                title: "Sign Out",
                style: .destructive,
                icon: nil
            ) {
                viewModel.showSignOutConfirmation = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
```

## File Location
```
Presentation/SwiftUI/Views/Settings/SettingsView.swift
```

## Changes from Original

### Removed (moved to other files)
- Profile section UI → SettingsProfileSection.swift
- Video section UI → SettingsVideoSection.swift
- Notifications section UI → SettingsNotificationsSection.swift
- Display section UI → SettingsDisplaySection.swift
- Storage section UI → SettingsStorageSection.swift
- About section UI → SettingsAboutSection.swift
- Row components → SettingsComponents.swift

### Added
- @StateObject for SettingsViewModel
- Section imports (all in same module)
- NavigationStack wrapper (iOS 16+ pattern)

### Kept
- Sign out alert (or move to actions section)
- Preview provider

## DI Registration (Optional)

### PresentationContainer Extension
```swift
extension PresentationContainer {
    var settingsViewModel: SettingsViewModel {
        SettingsViewModel(appSettings: appSettings)
    }
}
```

### Usage with Container
```swift
struct SettingsView: View {
    let container: AppContainer
    @StateObject private var viewModel: SettingsViewModel

    init(container: AppContainer) {
        self.container = container
        _viewModel = StateObject(wrappedValue: container.settingsViewModel)
    }
}
```

## Implementation Steps

1. Backup original SettingsView.swift
2. Replace with new modular version
3. Import all section files
4. Test navigation and state bindings
5. Verify alerts work correctly
6. Remove LegacySettingsView if not needed

## File Summary After Refactor

| File | Lines | Purpose |
|------|-------|---------|
| SettingsView.swift | ~80 | Main container |
| SettingsViewModel.swift | ~120 | Business logic |
| SettingsComponents.swift | ~150 | Shared row components |
| SettingsProfileSection.swift | ~60 | Profile UI |
| SettingsVideoSection.swift | ~50 | Video settings UI |
| SettingsNotificationsSection.swift | ~45 | Notifications UI |
| SettingsDisplaySection.swift | ~45 | Display UI |
| SettingsStorageSection.swift | ~60 | Storage UI |
| SettingsAboutSection.swift | ~65 | About UI |

**Total:** ~675 lines across 9 files (all under 200 lines)

## Success Criteria
- [ ] Main view under 100 lines
- [ ] All sections render correctly
- [ ] Navigation title appears
- [ ] Alerts trigger properly
- [ ] Build succeeds

## Next Phase
→ Phase 7: Testing & Polish
