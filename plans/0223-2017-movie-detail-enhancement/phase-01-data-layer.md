# Phase 1: Data Layer

## Context Links

- API Research: `/plans/reports/researcher-0223-2017-tmdb-apis.md`
- Existing API: `MoviesData/Sources/MoviesData/Network/MoviesAPI.swift`
- Existing DTOs: `trending-movie-ios/Network/TMDBResponseModels.swift`
- Domain Model: `trending-movie-ios/Domain/Movie.swift`
- Repository: `MoviesData/Sources/MoviesData/Repositories/DefaultMoviesRepository.swift`

## Overview

- **Priority:** P1 (blocks all other phases)
- **Status:** completed
- **Effort:** 2h

Add new API endpoints for watch providers and reviews, create corresponding DTOs, extend domain models, and update repository.

## Key Insights

1. TMDB provides watch providers per country - use US as default
2. Reviews include author details with avatar path and rating
3. Existing `Movie.swift` already has `credits`, `images`, `videos` - follow same pattern
4. Repository uses callback-based networking with Moya

## Requirements

### Functional
- Fetch watch providers for a movie (US region primary)
- Fetch paginated reviews for a movie
- Map DTOs to domain models

### Non-Functional
- Follow existing coding patterns
- Use snake_case for CodingKeys
- Handle optional fields gracefully

## Architecture

```
MoviesAPI (enum)
    + watchProviders(movieId)
    + movieReviews(movieId, page)
         |
         v
TMDBResponseModels
    + TMDBWatchProvidersResponse
    + TMDBCountryWatchProviders
    + TMDBWatchProvider
    + TMDBReviewsResponse
    + TMDBReview
    + TMDBAuthorDetails
         |
         v
Movie.swift (Domain)
    + watchProviders: WatchProviders?
    + reviews: [Review]?
```

## Related Code Files

### Files to Modify
- `MoviesData/Sources/MoviesData/Network/MoviesAPI.swift` - Add cases
- `trending-movie-ios/Network/TMDBResponseModels.swift` - Add DTOs + conversions
- `trending-movie-ios/Domain/Movie.swift` - Add domain models
- `MoviesDomain/Sources/MoviesDomain/Repositories/MoviesRepository.swift` - Add protocol methods
- `MoviesData/Sources/MoviesData/Repositories/DefaultMoviesRepository.swift` - Implement methods

### Files to Create
- None (extend existing files)

## Implementation Steps

### Step 1: Add API Cases (15 min)

File: `MoviesData/Sources/MoviesData/Network/MoviesAPI.swift`

```swift
// Add to enum MoviesAPI
case watchProviders(movieId: String)
case movieReviews(movieId: String, page: Int)

// Add to path switch
case .watchProviders(let movieId):
    return "movie/\(movieId)/watch/providers"
case .movieReviews(let movieId, _):
    return "movie/\(movieId)/reviews"

// Add to task switch
case .watchProviders:
    return .requestPlain
case .movieReviews(_, let page):
    return .requestParameters(
        parameters: ["page": page],
        encoding: URLEncoding.queryString
    )
```

### Step 2: Add DTOs (30 min)

File: `trending-movie-ios/Network/TMDBResponseModels.swift`

Add after existing DTOs:

```swift
// MARK: - Watch Providers Response
public struct TMDBWatchProvidersResponse: Codable {
    public let id: Int
    public let results: [String: TMDBCountryWatchProviders]
}

public struct TMDBCountryWatchProviders: Codable {
    public let link: String?
    public let flatrate: [TMDBWatchProvider]?
    public let rent: [TMDBWatchProvider]?
    public let buy: [TMDBWatchProvider]?
    public let free: [TMDBWatchProvider]?
    public let ads: [TMDBWatchProvider]?
}

public struct TMDBWatchProvider: Codable, Hashable {
    public let providerId: Int
    public let providerName: String
    public let logoPath: String?
    public let displayPriority: Int

    enum CodingKeys: String, CodingKey {
        case providerId = "provider_id"
        case providerName = "provider_name"
        case logoPath = "logo_path"
        case displayPriority = "display_priority"
    }
}

// MARK: - Reviews Response
public struct TMDBReviewsResponse: Codable {
    public let id: Int
    public let page: Int
    public let results: [TMDBReview]
    public let totalPages: Int
    public let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case id, page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

public struct TMDBReview: Codable, Identifiable {
    public let id: String
    public let author: String
    public let authorDetails: TMDBAuthorDetails?
    public let content: String
    public let createdAt: String
    public let updatedAt: String?
    public let url: String

    enum CodingKeys: String, CodingKey {
        case id, author, content, url
        case authorDetails = "author_details"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct TMDBAuthorDetails: Codable {
    public let name: String?
    public let username: String
    public let avatarPath: String?
    public let rating: Double?

    enum CodingKeys: String, CodingKey {
        case name, username, rating
        case avatarPath = "avatar_path"
    }
}
```

### Step 3: Add Domain Models (20 min)

File: `trending-movie-ios/Domain/Movie.swift`

Add after `CrewMember`:

