---
title: "Phase 4: Accessibility Improvements"
description: "Add comprehensive VoiceOver support to movie components"
status: completed
priority: P2
effort: 1.5h
phase: 4 of 6
---

# Phase 4: Accessibility Improvements

## Context Links

- Research: [Haptics & Accessibility Research](./research/researcher-01-haptics-accessibility.md)
- Apple: [SwiftUI Accessibility](https://developer.apple.com/documentation/swiftui/accessibility)

## Overview

Add comprehensive VoiceOver support to movie-related components. Users with visual impairments should be able to navigate and interact with the app efficiently using VoiceOver.

## Current State Analysis

| Component | Current Accessibility | Issue |
|-----------|----------------------|-------|
| `MovieCard` | Basic button | No label, hint, or custom actions |
| `DSIconButton` | None | Missing label/hint for icon buttons |
| `CategoryTabs` | None | Missing selection announcement |
| `MoviePosterImage` | None | Decorative, should be ignored |

## Requirements

### Functional
- All interactive elements have accessibility labels
- Navigation hints describe what action will occur
- Custom accessibility actions for common operations
- State changes announced (e.g., "Added to favorites")

### Non-Functional
- Labels are concise (no element type suffix)
- Hints start with a verb
- Dynamic labels reflect current state

## Accessibility Label Guidelines

| DO | DON'T |
|----|-------|
| "Favorite" | "Favorite button" |
| "Add to favorites" | "Tap to add" |
| "4.5 stars" | "Rating: 4.5" |
| "Action, Comedy" | "Genres: Action, Comedy" |

## Related Code Files

### Files to Modify
- `trending-movie-ios/Presentation/SwiftUI/Components/MovieCard.swift`
- `trending-movie-ios/Presentation/DesignSystem/Components/DSActionButton.swift`
- `trending-movie-ios/Presentation/SwiftUI/Components/CategoryTabs.swift`

## Implementation Steps

### Step 1: Update MovieCard Standard Style

```swift
// In MovieCard.swift standardCard:
private var standardCard: some View {
    Button(action: onTap) {
        VStack(spacing: 0) {
            // ... existing content
        }
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(12)
    }
    // ADD ACCESSIBILITY:
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(movie.title), \(getGenreText()), \(formatRating()) stars")
    .accessibilityHint("Double tap to view details")
    .accessibilityAction(named: "Add to favorites") {
        onFavoriteTap?()
    }
    .accessibilityAction(named: "Add to watchlist") {
        onWatchlistTap?()
    }
}

// Add helper:
private func formatRating() -> String {
    String(format: "%.1f", min(parseRating(movie.voteAverage) * 2, 10))
}
```

### Step 2: Update MovieCard Compact Style

```swift
// In MovieCard.swift compactCard:
private var compactCard: some View {
    Button(action: onTap) {
        HStack(spacing: 12) {
            // ... existing content
        }
        .padding(16)
        .background(DSColors.surfaceSwiftUI)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(movie.title), \(movie.releaseDate), \(formatRating()) stars")
    .accessibilityHint("Double tap to view details")
    .accessibilityAction(named: "Add to favorites") {
        onFavoriteTap?()
        // Announce state change
        UIAccessibility.post(notification: .announcement, argument: "Added to favorites")
    }
    .accessibilityAction(named: "Add to watchlist") {
        onWatchlistTap?()
        UIAccessibility.post(notification: .announcement, argument: "Added to watchlist")
    }
}
```

### Step 3: Update MovieCard Hero Style

```swift
// In MovieCard.swift heroCard:
private var heroCard: some View {
    Button(action: onTap) {
        ZStack(alignment: .bottom) {
            // ... existing content
        }
        .padding(20)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(movie.title), \(movie.releaseDate), \(formatRating()) out of 10")
    .accessibilityHint("Featured movie. Double tap to view details.")
    .accessibilityAction(named: "Play trailer") {
        onTap()
    }
}
```

### Step 4: Update DSIconButton

```swift
// In DSActionButton.swift DSIconButton:
struct DSIconButton: View {
    // Add parameter:
    let accessibilityLabel: String?

    init(
        icon: CinemaxIcon,
        style: DSActionButton.Style = .secondary,
        size: DSIconSize = .medium,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil,  // ADD
        action: @escaping () -> Void
    ) {
        // ... existing init
        self.accessibilityLabel = accessibilityLabel
    }

    var body: some View {
        Button(action: action) {
            // ... existing content
        }
        .disabled(isDisabled)
        // ADD ACCESSIBILITY:
        .accessibilityLabel(accessibilityLabel ?? iconName)
        .accessibilityHint("Double tap to activate")
        // ... existing onLongPressGesture
    }

    private var iconName: String {
        // Map icon to readable name
        switch icon {
        case .heart: return "Favorite"
        case .download, .downloadOffline: return "Watchlist"
        case .share: return "Share"
        default: return "Button"
        }
    }
}
```

### Step 5: Update CategoryTabs

```swift
// In CategoryTabs.swift CategoryTab:
struct CategoryTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                // ... existing styling
        }
        // ADD ACCESSIBILITY:
        .accessibilityLabel(title)
        .accessibilityHint(isSelected ? "Selected" : "Double tap to select")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
```

### Step 6: Add Accessibility Announcement Helper

```swift
// In View+Extensions.swift add:
// MARK: - Accessibility Announcements

/// Announce a message to VoiceOver
func announce(_ message: String) {
    UIAccessibility.post(notification: .announcement, argument: message)
}

/// Announce state change
func announceStateChange(_ message: String) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}
```

## Todo List

- [ ] Add accessibility modifiers to `MovieCard` standard style
- [ ] Add accessibility modifiers to `MovieCard` compact style
- [ ] Add accessibility modifiers to `MovieCard` hero style
- [ ] Add `accessibilityLabel` parameter to `DSIconButton`
- [ ] Add accessibility modifiers to `CategoryTab`
- [ ] Add announcement helpers to `View+Extensions.swift`
- [ ] Build and verify no compile errors
- [ ] Test with VoiceOver enabled

## Success Criteria

- [ ] VoiceOver reads all movie card information
- [ ] Custom actions available via rotor
- [ ] State changes announced
- [ ] Tab selection state announced
- [ ] No compile errors

## VoiceOver Testing Checklist

1. Enable VoiceOver: Settings > Accessibility > VoiceOver
2. Navigate movie cards - verify title, rating, genre read
3. Use rotor to access custom actions
4. Activate favorite - verify "Added to favorites" announced
5. Switch tabs - verify selection state announced

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Too verbose labels | Keep labels concise, use hints for details |
| Custom actions missed | Document in user onboarding |
| State not announced | Use UIAccessibility.post notification |

## Next Steps

After completion:
- Proceed to Phase 5: Reduce Motion Support
- Accessibility compliance significantly improved

---

*Phase 4 of 6 | Estimated: 1.5h*
