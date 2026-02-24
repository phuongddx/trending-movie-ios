# Phase 3: Filter System Models

## Overview
- **Priority:** P1 (Critical path for filters)
- **Status:** Pending
- **Effort:** 3h

Create domain and presentation models for movie filtering.

## Context Links
- Domain Layer: `MoviesDomain/Sources/MoviesDomain/Entities/`
- Presentation Layer: `trending-movie-ios/Presentation/SwiftUI/Models/`

## Requirements

### Functional
- Support genre multi-select
- Support year range filter
- Support minimum rating filter
- Support sort options

### Non-Functional
- Codable for persistence
- Hashable for SwiftUI state
- Default values for new users

## Architecture

```
MoviesDomain/Entities/
└── MovieFilters.swift           # Domain filter model

Presentation/SwiftUI/Models/
└── MovieFilterOption.swift      # Presentation helpers
```

## Related Code Files

| File | Action | Notes |
|------|--------|-------|
| `MoviesDomain/Sources/MoviesDomain/Entities/MovieFilters.swift` | Create | Domain model |
| `trending-movie-ios/Presentation/SwiftUI/Models/MovieFilterOption.swift` | Create | UI helpers |

## Implementation Steps

### Step 1: Create Domain MovieFilters Model
```swift
// MoviesDomain/Sources/MoviesDomain/Entities/MovieFilters.swift
import Foundation

public struct MovieFilters: Equatable, Codable, Hashable {
    public var genres: Set<Int>
    public var yearRange: ClosedRange<Int>
    public var minimumRating: Double
    public var sortBy: SortOption

    public init(
        genres: Set<Int> = [],
        yearRange: ClosedRange<Int> = 1990...Calendar.current.component(.year, from: Date()),
        minimumRating: Double = 0,
        sortBy: SortOption = .popularity
    ) {
        self.genres = genres
        self.yearRange = yearRange
        self.minimumRating = minimumRating
        self.sortBy = sortBy
    }

    public var isActive: Bool {
        !genres.isEmpty ||
        minimumRating > 0 ||
        sortBy != .popularity ||
        yearRange != 1990...Calendar.current.component(.year, from: Date())
    }

    public static let `default` = MovieFilters()
}

public enum SortOption: String, CaseIterable, Codable, Identifiable {
    case popularity = "popularity.desc"
    case rating = "vote_average.desc"
    case newest = "release_date.desc"
    case title = "original_title.asc"
    case oldest = "release_date.asc"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .popularity: return "Most Popular"
        case .rating: return "Highest Rated"
        case .newest: return "Newest First"
        case .title: return "Title A-Z"
        case .oldest: return "Oldest First"
        }
    }
}
```

### Step 2: Create Genre Helper
```swift
// MoviesDomain/Sources/MoviesDomain/Entities/Genre.swift
import Foundation

public struct Genre: Identifiable, Codable, Hashable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

// Common TMDB genres
public extension Genre {
    static let action = Genre(id: 28, name: "Action")
    static let adventure = Genre(id: 12, name: "Adventure")
    static let animation = Genre(id: 16, name: "Animation")
    static let comedy = Genre(id: 35, name: "Comedy")
    static let crime = Genre(id: 80, name: "Crime")
    static let documentary = Genre(id: 99, name: "Documentary")
    static let drama = Genre(id: 18, name: "Drama")
    static let family = Genre(id: 10751, name: "Family")
    static let fantasy = Genre(id: 14, name: "Fantasy")
    static let history = Genre(id: 36, name: "History")
    static let horror = Genre(id: 27, name: "Horror")
    static let music = Genre(id: 10402, name: "Music")
    static let mystery = Genre(id: 9648, name: "Mystery")
    static let romance = Genre(id: 10749, name: "Romance")
    static let sciFi = Genre(id: 878, name: "Science Fiction")
    static let thriller = Genre(id: 53, name: "Thriller")
    static let war = Genre(id: 10752, name: "War")
    static let western = Genre(id: 37, name: "Western")

    static let all: [Genre] = [
        .action, .adventure, .animation, .comedy, .crime,
        .documentary, .drama, .family, .fantasy, .history,
        .horror, .music, .mystery, .romance, .sciFi,
        .thriller, .war, .western
    ]
}
```

### Step 3: Create Presentation Helper
```swift
// Presentation/SwiftUI/Models/MovieFilterOption.swift
import SwiftUI
import MoviesDomain

extension MovieFilters {
    var activeChips: [FilterChip] {
        var chips: [FilterChip] = []

        // Sort chip (if not default)
        if sortBy != .popularity {
            chips.append(FilterChip(
                id: "sort",
                label: "Sort: \(sortBy.displayName)",
                category: .sort
            ))
        }

        // Genre chips
        for genreId in genres {
            if let genre = Genre.all.first(where: { $0.id == genreId }) {
                chips.append(FilterChip(
                    id: "genre_\(genreId)",
                    label: genre.name,
                    category: .genre
                ))
            }
        }

        // Rating chip
        if minimumRating > 0 {
            chips.append(FilterChip(
                id: "rating",
                label: "Rating: \(String(format: "%.1f", minimumRating))+",
                category: .rating
            ))
        }

        // Year chip
        let currentYear = Calendar.current.component(.year, from: Date())
        if yearRange != 1990...currentYear {
            if yearRange.lowerBound == yearRange.upperBound {
                chips.append(FilterChip(
                    id: "year",
                    label: "Year: \(yearRange.lowerBound)",
                    category: .year
                ))
            } else {
                chips.append(FilterChip(
                    id: "year",
                    label: "\(yearRange.lowerBound)-\(yearRange.upperBound)",
                    category: .year
                ))
            }
        }

        return chips
    }
}

struct FilterChip: Identifiable, Hashable {
    let id: String
    let label: String
    let category: FilterCategory
}

enum FilterCategory {
    case sort, genre, rating, year
}
```

## Todo List

- [ ] Create `MoviesDomain/Entities/MovieFilters.swift`
- [ ] Create `MoviesDomain/Entities/Genre.swift`
- [ ] Create `Presentation/SwiftUI/Models/MovieFilterOption.swift`
- [ ] Add `activeChips` computed property
- [ ] Add unit tests for `isActive` logic
- [ ] Test Codable encoding/decoding

## Success Criteria

- [ ] `MovieFilters` supports all filter types
- [ ] `isActive` correctly detects non-default state
- [ ] `activeChips` generates accurate chip labels
- [ ] Models are Codable for persistence

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Year range edge cases | Low | Clamp to valid TMDB range |
| Genre IDs mismatch | Medium | Use official TMDB genre IDs |

## Next Steps
- Proceed to Phase 4: Filter Bottom Sheet UI