```swift
// MARK: - Watch Providers
public struct WatchProviders: Equatable {
    public let link: String?
    public let flatrate: [WatchProvider]
    public let rent: [WatchProvider]
    public let buy: [WatchProvider]

    public init(link: String?, flatrate: [WatchProvider], rent: [WatchProvider], buy: [WatchProvider]) {
        self.link = link
        self.flatrate = flatrate
        self.rent = rent
        self.buy = buy
    }
}

public struct WatchProvider: Equatable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let logoPath: String?

    public init(id: Int, name: String, logoPath: String?) {
        self.id = id
        self.name = name
        self.logoPath = logoPath
    }

    public var logoURL: URL? {
        guard let logoPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(logoPath)")
    }
}

// MARK: - Review
public struct Review: Equatable, Identifiable {
    public let id: String
    public let author: String
    public let authorAvatarPath: String?
    public let authorRating: Double?
    public let content: String
    public let createdAt: String
    public let url: String

    public init(id: String, author: String, authorAvatarPath: String?, authorRating: Double?, content: String, createdAt: String, url: String) {
        self.id = id
        self.author = author
        self.authorAvatarPath = authorAvatarPath
        self.authorRating = authorRating
        self.content = content
        self.createdAt = createdAt
        self.url = url
    }

    public var avatarURL: URL? {
        guard let avatarPath = authorAvatarPath else { return nil }
        // Handle both full URLs and relative paths
        if avatarPath.hasPrefix("http") {
            return URL(string: avatarPath)
        }
        return URL(string: "https://image.tmdb.org/t/p/w185\(avatarPath)")
    }
}
```

Update `Movie` struct to add new fields:

```swift
// Add to Movie properties
public let watchProviders: WatchProviders?
public let reviews: [Review]?

// Update init
public init(
    // ... existing params ...
    watchProviders: WatchProviders? = nil,
    reviews: [Review]? = nil
) {
    // ... existing assignments ...
    self.watchProviders = watchProviders
    self.reviews = reviews
}
```

### Step 4: Add DTO Conversions (20 min)

File: `trending-movie-ios/Network/TMDBResponseModels.swift`

Add conversion extensions:

```swift
// MARK: - Watch Providers Conversion
extension TMDBWatchProvider {
    func toDomain() -> WatchProvider {
        return WatchProvider(
            id: providerId,
            name: providerName,
            logoPath: logoPath
        )
    }
}

extension TMDBCountryWatchProviders {
    func toDomain() -> WatchProviders {
        return WatchProviders(
            link: link,
            flatrate: flatrate?.map { $0.toDomain() } ?? [],
            rent: rent?.map { $0.toDomain() } ?? [],
            buy: buy?.map { $0.toDomain() } ?? []
        )
    }
}

// MARK: - Review Conversion
extension TMDBReview {
    func toDomain() -> Review {
        return Review(
            id: id,
            author: author,
            authorAvatarPath: authorDetails?.avatarPath,
            authorRating: authorDetails?.rating,
            content: content,
            createdAt: createdAt,
            url: url
        )
    }
}
```

### Step 5: Update Repository Protocol (15 min)

File: `MoviesDomain/Sources/MoviesDomain/Repositories/MoviesRepository.swift`

Add new protocol methods:

```swift
public typealias WatchProvidersResult = (Result<WatchProviders?, Error>) -> Void
public typealias ReviewsResult = (Result<[Review], Error>) -> Void

// Add to protocol
@discardableResult
func fetchWatchProviders(movieId: Movie.Identifier,
                         completion: @escaping WatchProvidersResult) -> Cancellable?

@discardableResult
func fetchReviews(movieId: Movie.Identifier,
                  page: Int,
                  completion: @escaping ReviewsResult) -> Cancellable?
```

### Step 6: Implement Repository Methods (20 min)

File: `MoviesData/Sources/MoviesData/Repositories/DefaultMoviesRepository.swift`

```swift
public func fetchWatchProviders(movieId: Movie.Identifier,
                                completion: @escaping WatchProvidersResult) -> MoviesDomain.Cancellable? {
    let cancellable = networkService.request(
        .watchProviders(movieId: movieId),
        type: TMDBWatchProvidersResponse.self
    ) { result in
        switch result {
        case .success(let response):
            // Default to US region
            let usProviders = response.results["US"]?.toDomain()
            completion(.success(usProviders))
        case .failure(let error):
            completion(.failure(error))
        }
    }
    return cancellable
}

public func fetchReviews(movieId: Movie.Identifier,
                         page: Int,
                         completion: @escaping ReviewsResult) -> MoviesDomain.Cancellable? {
    let cancellable = networkService.request(
        .movieReviews(movieId: movieId, page: page),
        type: TMDBReviewsResponse.self
    ) { result in
        switch result {
        case .success(let response):
            let reviews = response.results.map { $0.toDomain() }
            completion(.success(reviews))
        case .failure(let error):
            completion(.failure(error))
        }
    }
    return cancellable
}
```

## Todo List

- [x] Add `watchProviders` and `movieReviews` cases to `MoviesAPI.swift`
- [x] Add watch provider DTOs to `TMDBResponseModels.swift`
- [x] Add review DTOs to `TMDBResponseModels.swift`
- [x] Add `WatchProviders`, `WatchProvider`, `Review` domain models to `Movie.swift`
- [x] Update `Movie` struct with new optional fields
- [x] Add DTO-to-domain conversion extensions
- [x] Add repository protocol methods
- [x] Implement repository methods in `DefaultMoviesRepository`
- [x] Build and verify no compile errors

## Success Criteria

- [x] Project compiles without errors
- [x] New API cases return correct paths
- [x] DTOs decode sample JSON correctly
- [x] Domain models are Equatable
- [x] Repository methods callable from presentation layer

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Missing US providers | Low | Return nil, UI handles gracefully |
| API changes | Low | DTOs use optional fields |
| Build errors | Medium | Follow existing patterns exactly |

## Security Considerations

- API key already embedded in `AppContainer.swift` - no changes needed
- No user input in API calls (movieId from trusted source)

## Next Steps

- Complete Phase 2: UI Components
- Test API responses with real movie IDs
