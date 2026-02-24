# Phase 3: Integration

## Context Links

- ViewModel: `trending-movie-ios/Presentation/SwiftUI/ViewModels/ObservableMovieDetailsViewModel.swift`
- View: `trending-movie-ios/Presentation/SwiftUI/Views/MovieDetailsView.swift`
- DI Container: `trending-movie-ios/DI/AppContainer.swift`
- Use Case Protocol: `MoviesDomain/Sources/MoviesDomain/UseCases/FetchDetailsMovieUseCase.swift`

## Overview

- **Priority:** P2
- **Status:** completed
- **Effort:** 2h

Wire up new sections in MovieDetailsView and update ViewModel to fetch watch providers, reviews, and similar movies.

## Key Insights

1. Current ViewModel uses callback-based use case pattern
2. Movie details already fetch credits, videos, images via `append_to_response`
3. Similar movies endpoint exists but not connected to details view
4. Need to add parallel data fetching for watch providers + reviews

## Requirements

### Functional
- Fetch watch providers, reviews, similar movies when loading details
- Display all 5 new sections in correct order
- Navigate to similar movie detail on tap

### Non-Functional
- Parallel API calls where possible
- Loading states for each section
- Error handling per section

## Architecture

```
ObservableMovieDetailsViewModel
    + watchProviders: WatchProviders?
    + reviews: [Review]
    + similarMovies: [Movie]
    + loadSupplementaryData()
         |
         v
FetchDetailsMovieUseCase (existing)
FetchWatchProvidersUseCase (new or extend repository)
FetchReviewsUseCase (new or extend repository)
FetchSimilarMoviesUseCase (existing, reuse)
         |
         v
MovieDetailsView
    + WhereToWatchSection
    + CastCarouselSection
    + FullMetadataSection
    + ReviewsSection
    + SimilarMoviesSection
```

## Related Code Files

### Files to Modify
- `trending-movie-ios/Presentation/SwiftUI/ViewModels/ObservableMovieDetailsViewModel.swift`
- `trending-movie-ios/Presentation/SwiftUI/Views/MovieDetailsView.swift`
- `MoviesDomain/Sources/MoviesDomain/UseCases/FetchDetailsMovieUseCase.swift` (or create new use cases)

### Files to Reference
- `trending-movie-ios/DI/AppContainer.swift`
- `trending-movie-ios/DI/PresentationContainer.swift`

## Implementation Steps

### Step 1: Extend ViewModel Properties (15 min)

File: `trending-movie-ios/Presentation/SwiftUI/ViewModels/ObservableMovieDetailsViewModel.swift`

Add new published properties:

```swift
@MainActor
class ObservableMovieDetailsViewModel: ObservableObject {
    // Existing properties...

    // NEW: Supplementary data
    @Published var watchProviders: WatchProviders?
    @Published var reviews: [Review] = []
    @Published var similarMovies: [Movie] = []
    @Published var isLoadingSupplementary: Bool = false

    // Add repository reference if not using separate use cases
    private let moviesRepository: MoviesRepository
```

Update init:

```swift
init(movie: Movie,
     fetchDetailsMovieUseCase: FetchDetailsMovieUseCaseProtocol,
     moviesRepository: MoviesRepository) {
    self.initialMovie = movie
    self.detailsMovieUseCase = fetchDetailsMovieUseCase
    self.moviesRepository = moviesRepository
}
```

### Step 2: Add Supplementary Data Loading (30 min)

Add new method to load watch providers, reviews, similar movies:

```swift
private func loadSupplementaryData() {
    isLoadingSupplementary = true

    // Load watch providers
    moviesRepository.fetchWatchProviders(movieId: initialMovie.id) { [weak self] result in
        DispatchQueue.main.async {
            switch result {
            case .success(let providers):
                self?.watchProviders = providers
            case .failure:
                // Silent fail - section will be hidden
                break
            }
        }
    }

    // Load reviews (first page only)
    moviesRepository.fetchReviews(movieId: initialMovie.id, page: 1) { [weak self] result in
        DispatchQueue.main.async {
            switch result {
            case .success(let reviews):
                self?.reviews = reviews
            case .failure:
                break
            }
        }
    }

    // Load similar movies
    // Note: Check if repository has this method or add it
    moviesRepository.fetchSimilarMovies(movieId: initialMovie.id, page: 1) { [weak self] result in
        DispatchQueue.main.async {
            switch result {
            case .success(let moviesPage):
                self?.similarMovies = moviesPage.movies
            case .failure:
                break
            }
            self?.isLoadingSupplementary = false
        }
    }
}
```

Update `viewDidLoad()`:

```swift
func viewDidLoad() {
    movie = initialMovie
    loadDetails()
    loadSupplementaryData()  // NEW
}
```

### Step 3: Add Repository Method for Similar Movies (15 min)

File: `MoviesDomain/Sources/MoviesDomain/Repositories/MoviesRepository.swift`

Add protocol method (if not exists):

```swift
@discardableResult
func fetchSimilarMovies(movieId: Movie.Identifier,
                        page: Int,
                        completion: @escaping MoviesPageResult) -> Cancellable?
```

File: `MoviesData/Sources/MoviesData/Repositories/DefaultMoviesRepository.swift`

Add implementation:

