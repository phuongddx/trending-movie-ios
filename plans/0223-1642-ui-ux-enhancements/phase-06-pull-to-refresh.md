---
title: "Phase 6: Pull to Refresh"
description: "Add pull-to-refresh functionality using iOS 17 native refreshable modifier"
status: completed
priority: P3
effort: 0.5h
phase: 6 of 6
---

# Phase 6: Pull to Refresh

## Context Links

- Research: [Shimmer & Loading Patterns Research](./research/researcher-02-shimmer-images.md)
- Validation: iOS 17.0+ only - use native `.refreshable`

## Overview

Implement pull-to-refresh for the HomeView using the native `.refreshable` modifier. Since we target iOS 17+, no fallback is needed.

## Current State Analysis

| Component | Current State | Issue |
|-----------|---------------|-------|
| `HomeView` | Loads on appear only | No way to refresh without restart |
| `HomeViewModel` | `loadData()` method exists | No async version for refreshable |

## Requirements

### Functional
- Pull-down gesture triggers data refresh
- Loading indicator shown during refresh
- Haptic feedback on pull (when enabled)

### Non-Functional
- Native iOS feel
- Smooth animation

## Architecture

```
iOS 17+ (Native):
ScrollView.refreshable { await viewModel.refresh() }
```

## Related Code Files

### Files to Modify
- `trending-movie-ios/Presentation/SwiftUI/Views/HomeView.swift`
- `trending-movie-ios/Presentation/SwiftUI/Views/HomeView.swift` (HomeViewModel)

## Implementation Steps

### Step 1: Add Async Refresh to HomeViewModel

```swift
// In HomeView.swift HomeViewModel:

/// Refresh all data (for pull-to-refresh)
@MainActor
func refresh() async {
    // Clear existing tasks
    loadingTasks.values.forEach { $0.cancel() }
    loadingTasks.removeAll()

    // Reset state
    isLoading = true

    // Small delay for UX (feels more natural)
    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s

    // Reload all data
    loadTrendingMovies()
    loadPopularMovies()
    loadNowPlayingMovies()
    loadTopRatedMovies()
    loadUpcomingMovies()
}
```

### Step 2: Update HomeView with Refreshable

```swift
// In HomeView.swift body:
var body: some View {
    NavigationView {
        ZStack {
            DSColors.backgroundSwiftUI
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // ... existing content unchanged
                }
            }
            .refreshable {
                // Trigger haptic if enabled
                if AppSettings.shared.isHapticEnabled {
                    // Haptic triggered by system refresh
                }
                await viewModel.refresh()
            }

            // ... rest of view (NavigationLink, etc.)
        }
    }
}
```

### Step 3: Alternative - Extract Content View

If the view is too complex, extract content:

```swift
// In HomeView:
var body: some View {
    NavigationView {
        ZStack {
            DSColors.backgroundSwiftUI
                .ignoresSafeArea()

            refreshableContent

            // Hidden NavigationLink...
        }
    }
}

@ViewBuilder
private var refreshableContent: some View {
    ScrollView {
        VStack(spacing: 24) {
            userProfileHeader
            searchBar
            dateSubtitle
            heroCarousel
            categoriesSection
            popularSection
            bottomPadding
        }
    }
    .refreshable {
        await viewModel.refresh()
    }
}
```

## Todo List

- [ ] Add `refresh()` async method to `HomeViewModel`
- [ ] Add `.refreshable` modifier to `HomeView` ScrollView
- [ ] Build and verify no compile errors
- [ ] Test on simulator/device

## Success Criteria

- [ ] Pull-to-refresh works natively
- [ ] Loading indicator appears during refresh
- [ ] Indicator dismisses after data loads
- [ ] No compile errors

## Testing Checklist

1. Pull down on home screen
2. Verify native refresh control appears
3. Verify data refreshes
4. Verify control dismisses after loading

## Completion

All 6 phases complete! The app now has:
- Centralized haptic feedback with user settings
- Compliant touch targets (44x44pt)
- Shimmer loading states
- Comprehensive accessibility
- Reduce motion support
- Pull-to-refresh functionality

---

*Phase 6 of 6 | Estimated: 0.5h*
