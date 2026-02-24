# Phase 4: Bug Fixes

## Context Links

- CastCrewSection: `trending-movie-ios/Presentation/SwiftUI/Components/MovieDetails/CastCrewSection.swift`
- MovieBackdropHero: `trending-movie-ios/Presentation/SwiftUI/Components/MovieDetails/MovieBackdropHero.swift`
- Domain Model: `trending-movie-ios/Domain/Movie.swift`

## Overview

- **Priority:** P2
- **Status:** completed
- **Effort:** 1h

Fix two existing bugs:
1. `CastCrewSection` uses hardcoded writers instead of real crew data
2. `MovieBackdropHero` uses `posterPath` for backdrop instead of `backdropPath`

## Key Insights

1. `Movie.credits.crew` already contains real crew data with job/department fields
2. Filter crew by `job == "Director"` for directors
3. Filter crew by `department == "Writing"` for writers
4. `TMDBMovieDetail.backdropPath` exists but not mapped to domain model

## Requirements

### Functional
- CastCrewSection displays real directors and writers from `movie.credits.crew`
- MovieBackdropHero displays backdrop image using `backdropPath`

### Non-Functional
- Handle missing crew data gracefully
- Handle missing backdrop path gracefully

## Architecture

```
Current (Bug):
CastCrewSection
    - director: movie.director ?? "Jon Watts" (fallback hardcoded)
    - writers: hardcoded ["Chris McKenna", "Erik Sommers"]

MovieBackdropHero
    - backdrop: movie.posterPath (wrong image)

Fixed:
CastCrewSection
    - directors: movie.credits?.crew.filter { $0.job == "Director" }
    - writers: movie.credits?.crew.filter { $0.department == "Writing" }

MovieBackdropHero
    - backdrop: movie.backdropPath (correct image)
```

## Related Code Files

### Files to Modify
- `trending-movie-ios/Presentation/SwiftUI/Components/MovieDetails/CastCrewSection.swift`
- `trending-movie-ios/Presentation/SwiftUI/Components/MovieDetails/MovieBackdropHero.swift`
- `trending-movie-ios/Domain/Movie.swift` (add backdropPath property)
- `trending-movie-ios/Network/TMDBResponseModels.swift` (map backdropPath)

## Implementation Steps

### Step 1: Add backdropPath to Movie Domain Model (15 min)

File: `trending-movie-ios/Domain/Movie.swift`

Add property:

```swift
public struct Movie: Equatable, Identifiable {
    // ... existing properties ...
    public let backdropPath: String?  // NEW

    public init(
        // ... existing params ...
        backdropPath: String? = nil   // NEW
    ) {
        // ... existing assignments ...
        self.backdropPath = backdropPath
    }
}
```

Add computed property for URL:

```swift
extension Movie {
    // ... existing computed properties ...

    public var backdropImageURL: URL? {
        if let backdropPath = backdropPath, !backdropPath.isEmpty {
            return URL(string: "https://image.tmdb.org/t/p/w780\(backdropPath)")
        }
        return nil
    }
}
```

### Step 2: Map backdropPath in TMDBMovieDetail Conversion (10 min)

File: `trending-movie-ios/Network/TMDBResponseModels.swift`

Update `TMDBMovieDetail.toDomain()`:

```swift
extension TMDBMovieDetail {
    func toDomain(certification: String? = nil, director: String? = nil, videos: [Video]? = nil, images: MovieImages? = nil, credits: MovieCredits? = nil) -> Movie {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let parsedDate = releaseDate.flatMap { dateFormatter.date(from: $0) }

        return Movie(
            id: String(id),
            title: title,
            posterPath: posterPath,
            overview: overview,
            releaseDate: parsedDate,
            voteAverage: String(format: "%.1f", voteAverage),
            genres: genres?.map { $0.name },
            runtime: runtime,
            productionCountries: productionCountries?.map { $0.name },
            spokenLanguages: spokenLanguages?.compactMap { $0.englishName ?? $0.name },
            budget: budget,
            revenue: revenue,
            status: status,
            tagline: tagline,
            homepage: homepage,
            certification: certification,
            director: director,
            voteCount: voteCount,
            videos: videos,
            images: images,
            credits: credits,
            backdropPath: backdropPath  // NEW
        )
    }
}
```

### Step 3: Fix MovieBackdropHero (15 min)

File: `trending-movie-ios/Presentation/SwiftUI/Components/MovieDetails/MovieBackdropHero.swift`

Replace `posterPath` with `backdropPath`:

```swift
struct MovieBackdropHero: View {
    let movie: Movie
    let height: CGFloat

    init(movie: Movie, height: CGFloat = 552) {
        self.movie = movie
        self.height = height
    }

    var body: some View {
        ZStack {
            // Backdrop Image - FIXED: Use backdropPath instead of posterPath
            Group {
                if let backdropPath = movie.backdropPath, !backdropPath.isEmpty {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w780\(backdropPath)")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                    }
                } else if let posterPath = movie.posterPath, !posterPath.isEmpty {
                    // Fallback to poster if no backdrop
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w780\(posterPath)")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                    }
                } else {
                    Rectangle()
                        .fill(DSColors.surfaceSwiftUI)
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: height)
            .clipped()

            // Gradient Overlay - unchanged
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "#1F1D2B").opacity(0.57), location: 0),
                    .init(color: Color(hex: "#1F1D2B"), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: UIScreen.main.bounds.width, height: height)

            // Movie Poster - unchanged
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    if let posterPath = movie.posterPath, !posterPath.isEmpty {
                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(DSColors.surfaceSwiftUI)
                        }
                    } else {
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                    }

                    Spacer()
                }
                .frame(width: 205, height: 287)
                .cornerRadius(12)
                .padding(.bottom, 60)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: height)
    }
}
```

### Step 4: Fix CastCrewSection (20 min)

File: `trending-movie-ios/Presentation/SwiftUI/Components/MovieDetails/CastCrewSection.swift`

Rewrite to use real crew data:

```swift
import SwiftUI

struct CastCrewSection: View {
    let movie: Movie

    // Filter directors from crew
    private var directors: [CrewMember] {
        guard let crew = movie.credits?.crew else { return [] }
        return crew.filter { $0.job.lowercased() == "director" }
    }

    // Filter writers from crew
    private var writers: [CrewMember] {
        guard let crew = movie.credits?.crew else { return [] }
        return crew.filter { $0.department.lowercased() == "writing" }
    }

    // Fallback director from movie.director if no credits
    private var fallbackDirector: String {
        movie.director ?? "Unknown"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cast and Crew")
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Directors
                    if !directors.isEmpty {
                        ForEach(directors.prefix(2)) { director in
                            CrewMemberCard(
                                name: director.name,
                                role: "Director",
                                avatarImage: director.profilePath
                            )
                        }
                    } else {
                        // Fallback if no credits loaded
                        CrewMemberCard(
                            name: fallbackDirector,
                            role: "Director",
                            avatarImage: nil
                        )
                    }

                    // Writers
                    if !writers.isEmpty {
                        ForEach(writers.prefix(3)) { writer in
                            CrewMemberCard(
                                name: writer.name,
                                role: writer.job,
                                avatarImage: writer.profilePath
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct CrewMemberCard: View {
    let name: String
    let role: String
    let avatarImage: String?

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let profilePath = avatarImage {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle().fill(Color(hex: "#E8E8E6"))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(hex: "#E8E8E6"))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                    )
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(role)
                    .font(DSTypography.h7SwiftUI(weight: .medium))
                    .foregroundColor(DSColors.secondaryTextSwiftUI)

                Text(name)
                    .font(DSTypography.h5SwiftUI(weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .frame(maxWidth: 110, alignment: .leading)
        }
        .frame(width: 162)
    }
}
```

## Todo List

- [x] Add `backdropPath` property to `Movie.swift`
- [x] Add `backdropImageURL` computed property to `Movie` extension
- [x] Update `TMDBMovieDetail.toDomain()` to map `backdropPath`
- [x] Fix `MovieBackdropHero` to use `backdropPath` with poster fallback
- [x] Rewrite `CastCrewSection` to use real crew data
- [x] Update `CrewMemberCard` to load profile images
- [x] Build and verify no compile errors
- [x] Test with movie that has backdrop and crew data

## Success Criteria

- [x] Backdrop displays correct wide image (not poster)
- [x] Fallback to poster when backdrop unavailable
- [x] Directors show from `credits.crew` filtered by job
- [x] Writers show from `credits.crew` filtered by department
- [x] Crew profile photos load from `profilePath`
- [x] No hardcoded crew names visible

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Missing credits data | Low | Fallback to movie.director |
| Missing backdrop | Low | Fallback to poster |
| Crew filtering returns empty | Low | Show "Unknown" placeholder |

## Security Considerations

- No new security concerns
- Images loaded from TMDB CDN

## Next Steps

- Run full test suite
- Manual testing with various movies
- Verify no regressions in existing functionality
