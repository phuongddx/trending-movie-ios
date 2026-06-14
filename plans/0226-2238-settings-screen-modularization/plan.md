# Settings Screen Modularization Plan

## Overview
Refactor the existing 473-line `SettingsView.swift` into a modular, maintainable architecture following Clean Architecture and MVVM patterns.

**Status:** Not Started
**Priority:** High
**Branch:** master

## Problem Analysis

### Current Issues
1. **Single Monolithic File** - 473 lines exceeds 200-line limit
2. **Business Logic in View** - Settings state mixed with UI code
3. **No ViewModel** - Direct @AppStorage usage in view
4. **Tight Coupling** - All sections in one file, hard to test

### Design System Applied
- **Pattern:** App Store Style (clean sections, clear visual hierarchy)
- **Style:** Dark theme with vibrant accents
- **Touch Targets:** Minimum 44x44pt (already implemented)
- **Accessibility:** VoiceOver support, haptic feedback options

## Architecture

### File Structure
```
Presentation/SwiftUI/
├── Views/
│   └── Settings/
│       ├── SettingsView.swift              # Main container (~80 lines)
│       ├── SettingsViewModel.swift         # Business logic (~120 lines)
│       ├── SettingsComponents.swift        # Shared row components (~150 lines)
│       └── SettingsDestinations.swift      # Navigation destinations
└── Components/Settings/
    ├── SettingsProfileSection.swift        # Profile header
    ├── SettingsVideoSection.swift          # Video playback settings
    ├── SettingsNotificationsSection.swift   # Push notifications
    ├── SettingsDisplaySection.swift         # Language, age ratings, haptics
    ├── SettingsStorageSection.swift         # Cache, downloads management
    └── SettingsAboutSection.swift           # Version, privacy, terms
```

### Data Flow
```
SettingsViewModel (ObservableObject)
    ├── @Published var settings: AppSettings
    ├── @Published var videoSettings: VideoSettings
    ├── @Published var notificationSettings: NotificationSettings
    └── Functions: clearCache(), signOut()
           │
           ▼
    SettingsView (View)
    ├── ObservedObject: viewModel
    └── Renders sections with bindings
```

## Phases

| Phase | File | Lines | Status |
|-------|------|-------|--------|
| 1 | [SettingsViewModel](phase-01-settings-viewmodel.md) | ~120 | Pending |
| 2 | [SettingsComponents](phase-02-settings-components.md) | ~150 | Pending |
| 3 | [Profile & Video Sections](phase-03-profile-video-sections.md) | ~180 | Pending |
| 4 | [Notifications & Display Sections](phase-04-notifications-display-sections.md) | ~160 | Pending |
| 5 | [Storage & About Sections](phase-05-storage-about-sections.md) | ~140 | Pending |
| 6 | [Main SettingsView Integration](phase-06-main-view-integration.md) | ~80 | Pending |
| 7 | [Testing & Polish](phase-07-testing-polish.md) | - | Pending |

## Success Criteria
- [ ] All files under 200 lines
- [ ] ViewModel handles all business logic
- [ ] Each section in separate file
- [ ] All @AppStorage moved to ViewModel
- [ ] Navigation destinations implemented
- [ ] Build succeeds without errors
- [ ] Tests pass

## Risk Assessment
| Risk | Mitigation |
|------|------------|
| State sync issues | Use single source of truth in ViewModel |
| Navigation complexity | Use AppDestination enum pattern |
| iOS 14 compatibility | Keep @available checks |

## Next Steps
Start with Phase 1: SettingsViewModel to establish data layer foundation.
