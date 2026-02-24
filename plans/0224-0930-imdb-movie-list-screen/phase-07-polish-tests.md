# Phase 7: Polish & Tests

## Overview
- **Priority:** P2
- **Status:** Pending
- **Effort:** 3h

Add animations, accessibility, and unit tests.

## Context Links
- All previous phases
- Test patterns: `trending-movie-iosTests/`

## Requirements

### Functional
- Smooth view mode transition animation
- Skeleton loading states
- Pull-to-refresh indicator

### Non-Functional
- VoiceOver labels on all interactive elements
- Dynamic Type support
- Reduce Motion support
- 44x44pt touch targets verified

## Implementation Steps

### Step 1: View Mode Transition Animation
```swift
// In MoviesListView
@ViewBuilder
private var moviesContentView: some View {
    switch viewModel.viewMode {
    case .list:
        moviesListView
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                removal: .opacity
            ))
    case .grid:
        moviesGridView
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                removal: .opacity
            ))
    }
}
.animation(.easeInOut(duration: 0.25), value: viewModel.viewMode)

// Respect Reduce Motion
.animation(
    UIAccessibility.isReduceMotionEnabled
        ? .none
        : .easeInOut(duration: 0.25),
    value: viewModel.viewMode
)
```

### Step 2: Accessibility Labels
```swift
// MovieRowView additions
.contentShape(Rectangle())
.accessibilityElement(children: .combine)
.accessibilityLabel("\(movie.title), \(movie.releaseDate), rated \(movie.voteAverage) out of 10")
.accessibilityHint("Double tap to view details")
.accessibilityAction(named: "Add to watchlist") {
    toggleWatchlist()
}

// Filter button
.accessibilityLabel("Open filters")
.accessibilityHint("Currently \(viewModel.activeFilters.isActive ? "\(viewModel.activeFilters.activeChips.count) filters active" : "no filters active")")

// View mode toggle
.accessibilityLabel("View mode, currently \(viewModel.viewMode == .list ? "list" : "grid")")
```

### Step 3: Dynamic Type Support
```swift
// Use semantic fonts, not fixed sizes
Text(movie.title)
    .font(DSTypography.h4SwiftUI(weight: .semibold))
    // DSTypography should use .title3, .body, etc. internally

// Adjust layout for accessibility sizes
@ViewBuilder
private var posterImageView: some View {
    GeometryReader { geometry in
        let sizeCategory = geometry.sizeCategory
        let posterHeight: CGFloat = {
            switch sizeCategory {
            case .extraSmall, .small, .medium: return 90
            case .large, .extraLarge, .extraExtraLarge: return 110
            case .extraExtraExtraLarge: return 130
            @unknown default: return 90
            }
        }()

        MoviePosterImage.compact(posterPath: movie.posterImagePath)
            .frame(width: posterHeight * 2/3, height: posterHeight)
    }
}
```

### Step 4: Unit Tests

#### Test: MovieFilters.isActive
```swift
// trending-movie-iosTests/Domain/Models/MovieFiltersTests.swift
import XCTest
@testable import MoviesDomain

final class MovieFiltersTests: XCTestCase {

    func test_defaultFilters_notActive() {
        let filters = MovieFilters.default
        XCTAssertFalse(filters.isActive)
    }

    func test_filtersWithGenre_isActive() {
        var filters = MovieFilters.default
        filters.genres.insert(28) // Action
        XCTAssertTrue(filters.isActive)
    }

    func test_filtersWithRating_isActive() {
        var filters = MovieFilters.default
        filters.minimumRating = 7.0
        XCTAssertTrue(filters.isActive)
    }

    func test_filterChips_generatedCorrectly() {
        var filters = MovieFilters.default
        filters.genres.insert(28)
        filters.minimumRating = 7.0

        let chips = filters.activeChips

        XCTAssertTrue(chips.contains { $0.category == .genre })
        XCTAssertTrue(chips.contains { $0.category == .rating })
    }
}
```

