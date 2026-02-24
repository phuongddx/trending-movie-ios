# Phase 2: Search History

**Status:** Pending
**Priority:** High
**Effort:** Medium
**Est. Time:** 1 hour
**Depends on:** Phase 1

---

## Overview

Add persistent search history with UserDefaults storage, displaying recent searches above popular searches.

## Requirements

### Functional
- Store last 5 unique searches
- Persist across app sessions
- FIFO eviction when limit exceeded
- Tap to re-execute search
- Swipe to delete individual items

### Non-Functional
- O(1) lookup performance
- Thread-safe storage access
- Minimal memory footprint

## Architecture

```
SearchHistoryStore (ObservableObject)
├── recentSearches: [String] (@Published)
├── add(_ query: String)
├── remove(_ query: String)
├── clear()
└── Private: UserDefaults persistence
```

## Implementation Steps

### Step 1: Create SearchHistoryStore

**File:** `SearchHistoryStore.swift` (NEW)

```swift
import Foundation
import Combine

/// Manages persistent search history with UserDefaults storage
final class SearchHistoryStore: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var recentSearches: [String] = []

    // MARK: - Configuration
    private enum Configuration {
        static let userDefaultsKey = "com.cinemax.searchHistory"
        static let maxItems = 5
    }

    // MARK: - Initialization
    init() {
        load()
    }

    // MARK: - Public Methods

    /// Add a search query to history
    /// - Parameter query: The search query to add
    func add(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Remove if exists (re-add at front)
        recentSearches.removeAll { $0.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }

        // Insert at front
        recentSearches.insert(trimmed, at: 0)

        // Enforce limit
        if recentSearches.count > Configuration.maxItems {
            recentSearches.removeLast()
        }

        save()
    }

    /// Remove a specific search from history
    /// - Parameter query: The query to remove
    func remove(_ query: String) {
        recentSearches.removeAll { $0 == query }
        save()
    }

    /// Clear all search history
    func clear() {
        recentSearches.removeAll()
        save()
    }

    // MARK: - Private Methods

    private func save() {
        UserDefaults.standard.set(recentSearches, forKey: Configuration.userDefaultsKey)
    }

    private func load() {
        recentSearches = UserDefaults.standard.stringArray(forKey: Configuration.userDefaultsKey) ?? []
    }
}
```

### Step 2: Integrate with SearchViewModel

**File:** `SearchViewModel.swift`

```swift
@MainActor
class SearchViewModel: ObservableObject {
    // ... existing properties ...

    // Add search history
    @Published var searchHistory: [String] = []
    private let historyStore: SearchHistoryStore

    // Update init
    nonisolated init(
        searchMoviesUseCase: SearchMoviesUseCaseProtocol,
        historyStore: SearchHistoryStore = SearchHistoryStore()
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.historyStore = historyStore

        Task { @MainActor in
            self.searchHistory = historyStore.recentSearches
            setupSearchDebouncing()
        }
    }

    // Update performSearch
    func performSearch() {
        guard !searchQuery.isEmpty else { return }

        // Add to history
        historyStore.add(searchQuery)
        searchHistory = historyStore.recentSearches

        // ... rest of existing implementation ...
    }

    // Add history management methods
    func removeFromHistory(_ query: String) {
        historyStore.remove(query)
        searchHistory = historyStore.recentSearches
    }

    func clearSearchHistory() {
        historyStore.clear()
        searchHistory = []
    }
}
```

### Step 3: Create RecentSearchesRow Component

**File:** `SearchView.swift` (add private view)

```swift
// Add after SearchSuggestionsList
private struct RecentSearchRow: View {
    let query: String
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Button(action: onTap) {
                HStack {
                    CinemaxIconView(.clock, size: .small, color: DSColors.tertiaryTextSwiftUI)
                    Text(query)
                        .font(DSTypography.bodyMediumSwiftUI())
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                    Spacer()
                }
            }
            .accessibilityLabel("Search for \(query)")
            .accessibilityHint("Tap to search again")

            Button(action: onDelete) {
                CinemaxIconView(.remove, size: .small, color: DSColors.tertiaryTextSwiftUI)
            }
            .accessibilityLabel("Remove \(query) from history")
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
    }
}
```

### Step 4: Update Empty Search View

**File:** `SearchView.swift`

```swift
private var emptySearchView: some View {
    VStack(spacing: 24) {
        Spacer()

        // ... existing icon and text ...

        Spacer()

        // Recent Searches (NEW - above popular)
        if !viewModel.searchHistory.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    CinemaxIconView(.clock, size: .small, color: DSColors.accentSwiftUI)
                    Text("Recent Searches")
                        .font(DSTypography.h5SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)

                    Spacer()

                    Button("Clear") {
                        viewModel.clearSearchHistory()
                    }
                    .font(DSTypography.captionSwiftUI())
                    .foregroundColor(DSColors.tertiaryTextSwiftUI)
                }

                ForEach(viewModel.searchHistory, id: \.self) { query in
                    RecentSearchRow(
                        query: query,
                        onTap: {
                            viewModel.searchQuery = query
                            viewModel.performSearch()
                        },
                        onDelete: {
                            viewModel.removeFromHistory(query)
                        }
                    )
                }
            }
            .padding(20)
            .background(DSColors.surfaceSwiftUI)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
        }

        // Popular Searches (existing)
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CinemaxIconView(.trending, size: .small, color: DSColors.accentSwiftUI)
                Text("Popular Searches")
                    .font(DSTypography.h5SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)
            }
            // ... existing grid ...
        }
        .padding(20)
    }
}
```

## Todo Checklist

- [ ] Create SearchHistoryStore.swift
- [ ] Add historyStore property to SearchViewModel
- [ ] Update SearchViewModel init with history store
- [ ] Add history management methods (add, remove, clear)
- [ ] Create RecentSearchRow component in SearchView
- [ ] Update emptySearchView to show recent searches
- [ ] Add section headers with icons
- [ ] Test persistence (kill app, relaunch)

## Testing

### Manual Testing
1. Perform 3-4 different searches
2. Clear search field - verify recent searches appear
3. Tap recent search - verify it executes
4. Delete a recent search - verify it's removed
5. Kill app, relaunch - verify history persists

### Unit Tests
```swift
class SearchHistoryStoreTests: XCTestCase {
    var store: SearchHistoryStore!

    override func setUp() {
        store = SearchHistoryStore()
        store.clear()
    }

    func testAddMovesToFront() {
        store.add("First")
        store.add("Second")
        XCTAssertEqual(store.recentSearches, ["Second", "First"])
    }

    func testMaxItemsEnforced() {
        for i in 1...10 {
            store.add("Query \(i)")
        }
        XCTAssertEqual(store.recentSearches.count, 5)
    }

    func testDuplicatesMovedToFront() {
        store.add("Same")
        store.add("Other")
        store.add("Same")
        XCTAssertEqual(store.recentSearches.first, "Same")
    }
}
```

## Success Criteria

- [ ] Search history persists across app restarts
- [ ] Max 5 items stored
- [ ] Most recent search appears first
- [ ] Tap re-executes search
- [ ] Delete removes from history
- [ ] Clear removes all history

## Next Phase

→ [Phase 3: Animations](./phase-03-animations.md)
