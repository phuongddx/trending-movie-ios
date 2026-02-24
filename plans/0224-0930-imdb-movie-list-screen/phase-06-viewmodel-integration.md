# Phase 6: ViewModel Integration

## Overview
- **Priority:** P1
- **Status:** Pending
- **Effort:** 2h

Wire filters and view modes to `ObservableMoviesListViewModel`.

## Context Links
- Existing ViewModel: `trending-movie-ios/Presentation/SwiftUI/ViewModels/ObservableMoviesListViewModel.swift`
- DI Container: `DI/PresentationContainer.swift`
- Filter Models: Phase 3

## Requirements

### Functional
- Add `activeFilters: MovieFilters` property
- Add `viewMode: ViewMode` property
- Use discover use case when filters active
- Support infinite scroll
- Support pull-to-refresh

### Non-Functional
- Reactive updates via `@Published`
- Cancel pending requests on filter change

## Architecture

```swift
@MainActor
class ObservableMoviesListViewModel: ObservableObject {
    // Existing
    @Published var movies: [MoviesListItemViewModel] = []
    @Published var loading: MoviesListViewModelLoading? = nil
    @Published var searchQuery: String = ""

    // NEW
    @Published var activeFilters: MovieFilters = .default
    @AppStorage("moviesViewMode") var viewMode: ViewMode = .list

    // Use cases
    private let discoverMoviesUseCase: DiscoverMoviesUseCaseProtocol
    private let trendingMoviesUseCase: TrendingMoviesUseCaseProtocol
    private let searchMoviesUseCase: SearchMoviesUseCaseProtocol
}
```

## Related Code Files

| File | Action | Notes |
|------|--------|-------|
| `Presentation/SwiftUI/ViewModels/ObservableMoviesListViewModel.swift` | Modify | Add filter/view state |
| `DI/PresentationContainer.swift` | Modify | Add discover use case |
| `Presentation/SwiftUI/Views/MoviesListView.swift` | Modify | Use new properties |

## Implementation Steps

### Step 1: Add New Properties to ViewModel
```swift
// In ObservableMoviesListViewModel.swift

// NEW: Filter state
@Published var activeFilters: MovieFilters = .default

// NEW: View mode (persisted)
@AppStorage("moviesViewMode") var viewMode: ViewMode = .list

// NEW: Discover use case
private let discoverMoviesUseCase: DiscoverMoviesUseCaseProtocol
```

### Step 2: Update Init
```swift
nonisolated init(
    searchMoviesUseCase: SearchMoviesUseCaseProtocol,
    trendingMoviesUseCase: TrendingMoviesUseCaseProtocol,
    discoverMoviesUseCase: DiscoverMoviesUseCaseProtocol,
    onMovieSelected: ((Movie) -> Void)? = nil
) {
    self.searchMoviesUseCase = searchMoviesUseCase
    self.trendingMoviesUseCase = trendingMoviesUseCase
    self.discoverMoviesUseCase = discoverMoviesUseCase
    self.onMovieSelected = onMovieSelected

    Task { @MainActor in
        setupSearchDebouncing()
        setupFilterObservation() // NEW
    }
}
```

### Step 3: Add Filter Observation
```swift
private func setupFilterObservation() {
    // Observe filter changes and reload
    $activeFilters
        .removeDuplicates()
        .sink { [weak self] _ in
            Task { @MainActor in
                self?.resetPages()
                self?.loadMovies()
            }
        }
        .store(in: &cancellables)
}

private var cancellables = Set<AnyCancellable>()
```

### Step 4: Update loadMovies Logic
```swift
private func loadMovies(loading: MoviesListViewModelLoading = .fullScreen) {
    self.loading = loading

    // Cancel pending request
    moviesLoadTask?.cancel()

    if !searchQuery.isEmpty {
        // Search mode
        performSearch(query: searchQuery, loading: loading)
    } else if activeFilters.isActive {
        // Filtered mode - use discover
        loadDiscoverMovies(loading: loading)
    } else {
        // Default - trending
        loadTrendingMovies(loading: loading)
    }
}

private func loadDiscoverMovies(loading: MoviesListViewModelLoading = .fullScreen) {
    moviesLoadTask = discoverMoviesUseCase.execute(
        filters: activeFilters,
        page: nextPage,
        cached: { [weak self] page in
            Task { @MainActor in
                self?.appendPage(page)
            }
        },
        completion: { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let page):
                    self?.appendPage(page)
                case .failure(let error):
                    self?.handleError(error)
                }
                self?.loading = nil
            }
        }
    )
}
```

### Step 5: Update DI Container
```swift
// DI/PresentationContainer.swift
extension AppContainer {
    func observableMoviesListViewModel() -> ObservableMoviesListViewModel {
        return ObservableMoviesListViewModel(
            searchMoviesUseCase: searchMoviesUseCase(),
            trendingMoviesUseCase: trendingMoviesUseCase(),
            discoverMoviesUseCase: discoverMoviesUseCase()
        )
    }
}
```

### Step 6: Update MoviesListView
```swift
// In MoviesListView.swift

// Add filter bar
private var filterBar: some View {
    HStack(spacing: DSSpacing.sm) {
        // Active filter chips
        ForEach(viewModel.activeFilters.activeChips) { chip in
            FilterChipView(chip: chip) {
                viewModel.removeFilter(chip)
            }
        }

        Spacer()

        // Filter button
        Button(action: { showFilterSheet = true }) {
            Image(systemName: viewModel.activeFilters.isActive
                ? "line.3.horizontal.decrease.circle.fill"
                : "line.3.horizontal.decrease.circle")
        }
    }
    .padding(.horizontal, DSSpacing.Padding.container)
}

// Add removeFilter to ViewModel
func removeFilter(_ chip: FilterChip) {
    switch chip.category {
    case .sort:
        activeFilters.sortBy = .popularity
    case .genre:
        if let genreId = Int(chip.id.replacingOccurrences(of: "genre_", with: "")) {
            activeFilters.genres.remove(genreId)
        }
    case .rating:
        activeFilters.minimumRating = 0
    case .year:
        let currentYear = Calendar.current.component(.year, from: Date())
        activeFilters.yearRange = 1990...currentYear
    }
}
```

## Todo List

- [ ] Add `activeFilters` property to ViewModel
- [ ] Add `viewMode` property with `@AppStorage`
- [ ] Add `discoverMoviesUseCase` dependency
- [ ] Implement `setupFilterObservation()`
- [ ] Update `loadMovies()` to use discover when filters active
- [ ] Add `removeFilter(_:)` method
- [ ] Update `PresentationContainer` DI
- [ ] Add `filterBar` to `MoviesListView`

## Success Criteria

- [ ] Filters trigger movie reload
- [ ] View mode persists across launches
- [ ] Discover use case called when filters active
- [ ] Removing chip updates filters
- [ ] Pull-to-refresh works with filters

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Filter observation loop | Medium | Use `.removeDuplicates()` |
| Race condition on rapid filter change | Medium | Cancel pending task before new |

## Next Steps
- Proceed to Phase 7: Polish & Tests
