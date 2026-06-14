# Phase 2: SettingsComponents

## Overview
Extract reusable row components from existing SettingsView into dedicated file.

**Priority:** High | **Effort:** Medium | **Status:** Pending

## Context
- Current row components are private extensions (lines 349-467)
- Need to make them reusable across sections
- Follow existing DSActionButton pattern

## Components to Extract

### 1. SettingsSectionHeader
```swift
struct SettingsSectionHeader: View {
    let title: String
    let icon: CinemaxIcon

    var body: some View {
        HStack(spacing: 8) {
            CinemaxIconView(icon, size: .small, color: DSColors.accentSwiftUI)
            Text(title)
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)
        }
    }
}
```

### 2. SettingsToggleRow
```swift
struct SettingsToggleRow: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    let isEnabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(DSColors.primaryTextSwiftUI)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DSTypography.bodySmallSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                        .lineLimit(2)
                }
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(DSColors.accentSwiftUI)
                .labelsHidden()
        }
        .padding(16)
        .opacity(isEnabled ? 1 : 0.5)
    }
}
```

### 3. SettingsNavigationRow
```swift
struct SettingsNavigationRow: View {
    let title: String
    let value: String?
    let icon: CinemaxIcon?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    CinemaxIconView(icon, size: .small, color: DSColors.secondaryTextSwiftUI)
                }
                Text(title)
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(DSColors.primaryTextSwiftUI)
                Spacer()
                if let value = value {
                    Text(value)
                        .font(DSTypography.bodySmallSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DSColors.tertiaryTextSwiftUI)
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

### 4. SettingsInfoRow
```swift
struct SettingsInfoRow: View {
    let title: String
    let value: String
    let icon: CinemaxIcon?

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                CinemaxIconView(icon, size: .small, color: DSColors.secondaryTextSwiftUI)
            }
            Text(title)
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.primaryTextSwiftUI)
            Spacer()
            Text(value)
                .font(DSTypography.bodySmallSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)
        }
        .padding(16)
    }
}
```

### 5. SettingsButtonRow
```swift
struct SettingsButtonRow: View {
    let title: String
    let icon: CinemaxIcon?
    let isDestructive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    CinemaxIconView(
                        icon,
                        size: .small,
                        color: isDestructive ? DSColors.errorSwiftUI : DSColors.secondaryTextSwiftUI
                    )
                }
                Text(title)
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(isDestructive ? DSColors.errorSwiftUI : DSColors.primaryTextSwiftUI)
                Spacer()
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

### 6. SettingsSectionContainer
```swift
struct SettingsSectionContainer<Content: View>: View {
    let title: String
    let icon: CinemaxIcon
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: title, icon: icon)
            VStack(spacing: 0) {
                content()
            }
            .background(DSColors.surfaceSwiftUI)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
```

## File Location
```
Presentation/SwiftUI/Views/Settings/SettingsComponents.swift
```

## Implementation Steps

1. Create `SettingsComponents.swift` file
2. Add @available(iOS 15.0, *) where needed
3. Copy component code from existing SettingsView
4. Add accessibility identifiers
5. Add preview providers for each component

## Success Criteria
- [ ] All 6 components extracted
- [ ] File under 200 lines
- [ ] Components compile without errors
- [ ] Accessibility labels added

## Next Phase
→ Phase 3: Profile & Video Sections
