# Phase 6: Performance Optimizations

**Status:** Pending
**Priority:** Low
**Effort:** Low
**Est. Time:** 30 min
**Depends on:** Phase 5

---

## Overview

Final performance optimizations including task cancellation, image caching verification, and memory leak prevention.

## Requirements

### Functional
- Proper Task cancellation on ViewModel deinit
- Image caching verified and working
- No memory leaks from search operations

### Non-Functional
- Memory usage stable under repeated searches
- Fast image loading from cache
- Clean cancellation patterns

## Implementation Steps

### Step 1: Add Proper Cancellation to SearchViewModel

**File:** `SearchViewModel.swift`

```swift
@MainActor
class SearchViewModel: ObservableObject {
    // ... existing properties ...

    // Track running tasks
    private var searchTask: Task<Void, Never>?
    private var trendingTask: Task<Void, Never>?

    // Update performSearch with Task
    func performSearch() {
        guard !searchQuery.isEmpty else { return }

        // Cancel previous search
        searchTask?.cancel()

        clearSuggestions()
        isLoading = true
        currentPage = 1
        searchResults.removeAll()

        // Add to history
        historyStore.add(searchQuery)
        searchHistory = historyStore.recentSearches

        // Create new task
        searchTask = Task {
            await executeSearch(page: currentPage)

            // Check for cancellation
            if !Task.isCancelled {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

    // Update loadNextPage with cancellation check
    func loadNextPage() {
        guard hasMorePages && !isLoadingMore else { return }

        searchTask?.cancel()
        isLoadingMore = true
        currentPage += 1

        searchTask = Task {
            await executeSearch(page: currentPage)

            if !Task.isCancelled {
                await MainActor.run {
                    isLoadingMore = false
                }
            }
        }
    }

    // Update loadTrendingMovies with task tracking
    func loadTrendingMovies() {
        guard let trendingUseCase = trendingUseCase else { return }

        trendingTask?.cancel()

        trendingTask = Task {
            // ... implementation with cancellation checks ...
        }
    }

    // Add deinit for cleanup
    nonisolated deinit {
        Task { @MainActor in
            searchTask?.cancel()
            trendingTask?.cancel()
            searchCancellable?.cancel()
        }
    }

    // Add explicit cancel method
    func cancelAllOperations() {
        searchTask?.cancel()
        trendingTask?.cancel()
        currentSearchTask?.cancel()
        searchCancellable?.cancel()
    }
}
```

### Step 2: Verify Image Caching Setup

**File:** `MoviePosterImage.swift` (check existing implementation)

```swift
// Ensure AsyncImage uses proper caching
// If using custom cache, verify configuration:

struct MoviePosterImage: View {
    let url: URL?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                placeholder
            case .empty:
                placeholder
                    .shimmer()
            @unknown default:
                placeholder
            }
        }
        .frame(width: width, height: height)
        .clipped()
    }

    private var placeholder: some View {
        Rectangle()
            .fill(DSColors.surfaceSwiftUI)
            .overlay(
                CinemaxIconView(.film, size: .medium, color: DSColors.tertiaryTextSwiftUI)
            )
    }
}
```

### Step 3: Add URLCache Configuration (if needed)

**File:** `AppContainer.swift` or `AppDelegate.swift`

```swift
// Configure URLCache for image caching
private func configureImageCache() {
    let memoryCapacity = 50 * 1024 * 1024 // 50 MB
    let diskCapacity = 100 * 1024 * 1024 // 100 MB

    let cache = URLCache(
        memoryCapacity: memoryCapacity,
        diskCapacity: diskCapacity,
        diskPath: "imageCache"
    )

    URLCache.shared = cache
}

// Call in app initialization
```

### Step 4: Add Memory Warning Handler

**File:** `SearchViewModel.swift`

```swift
// Add memory pressure handling
func handleMemoryWarning() {
    // Clear cached data if needed
    searchResults.removeAll()
    trendingMovies.removeAll()
    clearSuggestions()
}

// Register in View
// .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
//     viewModel.handleMemoryWarning()
// }
```

### Step 5: Add Performance Metrics (Debug Only)

**File:** `SearchViewModel.swift`

```swift
#if DEBUG
private var searchStartTime: Date?

func logSearchPerformance() {
    if let start = searchStartTime {
        let duration = Date().timeIntervalSince(start)
        print("[Performance] Search completed in \(String(format: "%.2f", duration * 1000))ms")
    }
}
#endif

func performSearch() {
    #if DEBUG
    searchStartTime = Date()
    #endif

    // ... existing implementation ...

    #if DEBUG
    logSearchPerformance()
    #endif
}
```

### Step 6: Optimize List Rendering

**File:** `SearchView.swift`

```swift
// Ensure LazyVStack for performance
private var searchResultsList: some View {
    ScrollView {
        LazyVStack(spacing: 16) { // LazyVStack, not VStack
            // ... content ...
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    // Add id for SwiftUI diffing optimization
    .id("search-results-\(viewModel.searchQuery)")
}

// Add memory-efficient image loading
private struct OptimizedMovieCard: View {
    let movie: MoviesListItemViewModel

    var body: some View {
        MovieCard(movie: movie, style: .compact) { }
            .frame(height: 120) // Fixed height prevents layout shifts
    }
}
```

## Performance Checklist

### Memory
- [ ] Task cancellation on deinit
- [ ] Combine cancellable cleanup
- [ ] Image cache limits configured
- [ ] Memory warning handler registered

### Network
- [ ] Debounce prevents duplicate requests
- [ ] Requests cancelled on new search
- [ ] URLCache configured for images

### Rendering
- [ ] LazyVStack for lists
- [ ] Fixed frame heights where possible
- [ ] Shimmer for loading states
- [ ] No layout shifts during loading

## Testing

### Memory Testing
```swift
// Instruments > Allocations
// 1. Perform 10 searches
// 2. Verify memory doesn't grow unbounded
// 3. Verify memory released after search cleared
```

### Performance Testing
```swift
// Instruments > Time Profiler
// 1. Search and scroll through results
// 2. Verify 60fps maintained
// 3. Check for main thread blocking
```

### Network Testing
```swift
// Network Link Conditioner
// 1. Set to 3G speeds
// 2. Verify graceful degradation
// 3. Verify cancellation works
```

## Success Criteria

- [ ] No memory leaks detected in Instruments
- [ ] Memory usage stable under load
- [ ] Search cancellation prevents wasted work
- [ ] Images load from cache on repeated view
- [ ] 60fps maintained during scrolling
- [ ] App handles memory warnings gracefully

## Final Verification

Run through complete search flow:
1. [ ] Open SearchView - trending loads
2. [ ] Type search - debounce works
3. [ ] Results appear with animation
4. [ ] Scroll through results - smooth
5. [ ] Load more results - pagination works
6. [ ] Clear search - returns to empty state
7. [ ] Kill app - history persists
8. [ ] Relaunch - verify persistence
9. [ ] Memory profile - no leaks

## Plan Complete

All 6 phases implemented. Review and deploy.