#### Test: ViewModel Filter Integration
```swift
// trending-movie-iosTests/Presentation/MovieList/MoviesListViewModelTests.swift
import XCTest
@testable import trending_movie_ios
@testable import MoviesDomain

final class MoviesListViewModelFilterTests: XCTestCase {
    var sut: ObservableMoviesListViewModel!
    var mockDiscoverUseCase: MockDiscoverMoviesUseCase!

    override func setUp() {
        mockDiscoverUseCase = MockDiscoverMoviesUseCase()
        sut = ObservableMoviesListViewModel(
            searchMoviesUseCase: MockSearchMoviesUseCase(),
            trendingMoviesUseCase: MockTrendingMoviesUseCase(),
            discoverMoviesUseCase: mockDiscoverUseCase
        )
    }

    func test_whenFiltersApplied_usesDiscoverUseCase() {
        // Given
        let expectation = expectation(description: "Load movies")

        // When
        sut.activeFilters.genres.insert(28)

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockDiscoverUseCase.executeCalled)
        XCTAssertEqual(mockDiscoverUseCase.lastFilters?.genres, [28])
    }
}
```

#### Test: DiscoverMoviesUseCase
```swift
// trending-movie-iosTests/Domain/UseCases/DiscoverMoviesUseCaseTests.swift
import XCTest
@testable import MoviesDomain

final class DiscoverMoviesUseCaseTests: XCTestCase {
    var sut: DiscoverMoviesUseCase!
    var mockRepository: MockMoviesRepository!

    override func setUp() {
        mockRepository = MockMoviesRepository()
        sut = DiscoverMoviesUseCase(moviesRepository: mockRepository)
    }

    func test_execute_callsRepositoryWithCorrectFilters() {
        // Given
        var filters = MovieFilters.default
        filters.genres.insert(28)
        filters.minimumRating = 7.0
        filters.sortBy = .rating

        // When
        let _ = sut.execute(filters: filters, page: 1, cached: { _ in }, completion: { _ in })

        // Then
        XCTAssertTrue(mockRepository.fetchDiscoverMoviesCalled)
        XCTAssertEqual(mockRepository.lastFilters?.genres, [28])
        XCTAssertEqual(mockRepository.lastFilters?.minimumRating, 7.0)
        XCTAssertEqual(mockRepository.lastFilters?.sortBy, .rating)
    }
}
```

### Step 5: Pull-to-Refresh
```swift
// Already using .refreshable in MoviesListView
.refreshable {
    await viewModel.refreshMovies()
}

// In ViewModel
func refreshMovies() async {
    resetPages()
    loadMovies()
}
```

### Step 6: Skeleton Loading
```swift
// Use existing skeleton views
if viewModel.isLoading && viewModel.movies.isEmpty {
    ForEach(0..<6, id: \.self) { _ in
        MovieRowSkeleton()
    }
}
```

## Todo List

- [ ] Add `.animation()` to view mode toggle
- [ ] Add Reduce Motion check
- [ ] Add VoiceOver labels to all components
- [ ] Test Dynamic Type (AX sizes)
- [ ] Create `MovieFiltersTests`
- [ ] Create `MoviesListViewModelFilterTests`
- [ ] Create `DiscoverMoviesUseCaseTests`
- [ ] Run all tests
- [ ] Accessibility Inspector audit

## Success Criteria

- [ ] View mode toggle animates smoothly
- [ ] Reduce Motion disables animations
- [ ] VoiceOver navigates all elements
- [ ] Dynamic Type scales correctly
- [ ] All touch targets 44x44pt
- [ ] Unit tests pass (>80% coverage on new code)
- [ ] Accessibility Inspector shows no warnings

## Accessibility Checklist

| Item | Status |
|------|--------|
| Touch targets 44x44pt | [ ] |
| Color contrast 4.5:1 | [ ] |
| VoiceOver labels | [ ] |
| Dynamic Type | [ ] |
| Reduce Motion | [ ] |
| Focus management | [ ] |

## Test Coverage Goals

| Component | Target |
|-----------|--------|
| MovieFilters | 100% |
| DiscoverMoviesUseCase | 100% |
| ViewModel filter logic | 80%+ |
| Filter views | UI tests |

## Final Deliverable

Run full test suite:
```bash
bundle exec fastlane tests
# or
xcodebuild test -project trending-movie-ios.xcodeproj -scheme trending-movie-ios -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'
```

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Dynamic Type breaks layout | Medium | Test all AX sizes |
| Test flakiness | Low | Use mocks, avoid real network |

## Completion

After this phase:
- All features implemented
- Tests passing
- Accessibility verified
- Ready for code review
