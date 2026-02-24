# Phase 5: API Integration

## Overview
- **Priority:** P1 (Critical path)
- **Status:** Pending
- **Effort:** 3h

Add TMDB discover endpoint support for filtered movie queries.

## Context Links
- Existing API: `MoviesData/Sources/MoviesData/Network/MoviesAPI.swift`
- Repository: `MoviesData/Sources/MoviesData/Repositories/DefaultMoviesRepository.swift`
- TMDB Docs: https://developers.themoviedb.org/3/discover/movie-discover

## Requirements

### Functional
- Support genre filter (comma-separated IDs)
- Support year range (primary_release_date.gte/lte)
- Support minimum rating (vote_average.gte)
- Support sort options

### Non-Functional
- Follow existing Moya pattern
- Cache responses like other endpoints

## Architecture

```
MoviesAPI (Moya TargetType)
└── .discoverMovies(filters: MovieFilters, page: Int)

DefaultMoviesRepository
└── fetchDiscoverMovies(filters:cached:completion:)

DiscoverMoviesUseCase
└── execute(filters:page:cached:completion:)
```

## Related Code Files

| File | Action | Notes |
|------|--------|-------|
| `MoviesData/Sources/MoviesData/Network/MoviesAPI.swift` | Modify | Add discover case |
| `MoviesDomain/Sources/MoviesDomain/Repositories/MoviesRepository.swift` | Modify | Add protocol method |
| `MoviesData/Sources/MoviesData/Repositories/DefaultMoviesRepository.swift` | Modify | Implement fetch |
| `MoviesDomain/Sources/MoviesDomain/UseCases/DiscoverMoviesUseCase.swift` | Create | New use case |
| `DI/AppContainer.swift` | Modify | Register use case |

## Implementation Steps

### Step 1: Add Discover Endpoint to MoviesAPI
```swift
// MoviesData/Sources/MoviesData/Network/MoviesAPI.swift
enum MoviesAPI {
    // ... existing cases
    case discoverMovies(filters: MovieFilters, page: Int)
}

extension MoviesAPI: TargetType {
    var path: String {
        switch self {
        // ... existing cases
        case .discoverMovies:
            return "discover/movie"
        }
    }

    var task: Task {
        switch self {
        // ... existing cases
        case .discoverMovies(let filters, let page):
            var params: [String: Any] = ["page": page]

            // Genres (comma-separated)
            if !filters.genres.isEmpty {
                params["with_genres"] = filters.genres.sorted().map(String.init).joined(separator: ",")
            }

            // Sort
            params["sort_by"] = filters.sortBy.rawValue

            // Minimum rating
            if filters.minimumRating > 0 {
                params["vote_average.gte"] = filters.minimumRating
            }

            // Year range
            let currentYear = Calendar.current.component(.year, from: Date())
            if filters.yearRange.lowerBound > 1990 {
                params["primary_release_date.gte"] = "\(filters.yearRange.lowerBound)-01-01"
            }
            if filters.yearRange.upperBound < currentYear {
                params["primary_release_date.lte"] = "\(filters.yearRange.upperBound)-12-31"
            }

            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
}
```

### Step 2: Add Repository Protocol Method
```swift
// MoviesDomain/Sources/MoviesDomain/Repositories/MoviesRepository.swift
public protocol MoviesRepository {
    // ... existing methods

    @discardableResult
    func fetchDiscoverMovies(
        filters: MovieFilters,
        page: Int,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping MoviesPageResult
    ) -> Cancellable?
}
```

### Step 3: Implement Repository Method
```swift
// MoviesData/Sources/MoviesData/Repositories/DefaultMoviesRepository.swift
public func fetchDiscoverMovies(
    filters: MovieFilters,
    page: Int,
    cached: @escaping (MoviesPage) -> Void,
    completion: @escaping MoviesPageResult
) -> MoviesDomain.Cancellable? {

    // Check cache
    let cacheKey = RequestCacheKey(query: "discover_\(filters.cacheKey)", page: page)
    if let cachedResponse = cache?.getResponse(for: cacheKey) {
        cached(cachedResponse)
    }

    // Fetch from network
    let cancellable = networkService.request(
        .discoverMovies(filters: filters, page: page),
        type: MoviesResponseDTO.self
    ) { [weak self] result in
        switch result {
        case .success(let responseDTO):
            let moviesPage = responseDTO.toDomain()
            self?.cache?.save(response: moviesPage, for: cacheKey)
            completion(.success(moviesPage))
        case .failure(let error):
            completion(.failure(error))
        }
    }

    return cancellable
}
```

### Step 4: Add Cache Key Extension
```swift
// In MovieFilters+Extensions (or in DefaultMoviesRepository file)
extension MovieFilters {
    var cacheKey: String {
        let genresKey = genres.sorted().map(String.init).joined(separator: "_")
        return "\(sortBy.rawValue)_\(genresKey)_\(minimumRating)_\(yearRange.lowerBound)-\(yearRange.upperBound)"
    }
}
```

### Step 5: Create DiscoverMoviesUseCase
```swift
// MoviesDomain/Sources/MoviesDomain/UseCases/DiscoverMoviesUseCase.swift
import Foundation

public protocol DiscoverMoviesUseCaseProtocol {
    @discardableResult
    func execute(
        filters: MovieFilters,
        page: Int,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?
}

public final class DiscoverMoviesUseCase: DiscoverMoviesUseCaseProtocol {
    private let moviesRepository: MoviesRepository

    public init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }

    public func execute(
        filters: MovieFilters,
        page: Int,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {
        return moviesRepository.fetchDiscoverMovies(
            filters: filters,
            page: page,
            cached: cached,
            completion: completion
        )
    }
}
```

### Step 6: Register in DI Container
```swift
// DI/AppContainer.swift
lazy var discoverMoviesUseCase: DiscoverMoviesUseCaseProtocol = {
    DiscoverMoviesUseCase(moviesRepository: moviesRepository())
}()
```

## Todo List

- [ ] Add `.discoverMovies` case to `MoviesAPI`
- [ ] Implement `task` with filter params
- [ ] Add `fetchDiscoverMovies` to `MoviesRepository` protocol
- [ ] Implement in `DefaultMoviesRepository`
- [ ] Create `DiscoverMoviesUseCase`
- [ ] Add `cacheKey` extension to `MovieFilters`
- [ ] Register use case in `AppContainer`
- [ ] Test API with curl first

## TMDB API Verification

Before implementing, verify endpoint supports:
```bash
# Test discover endpoint with filters
curl "https://api.themoviedb.org/3/discover/movie?api_key=YOUR_KEY&page=1&with_genres=28,12&sort_by=popularity.desc&vote_average.gte=7"
```

| Param | TMDB Support | Notes |
|-------|--------------|-------|
| `with_genres` | ✅ | Comma-separated IDs |
| `sort_by` | ✅ | popularity.desc, vote_average.desc, etc. |
| `vote_average.gte` | ✅ | Minimum rating |
| `primary_release_date.gte` | ✅ | YYYY-MM-DD format |
| `primary_release_date.lte` | ✅ | YYYY-MM-DD format |

## Success Criteria

- [ ] `discoverMovies` API request compiles
- [ ] Repository fetches and caches correctly
- [ ] Use case follows existing patterns
- [ ] DI container provides use case
- [ ] API returns expected data (test with curl)

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| TMDB API doesn't support filter | **High** | Test with curl first |
| Cache key collision | Medium | Include all filter params in key |
| URL encoding issues | Low | Use Moya's URLEncoding |

## Next Steps
- Proceed to Phase 6: ViewModel Integration
