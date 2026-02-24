# Phase 1: Debounce + Accessibility

**Status:** Pending
**Priority:** Critical
**Effort:** Low
**Est. Time:** 30 min

---

## Overview

Optimize debounce timing (500ms → 300ms) and add comprehensive accessibility labels to SearchView components.

## Requirements

### Functional
- Configurable debounce timing (200-500ms range)
- Accessibility labels on all interactive elements
- Screen reader announcements for state changes

### Non-Functional
- iOS 14+ compatibility (components require iOS 15+)
- No performance impact from accessibility additions

## Current State Analysis

**SearchViewModel.swift:37-48** - Already has debounce via Combine:
```swift
searchCancellable = $searchQuery
    .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
    .removeDuplicates()
```

**Issue:** 500ms too long, users perceive lag. Optimal: 300ms.

## Implementation Steps

### Step 1: Make Debounce Configurable

**File:** `SearchViewModel.swift`

```swift
// Add configuration constant
private enum Configuration {
    static let debounceInterval: Int = 300 // milliseconds
}

// Update setupSearchDebouncing()
private func setupSearchDebouncing() {
    searchCancellable = $searchQuery
        .debounce(for: .milliseconds(Configuration.debounceInterval), scheduler: DispatchQueue.main)
        .removeDuplicates()
        .sink { [weak self] query in
            if query.isEmpty {
                self?.clearSearch()
            } else {
                self?.updateSuggestions(for: query)
            }
        }
}
```

### Step 2: Add Accessibility to SearchViewModel

**File:** `SearchViewModel.swift`

```swift
// Add announcement helper
func announceSearchResults(count: Int) {
    let message = count == 0
        ? "No movies found"
        : "\(count) movies found"
    UIAccessibility.post(notification: .announcement, argument: message)
}

// Call in handleSearchResult
private func handleSearchResult(_ moviesPage: MoviesPage, isLoadingMore: Bool) {
    // ... existing code ...
    if !isLoadingMore {
        announceSearchResults(count: searchResults.count)
    }
}
```

### Step 3: Add Accessibility to DSSearchField

**File:** `DSFormComponents.swift` (DSSearchField)

```swift
struct DSSearchField: View {
    // ... existing properties ...

    var body: some View {
        HStack(spacing: 12) {
            CinemaxIconView(.search, size: .small, color: DSColors.secondaryTextSwiftUI)
                .accessibilityHidden(true) // Decorative

            TextField(placeholder, text: $text)
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.primaryTextSwiftUI)
                .textFieldStyle(PlainTextFieldStyle())
                .accessibilityLabel("Search movies")
                .accessibilityHint("Type to search for movies")
                .accessibilityAddTraits(.isSearchField)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    CinemaxIconView(.remove, size: .small, color: DSColors.tertiaryTextSwiftUI)
                }
                .accessibilityLabel("Clear search")
                .accessibilityHint("Removes all text from search field")
            }
        }
        // ... existing styling ...
    }
}
```

### Step 4: Add Accessibility to SearchView

**File:** `SearchView.swift`

```swift
// Loading view accessibility
private var loadingView: some View {
    ScrollView {
        VStack(spacing: 16) {
            // ... skeleton content ...
        }
    }
    .accessibilityLabel("Loading movies")
    .accessibilityHidden(true) // Skeleton not meaningful to screen reader
}

// No results view accessibility
private var noResultsView: some View {
    VStack(spacing: 24) {
        // ... existing content ...
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("No results found. Try different keywords.")
}

// Search results list accessibility
private var searchResultsList: some View {
    ScrollView {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.searchResults, id: \.id) { movie in
                MovieCard(movie: movie, style: .compact, ...)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(movie.title), \(movie.releaseYear), rated \(movie.voteAverage)")
            }
        }
    }
}
```

### Step 5: Add Results Count Header (Bonus)

**File:** `SearchView.swift`

```swift
// Add above searchResultsList
private var resultsCountHeader: some View {
    HStack {
        Text("\(viewModel.searchResults.count) movies found")
            .font(DSTypography.bodySmallSwiftUI())
            .foregroundColor(DSColors.secondaryTextSwiftUI)
        Spacer()
    }
    .padding(.horizontal, 20)
    .accessibilityHidden(true) // Announced via UIAccessibility
}
```

## Todo Checklist

- [ ] Update debounce timing to 300ms in SearchViewModel
- [ ] Add `announceSearchResults()` helper to SearchViewModel
- [ ] Add accessibility labels to DSSearchField (DSFormComponents.swift)
- [ ] Add accessibility to loadingView in SearchView
- [ ] Add accessibility to noResultsView in SearchView
- [ ] Add accessibility to MovieCard in searchResultsList
- [ ] Test with VoiceOver enabled

## Testing

### Manual Testing
1. Enable VoiceOver (Settings > Accessibility > VoiceOver)
2. Navigate to SearchView
3. Verify search field announces "Search movies, text field"
4. Perform search, verify results count announced
5. Verify "Clear search" button accessible

### Unit Tests
```swift
func testDebounceTiming() {
    let expectation = expectation(description: "Debounce")
    // Test 300ms delay
}
```

## Success Criteria

- [ ] Debounce fires after 300ms ± 50ms
- [ ] All buttons have accessibility labels
- [ ] Screen reader announces results count
- [ ] No accessibility warnings in console

## Next Phase

→ [Phase 2: Search History](./phase-02-search-history.md)
