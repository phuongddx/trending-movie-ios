# Phase 1: SettingsViewModel

## Overview
Create the ViewModel layer to manage all settings state and business logic.

**Priority:** High | **Effort:** Medium | **Status:** Pending

## Context
- Extract business logic from SettingsView
- Use existing `AppSettings.swift` as reference
- ViewModel will be single source of truth for settings

## Architecture

```swift
// SettingsViewModel.swift
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Dependencies
    private let appSettings: AppSettings

    // MARK: - Published State
    @Published var videoSettings: VideoSettings
    @Published var notificationSettings: NotificationSettings
    @Published var displaySettings: DisplaySettings
    @Published var storageInfo: StorageInfo

    // MARK: - Computed
    var appVersion: String { ... }
    var buildNumber: String { ... }

    // MARK: - Actions
    func clearCache() async { ... }
    func signOut() async { ... }
}
```

## Data Models

### VideoSettings
```swift
struct VideoSettings {
    var autoplayTrailers: Bool
    var streamingQuality: VideoQuality
    var downloadQuality: VideoQuality
}

enum VideoQuality: String, CaseIterable {
    case auto = "Auto"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}
```

### NotificationSettings
```swift
struct NotificationSettings {
    var pushEnabled: Bool
    var newReleasesEnabled: Bool
    var recommendationsEnabled: Bool
}
```

### DisplaySettings
```swift
struct DisplaySettings {
    var language: String
    var showAgeRatings: Bool
    var hapticFeedbackEnabled: Bool
}
```

### StorageInfo
```swift
struct StorageInfo {
    var downloadedMoviesCount: Int
    var downloadedMoviesSize: String
    var cacheSize: String
}
```

## Implementation Steps

1. **Create SettingsViewModel.swift**
   - Location: `Presentation/SwiftUI/ViewModels/SettingsViewModel.swift`
   - Import Combine, Foundation
   - Define data models as nested types or separate files

2. **Create SettingsModels.swift**
   - Location: `Presentation/SwiftUI/Models/SettingsModels.swift`
   - VideoSettings, NotificationSettings, DisplaySettings, StorageInfo
   - VideoQuality enum

3. **Implement State Management**
   - Use UserDefaults @AppStorage wrapper or direct UserDefaults
   - Use @Published properties for reactive updates
   - Add combine cancellables if needed

4. **Implement Actions**
   - `clearCache()` - Clear URLCache, image cache
   - `signOut()` - Call auth service (stub for now)
   - `refreshStorageInfo()` - Calculate cache/downloads size

5. **Add Dependencies**
   - Inject AppSettings from DI container
   - Prepare for future auth service injection

## Related Files
- `trending-movie-ios/Presentation/SwiftUI/ViewModels/` (create if needed)
- `trending-movie-ios/Presentation/Utils/Services/AppSettings.swift` (reference)
- `DI/PresentationContainer.swift` (register ViewModel)

## Success Criteria
- [ ] ViewModel compiles without errors
- [ ] All @Published properties defined
- [ ] Actions implemented with stubs
- [ ] Models conform to Codable for future persistence

## Next Phase
→ Phase 2: SettingsComponents (shared row components)
