# Phase 3: Animations & Micro-interactions

**Status:** Pending
**Priority:** Medium
**Effort:** Medium
**Est. Time:** 1 hour
**Depends on:** Phase 2

---

## Overview

Add polished animations to SearchView with full support for `accessibilityReduceMotion` environment.

## Requirements

### Functional
- Staggered results appearance animation
- Search field focus animation
- Smooth transitions between states
- Tag tap bounce effect

### Non-Functional
- Respect system reduce motion setting
- 60fps on iPhone 8+
- Spring-based natural feel

## Animation Specifications

| Element | Animation | Duration | Easing |
|---------|-----------|----------|--------|
| Results stagger | Move + opacity | 0.3s per item | Spring(response: 0.3) |
| Search focus | Scale + shadow | 0.2s | easeInOut |
| Suggestions | Move from top | 0.25s | easeOut |
| Tags | Scale bounce | 0.15s | spring |
| Loading more | Fade in | 0.2s | easeIn |

## Implementation Steps

### Step 1: Add Reduce Motion Environment

**File:** `SearchView.swift`

```swift
struct SearchView: View {
    // ... existing properties ...

    // Add environment
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // Animation helper
    private func animation<T: Equatable>(value: T) -> Animation? {
        reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.8)
    }

    private var defaultTransition: AnyTransition {
        reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity)
    }
}
```

### Step 2: Add Search Field Focus Animation

**File:** `SearchView.swift`

```swift
// Add focus state
@FocusState private var isSearchFocused: Bool

// Update search field section
VStack(spacing: 16) {
    DSSearchField(
        text: $viewModel.searchQuery,
        placeholder: "Search movies...",
        onSearchTap: {
            viewModel.performSearch()
        }
    )
    .focused($isSearchFocused)
    .scaleEffect(isSearchFocused ? 1.02 : 1.0)
    .shadow(
        color: isSearchFocused
            ? DSColors.accentSwiftUI.opacity(0.3)
            : Color.clear,
        radius: isSearchFocused ? 8 : 0
    )
    .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: isSearchFocused)

    // Suggestions dropdown
    if !viewModel.suggestions.isEmpty && !viewModel.searchQuery.isEmpty {
        SearchSuggestionsList(...)
            .transition(defaultTransition)
    }
}
```

### Step 3: Add Staggered Results Animation

**File:** `SearchView.swift`

```swift
private var searchResultsList: some View {
    ScrollView {
        LazyVStack(spacing: 16) {
            // Results count header
            if !viewModel.searchResults.isEmpty {
                resultsCountHeader
                    .transition(.opacity)
            }

            // Staggered results
            ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, movie in
                MovieCard(
                    movie: movie,
                    style: .compact,
                    onTap: { viewModel.selectMovie(movie) },
                    onWatchlistTap: { viewModel.toggleWatchlist(movie) },
                    onFavoriteTap: { viewModel.toggleFavorite(movie) }
                )
                .transition(defaultTransition)
                .animation(
                    reduceMotion ? .none : .spring(response: 0.3)
                        .delay(Double(index) * 0.05),
                    value: viewModel.searchResults.count
                )
            }

            // Loading more indicator
            if viewModel.isLoadingMore {
                loadingMoreIndicator
                    .transition(.opacity)
                    .animation(.easeIn(duration: 0.2), value: viewModel.isLoadingMore)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

private var loadingMoreIndicator: some View {
    HStack {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: DSColors.accentSwiftUI))
        Text("Loading more...")
            .font(DSTypography.bodySmallSwiftUI())
            .foregroundColor(DSColors.secondaryTextSwiftUI)
    }
    .padding(24)
}
```

### Step 4: Add Tag Bounce Animation

**File:** `SearchView.swift` or create component

```swift
struct BouncyTag: View {
    let title: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.bodySmallSwiftUI(weight: .medium))
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(DSColors.surfaceSwiftUI)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DSColors.accentSwiftUI.opacity(0.3), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.15), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
```

### Step 5: Update Popular Searches with Animation

**File:** `SearchView.swift`

```swift
// Replace DSTag with BouncyTag in popular searches grid
LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
    ForEach(viewModel.popularSearches, id: \.self) { search in
        BouncyTag(title: search) {
            viewModel.searchQuery = search
            viewModel.performSearch()
        }
    }
}
```

### Step 6: State Transition Animations

**File:** `SearchView.swift`

```swift
// Wrap content ZStack with animation
ZStack {
    if viewModel.searchQuery.isEmpty {
        emptySearchView
            .transition(reduceMotion ? .opacity : .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .opacity
            ))
    } else if viewModel.isLoading && viewModel.searchResults.isEmpty {
        loadingView
            .transition(.opacity)
    } else if viewModel.searchResults.isEmpty && !viewModel.isLoading {
        noResultsView
            .transition(reduceMotion ? .opacity : .asymmetric(
                insertion: .scale(scale: 0.95).combined(with: .opacity),
                removal: .opacity
            ))
    } else {
        searchResultsList
            .transition(.opacity)
    }
}
.animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: viewModel.searchQuery.isEmpty)
.animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: viewModel.isLoading)
.animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: viewModel.searchResults.isEmpty)
```

## Todo Checklist

- [ ] Add `@Environment(\.accessibilityReduceMotion)` to SearchView
- [ ] Create `animation()` and `defaultTransition` helpers
- [ ] Add focus state and animation to search field
- [ ] Implement staggered results animation
- [ ] Create BouncyTag component
- [ ] Add loading more indicator animation
- [ ] Add state transition animations
- [ ] Test on device with reduce motion enabled/disabled

## Testing

### Manual Testing
1. Perform search - verify staggered results appear
2. Tap search field - verify subtle scale + glow
3. Tap popular search tag - verify bounce
4. Enable Reduce Motion in Settings
5. Repeat tests - verify animations disabled

### Performance Testing
```swift
// Instruments > Time Profiler
// Verify animation frame drops < 5%
```

## Success Criteria

- [ ] All animations use spring physics
- [ ] Reduce motion fully respected
- [ ] 60fps maintained on iPhone 8
- [ ] No animation jank during scrolling
- [ ] Smooth state transitions

## Next Phase

→ [Phase 4: Enhanced Empty States](./phase-04-enhanced-empty-states.md)