```swift
public func fetchSimilarMovies(movieId: Movie.Identifier,
                               page: Int,
                               completion: @escaping MoviesPageResult) -> MoviesDomain.Cancellable? {
    let cancellable = networkService.request(
        .similarMovies(movieId: movieId, page: page),
        type: MoviesResponseDTO.self
    ) { result in
        switch result {
        case .success(let responseDTO):
            completion(.success(responseDTO.toDomain()))
        case .failure(let error):
            completion(.failure(error))
        }
    }
    return cancellable
}
```

### Step 4: Update DI Container (10 min)

File: `trending-movie-ios/DI/PresentationContainer.swift`

Update ViewModel factory to include repository:

```swift
extension PresentationContainer {
    var movieDetailsViewModel: ParameterFactory<Movie, ObservableMovieDetailsViewModel> {
        Factory(self) { movie in
            ObservableMovieDetailsViewModel(
                movie: movie,
                fetchDetailsMovieUseCase: AppContainer.shared.fetchDetailsMovieUseCase(),
                moviesRepository: AppContainer.shared.moviesRepository()
            )
        }
    }
}
```

### Step 5: Update MovieDetailsView (30 min)

File: `trending-movie-ios/Presentation/SwiftUI/Views/MovieDetailsView.swift`

Add new sections to contentView:

```swift
private var contentView: some View {
    ScrollView {
        VStack(spacing: 0) {
            if let movie = viewModel.movie {
                // Existing: Backdrop Hero
                ZStack {
                    MovieBackdropHero(movie: movie, height: 500)
                    VStack {
                        MovieDetailsHeader(...)
                        Spacer()
                    }
                }
                .frame(height: 500)

                // Existing: Metadata Bar
                MovieMetadataBar(movie: movie)
                    .padding(.top, 24)

                // Existing: Action Buttons
                MovieActionButtons(...)
                    .padding(.top, 24)

                // NEW: Where to Watch
                WhereToWatchSection(watchProviders: viewModel.watchProviders)
                    .padding(.top, 24)

                // Existing: Story Line
                StoryLineSection(movie: movie)
                    .padding(.top, 24)

                // Existing: Cast and Crew
                CastCrewSection(movie: movie)
                    .padding(.top, 24)

                // NEW: Cast Carousel with Photos
                if let credits = movie.credits, !credits.cast.isEmpty {
                    CastCarouselSection(cast: credits.cast)
                        .padding(.top, 24)
                }

                // NEW: Full Metadata
                FullMetadataSection(movie: movie)
                    .padding(.top, 24)

                // NEW: Reviews
                ReviewsSection(reviews: viewModel.reviews)
                    .padding(.top, 24)

                // NEW: Similar Movies
                SimilarMoviesSection(
                    movies: viewModel.similarMovies,
                    onMovieTap: { similarMovie in
                        // Navigate to similar movie detail
                        handleSimilarMovieTap(similarMovie)
                    }
                )
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// Add navigation handler
private func handleSimilarMovieTap(_ movie: Movie) {
    // Create new ViewModel for selected movie and navigate
    // This depends on navigation pattern used in app
    // Option 1: Use NavigationLink with new ViewModel
    // Option 2: Use coordinator pattern

    // For now, store selected movie for parent coordinator to handle
    viewModel.selectedSimilarMovie = movie
}
```

### Step 6: Add Navigation State to ViewModel (10 min)

Add to ViewModel for coordinator pattern:

```swift
@Published var selectedSimilarMovie: Movie?

func selectSimilarMovie(_ movie: Movie) {
    selectedSimilarMovie = movie
}

func clearSelection() {
    selectedSimilarMovie = nil
}
```

### Step 7: Update Use Case or Create New Ones (optional)

If following clean architecture strictly, create dedicated use cases:

File: `MoviesDomain/Sources/MoviesDomain/UseCases/FetchWatchProvidersUseCase.swift`

```swift
public protocol FetchWatchProvidersUseCaseProtocol {
    @discardableResult
    func execute(movieId: Movie.Identifier, completion: @escaping (Result<WatchProviders?, Error>) -> Void) -> Cancellable?
}

public final class FetchWatchProvidersUseCase: FetchWatchProvidersUseCaseProtocol {
    private let repository: MoviesRepository

    public init(repository: MoviesRepository) {
        self.repository = repository
    }

    public func execute(movieId: Movie.Identifier, completion: @escaping (Result<WatchProviders?, Error>) -> Void) -> Cancellable? {
        return repository.fetchWatchProviders(movieId: movieId, completion: completion)
    }
}
```

## Todo List

- [x] Add `watchProviders`, `reviews`, `similarMovies` properties to ViewModel
- [x] Add `loadSupplementaryData()` method to ViewModel
- [x] Update `viewDidLoad()` to call supplementary data load
- [x] Add `fetchSimilarMovies` to repository protocol + implementation
- [x] Update DI container for ViewModel factory
- [x] Add new sections to MovieDetailsView in correct order
- [x] Add navigation handler for similar movies
- [x] Build and verify no compile errors
- [x] Test on simulator with real movie data

## Success Criteria

- [x] All 5 new sections display when data available
- [x] Sections hide gracefully when no data
- [x] Similar movies navigate to detail view
- [x] Loading states don't block main UI
- [x] No memory leaks from API calls

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| API rate limiting | Medium | Stagger API calls if needed |
| Slow API responses | Low | Sections load independently |
| Navigation state | Low | Use coordinator pattern |

## Security Considerations

- No new security concerns
- API key already secured in AppContainer

## Next Steps

- Complete Phase 4: Bug Fixes
- Run tests to verify no regressions
- Test with various movie IDs
