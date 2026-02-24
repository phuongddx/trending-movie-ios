# Phase 1: Enhance MovieRowView with Action Buttons

## Overview
- **Priority:** P1 (Critical path)
- **Status:** Pending
- **Effort:** 4h

Add visible quick actions to `MovieRowView` for better UX.

## Context Links
- Brainstorm Report: `plans/reports/brainstorm-movie-list-screen-design-0224-0930.md`
- Existing: `trending-movie-ios/Presentation/SwiftUI/Components/MovieRowView.swift`
- Design System: `Presentation/DesignSystem/`

## Requirements

### Functional
- Watchlist button visible as primary action
- Overflow menu (...) for secondary actions (Favorite, Share)
- Button state reflects current storage state (filled/outline)

### Non-Functional
- Touch targets: 44x44pt minimum
- Gap between buttons: 8pt minimum
- VoiceOver labels on all buttons

## Architecture

```
MovieRowView
├── HStack
│   ├── posterImageView (60x90)
│   ├── movieInfoView
│   │   ├── Title + Year
│   │   ├── Rating
│   │   └── Overview
│   └── actionButtonsView (NEW)
│       ├── WatchlistButton (primary, visible)
│       └── OverflowMenu
│           ├── Favorite
│           └── Share
```

## Related Code Files

| File | Action | Notes |
|------|--------|-------|
| `Presentation/SwiftUI/Components/MovieRowView.swift` | Modify | Add action buttons |
| `Presentation/DesignSystem/Components/DSActionButton.swift` | Reference | Button styles |
| `Presentation/Utils/Services/MovieStorage.swift` | Reference | Watchlist/favorite state |

## Implementation Steps

### Step 1: Add Action Button State
```swift
// Add to MovieRowView
@StateObject private var storage = MovieStorage.shared

private var isInWatchlist: Bool {
    storage.isInWatchlist(movie.toMovie())
}

private var isFavorite: Bool {
    storage.isFavorite(movie.toMovie())
}
```

### Step 2: Create Action Buttons View
```swift
private var actionButtonsView: some View {
    HStack(spacing: DSSpacing.sm) { // 8pt gap
        // Primary: Watchlist
        Button(action: { toggleWatchlist() }) {
            Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                .font(.system(size: 20))
                .foregroundColor(isInWatchlist ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI)
        }
        .frame(width: 44, height: 44) // Touch target
        .accessibilityLabel(isInWatchlist ? "Remove from watchlist" : "Add to watchlist")

        // Overflow menu
        Menu {
            Button(action: { toggleFavorite() }) {
                Label(
                    isFavorite ? "Remove from favorites" : "Add to favorites",
                    systemImage: isFavorite ? "heart.fill" : "heart"
                )
            }
            Button(action: { shareMovie() }) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 20))
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel("More options")
    }
}
```

### Step 3: Add Callbacks
```swift
// Add to MovieRowView init
let onWatchlistToggle: (() -> Void)?
let onFavoriteToggle: (() -> Void)?
let onShare: (() -> Void)?

private func toggleWatchlist() {
    let movieModel = movie.toMovie()
    if isInWatchlist {
        storage.removeFromWatchlist(movieModel)
    } else {
        storage.addToWatchlist(movieModel)
    }
    onWatchlistToggle?()
}

private func shareMovie() {
    // Share sheet with movie URL
    onShare?()
}
```

### Step 4: Update Layout
```swift
var body: some View {
    HStack(spacing: DSSpacing.md) {
        posterImageView
        movieInfoView
        Spacer()
        actionButtonsView // NEW
    }
    .frame(minHeight: 100) // Prevent layout shift
    // ... existing styling
}
```

## Todo List

- [ ] Add `MovieStorage` reference to `MovieRowView`
- [ ] Create `actionButtonsView` computed property
- [ ] Implement `toggleWatchlist()` method
- [ ] Implement `toggleFavorite()` method
- [ ] Implement `shareMovie()` method
- [ ] Add callbacks to init (optional parameters)
- [ ] Add `frame(minHeight: 100)` for stability
- [ ] Add accessibility labels
- [ ] Test VoiceOver navigation

## Success Criteria

- [ ] Watchlist button shows filled when movie in watchlist
- [ ] Overflow menu shows Favorite + Share options
- [ ] All buttons have 44x44pt touch targets
- [ ] VoiceOver announces button states correctly
- [ ] No layout shift when buttons appear/disappear

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Storage state not updating | Medium | Use `@StateObject` for reactive updates |
| Touch targets too small | High | Enforce frame with 44x44pt |
| Menu not accessible | Medium | Add accessibilityLabel to Menu |

## Next Steps
- Proceed to Phase 2: View Mode Toggle
