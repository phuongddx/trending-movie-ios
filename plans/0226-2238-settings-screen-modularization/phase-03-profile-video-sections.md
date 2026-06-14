# Phase 3: Profile & Video Sections

## Overview
Create profile header and video playback settings section views.

**Priority:** Medium | **Effort:** Low | **Status:** Pending

## Files to Create

### 1. SettingsProfileSection.swift

```swift
// MARK: - Profile Header Section
struct SettingsProfileSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(DSColors.accentSwiftUI.opacity(0.2))
                    .frame(width: 80, height: 80)
                CinemaxIconView(.person, size: .extraLarge, color: DSColors.accentSwiftUI)
            }

            // User Info
            VStack(spacing: 4) {
                Text(viewModel.displayName)
                    .font(DSTypography.h3SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)
                Text(viewModel.email)
                    .font(DSTypography.bodySmallSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
            }

            // Edit Profile Button
            DSActionButton(
                title: "Edit Profile",
                style: .secondary,
                size: .small,
                icon: .edit
            ) {
                viewModel.editProfileTapped()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(DSColors.surfaceSwiftUI)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

**Lines:** ~60

### 2. SettingsVideoSection.swift

```swift
// MARK: - Video Playback Section
struct SettingsVideoSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        SettingsSectionContainer(title: "Video Playback", icon: .film) {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "Autoplay Trailers",
                    subtitle: "Automatically play trailers when browsing",
                    isOn: $viewModel.videoSettings.autoplayTrailers
                )

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsNavigationRow(
                    title: "Streaming Quality",
                    value: viewModel.videoSettings.streamingQuality.displayValue,
                    icon: .hd
                ) {
                    viewModel.showStreamingQualityPicker()
                }

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsNavigationRow(
                    title: "Download Quality",
                    value: viewModel.videoSettings.downloadQuality.displayValue,
                    icon: .download
                ) {
                    viewModel.showDownloadQualityPicker()
                }
            }
        }
    }
}
```

**Lines:** ~50

## File Locations
```
Presentation/SwiftUI/Views/Settings/SettingsProfileSection.swift
Presentation/SwiftUI/Views/Settings/SettingsVideoSection.swift
```

## Implementation Steps

### Profile Section
1. Create SettingsProfileSection.swift
2. Bind to viewModel.displayName, viewModel.email
3. Add editProfileTapped() action (stub navigation)
4. Add accessibility identifiers

### Video Section
1. Create SettingsVideoSection.swift
2. Use SettingsSectionContainer from Phase 2
3. Bind to viewModel.videoSettings
4. Add quality picker sheet states (or navigation)

## Video Quality Display Extension

```swift
extension VideoQuality {
    var displayValue: String {
        switch self {
        case .auto: return "Auto"
        case .low: return "Low (480p)"
        case .medium: return "Medium (720p)"
        case .high: return "High (1080p)"
        }
    }
}
```

## Success Criteria
- [ ] Both files under 80 lines each
- [ ] Compile without errors
- [ ] Bindings connected to ViewModel
- [ ] Navigation stubs in place

## Next Phase
→ Phase 4: Notifications & Display Sections
