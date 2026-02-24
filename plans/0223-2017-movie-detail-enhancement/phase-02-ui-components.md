# Phase 2: UI Components

## Context Links

- Design System: `Presentation/DesignSystem/`
- Existing Sections: `Presentation/SwiftUI/Components/MovieDetails/`
- StoryLineSection pattern: Reference for consistent styling

## Overview

- **Priority:** P2
- **Status:** completed
- **Effort:** 3h

Create 5 new SwiftUI sections following existing design patterns. Use `ui-ux-pro-max` skill for IMDb-style polish.

## Key Insights

1. All sections use `DSTypography`, `DSColors`, `DSSpacing` from design system
2. Horizontal carousels use `ScrollView(.horizontal)` with `HStack`
3. Section titles use `h4SwiftUI(weight: .semibold)` + white color
4. Content uses `h5SwiftUI` or `h6SwiftUI` + `secondaryTextSwiftUI`
5. Padding: horizontal 24pt, section spacing 24pt

## Requirements

### Functional
- CastCarouselSection: Display top 10 cast with photos, names, characters
- SimilarMoviesSection: Display 10 similar movies with navigation to detail
- FullMetadataSection: Display budget, revenue, studios, collection, languages
- WhereToWatchSection: Display streaming logos grouped by type (flatrate, rent, buy)
- ReviewsSection: Display top 3 reviews with avatar, author, rating, excerpt

### Non-Functional
- Lazy loading for images
- Graceful handling of missing data
- Consistent with Cinemax dark theme
- Accessibility identifiers

## Architecture

```
MovieDetailsView
    |
    +-- WhereToWatchSection (NEW)
    |       +-- ProviderLogoView (logo + name badge)
    |
    +-- CastCarouselSection (NEW)
    |       +-- CastMemberCard (photo + name + character)
    |
    +-- FullMetadataSection (NEW)
    |       +-- MetadataRow (label + value)
    |
    +-- ReviewsSection (NEW)
    |       +-- ReviewCard (avatar + author + rating + excerpt)
    |
    +-- SimilarMoviesSection (NEW)
            +-- SimilarMovieCard (poster + title)
```

## Related Code Files

### Files to Create
- `trending-movie-ios/Presentation/SwiftUI/Components/MovieDetails/WhereToWatchSection.swift`
- `trending-movie-ios/Presentation/SwiftUI/Components/MovieDetails/CastCarouselSection.swift`
- `trending-movie-ios/Presentation/SwiftUI/Components/MovieDetails/FullMetadataSection.swift`
- `trending-movie-ios/Presentation/SwiftUI/Components/MovieDetails/ReviewsSection.swift`
- `trending-movie-ios/Presentation/SwiftUI/Components/MovieDetails/SimilarMoviesSection.swift`

### Files to Reference
- `Presentation/SwiftUI/Components/MovieDetails/StoryLineSection.swift` - Styling pattern
- `Presentation/SwiftUI/Components/MovieDetails/CastCrewSection.swift` - CrewMemberCard pattern
- `Presentation/DesignSystem/DSColors.swift` - Color palette
- `Presentation/DesignSystem/DSTypography.swift` - Font styles

## Implementation Steps

### Step 1: WhereToWatchSection (30 min)

File: `Presentation/SwiftUI/Components/MovieDetails/WhereToWatchSection.swift`

```swift
import SwiftUI

struct WhereToWatchSection: View {
    let watchProviders: WatchProviders?

    private var hasProviders: Bool {
        guard let providers = watchProviders else { return false }
        return !providers.flatrate.isEmpty || !providers.rent.isEmpty || !providers.buy.isEmpty
    }

    var body: some View {
        if hasProviders {
            VStack(alignment: .leading, spacing: 16) {
                Text("Where to Watch")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 12) {
                    if let flatrate = watchProviders?.flatrate, !flatrate.isEmpty {
                        providerRow(title: "Stream", providers: flatrate)
                    }
                    if let rent = watchProviders?.rent, !rent.isEmpty {
                        providerRow(title: "Rent", providers: rent)
                    }
                    if let buy = watchProviders?.buy, !buy.isEmpty {
                        providerRow(title: "Buy", providers: buy)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
        }
    }

    private func providerRow(title: String, providers: [WatchProvider]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(DSTypography.h6SwiftUI(weight: .medium))
                .foregroundColor(DSColors.secondaryTextSwiftUI)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(providers.prefix(8)) { provider in
                        ProviderLogoView(provider: provider)
                    }
                }
            }
        }
    }
}

struct ProviderLogoView: View {
    let provider: WatchProvider

    var body: some View {
        VStack(spacing: 4) {
            if let logoURL = provider.logoURL {
                AsyncImage(url: logoURL) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(DSColors.surfaceSwiftUI)
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(DSColors.surfaceSwiftUI)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        Text(String(provider.name.prefix(2)))
                            .font(DSTypography.h6SwiftUI(weight: .semibold))
                            .foregroundColor(.white)
                    )
            }

            Text(provider.name)
                .font(DSTypography.captionSwiftUI(weight: .regular))
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .lineLimit(1)
                .frame(width: 60)
        }
    }
}
```

### Step 2: CastCarouselSection (30 min)

File: `Presentation/SwiftUI/Components/MovieDetails/CastCarouselSection.swift`

```swift
import SwiftUI

struct CastCarouselSection: View {
    let cast: [CastMember]

    private var displayCast: [CastMember] {
        Array(cast.sorted { ($0.order ?? 0) < ($1.order ?? 0) }.prefix(15))
    }

    var body: some View {
        if !cast.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Top Cast")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                    .foregroundColor(.white)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(displayCast) { member in
                            CastMemberCard(member: member)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal, -24)
            }
        }
    }
}

struct CastMemberCard: View {
    let member: CastMember

    var body: some View {
        VStack(spacing: 8) {
            // Profile Image
            if let profilePath = member.profilePath {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(DSColors.surfaceSwiftUI)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(DSColors.surfaceSwiftUI)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                    )
            }

            // Name
            Text(member.name)
                .font(DSTypography.h6SwiftUI(weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)

            // Character
            if let character = member.character {
                Text(character)
                    .font(DSTypography.captionSwiftUI(weight: .regular))
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
            }
        }
    }
}
```

### Step 3: FullMetadataSection (30 min)

File: `Presentation/SwiftUI/Components/MovieDetails/FullMetadataSection.swift`

```swift
import SwiftUI

struct FullMetadataSection: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Full Details")
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 12) {
                if let budget = movie.budget, budget > 0 {
                    MetadataRow(label: "Budget", value: formatCurrency(budget))
                }

                if let revenue = movie.revenue, revenue > 0 {
                    MetadataRow(label: "Revenue", value: formatCurrency(revenue))
                }

                if let countries = movie.productionCountries, !countries.isEmpty {
                    MetadataRow(label: "Production", value: countries.joined(separator: ", "))
                }

                if let languages = movie.spokenLanguages, !languages.isEmpty {
                    MetadataRow(label: "Languages", value: languages.prefix(5).joined(separator: ", "))
                }

                if let status = movie.status {
                    MetadataRow(label: "Status", value: status)
                }

                if let homepage = movie.homepage, !homepage.isEmpty {
                    Link(destination: URL(string: homepage)!) {
                        HStack {
                            Text("Official Website")
                                .font(DSTypography.h5SwiftUI(weight: .medium))
                                .foregroundColor(Color(hex: "#12CDD9"))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(Color(hex: "#12CDD9"))
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }

    private func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(DSTypography.h5SwiftUI(weight: .medium))
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(DSTypography.h5SwiftUI(weight: .regular))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
```

### Step 4: ReviewsSection (40 min)

File: `Presentation/SwiftUI/Components/MovieDetails/ReviewsSection.swift`

```swift
import SwiftUI

struct ReviewsSection: View {
    let reviews: [Review]

    private var displayReviews: [Review] {
        Array(reviews.prefix(3))
    }

    var body: some View {
        if !reviews.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Reviews")
                        .font(DSTypography.h4SwiftUI(weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    if reviews.count > 3 {
                        Button("See All") {
                            // Navigate to full reviews
                        }
                        .font(DSTypography.h5SwiftUI(weight: .medium))
                        .foregroundColor(Color(hex: "#12CDD9"))
                    }
                }

                ForEach(displayReviews) { review in
                    ReviewCard(review: review)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
        }
    }
}

struct ReviewCard: View {
    let review: Review
    @State private var isExpanded = false

    private var displayContent: String {
        if isExpanded || review.content.count <= 200 {
            return review.content
        }
        let endIndex = review.content.index(review.content.startIndex, offsetBy: 200)
        return String(review.content[..<endIndex]) + "..."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Header
            HStack(spacing: 12) {
                // Avatar
                if let avatarURL = review.avatarURL {
                    AsyncImage(url: avatarURL) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle().fill(DSColors.surfaceSwiftUI)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(DSColors.surfaceSwiftUI)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(review.author.prefix(1)).uppercased())
                                .font(DSTypography.h5SwiftUI(weight: .semibold))
                                .foregroundColor(.white)
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.author)
                        .font(DSTypography.h5SwiftUI(weight: .semibold))
                        .foregroundColor(.white)

                    if let rating = review.authorRating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(DSTypography.captionSwiftUI(weight: .medium))
                                .foregroundColor(DSColors.secondaryTextSwiftUI)
                            Text("/ 10")
                                .font(DSTypography.captionSwiftUI(weight: .regular))
                                .foregroundColor(DSColors.secondaryTextSwiftUI)
                        }
                    }
                }

                Spacer()
            }

            // Content
            Text(displayContent)
                .font(DSTypography.h5SwiftUI(weight: .regular))
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .lineLimit(isExpanded ? nil : 4)

            if review.content.count > 200 {
                Button(isExpanded ? "Less" : "Read more") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
                .font(DSTypography.h5SwiftUI(weight: .medium))
                .foregroundColor(Color(hex: "#12CDD9"))
            }
        }
        .padding(16)
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(12)
    }
}
```

### Step 5: SimilarMoviesSection (30 min)

File: `Presentation/SwiftUI/Components/MovieDetails/SimilarMoviesSection.swift`

```swift
import SwiftUI

struct SimilarMoviesSection: View {
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void

    private var displayMovies: [Movie] {
        Array(movies.prefix(10))
    }

    var body: some View {
        if !movies.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("More Like This")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                    .foregroundColor(.white)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(displayMovies) { movie in
                            SimilarMovieCard(movie: movie) {
                                onMovieTap(movie)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal, -24)
            }
        }
    }
}

struct SimilarMovieCard: View {
    let movie: Movie
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Poster
                if let posterPath = movie.posterPath {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)")) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle().fill(DSColors.surfaceSwiftUI)
                    }
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Rectangle()
                        .fill(DSColors.surfaceSwiftUI)
                        .frame(width: 120, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            Image(systemName: "film")
                                .font(.system(size: 32))
                                .foregroundColor(.gray)
                        )
                }

                // Title
                Text(movie.title ?? "Unknown")
                    .font(DSTypography.h6SwiftUI(weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .frame(width: 120, alignment: .leading)

                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text(movie.voteAverage ?? "N/A")
                        .font(DSTypography.captionSwiftUI(weight: .medium))
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                }
            }
        }
    }
}
```

## Todo List

- [x] Create `WhereToWatchSection.swift` with provider logos
- [x] Create `CastCarouselSection.swift` with cast photos carousel
- [x] Create `FullMetadataSection.swift` with metadata rows
- [x] Create `ReviewsSection.swift` with review cards
- [x] Create `SimilarMoviesSection.swift` with movie posters
- [x] Add preview providers for each component
- [x] Build and verify no compile errors

## Success Criteria

- [x] All 5 components compile without errors
- [x] Components follow design system patterns
- [x] Missing data handled gracefully (no crashes)
- [x] Horizontal scrolling smooth on all components
- [x] Images load with AsyncImage

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Missing poster/profile paths | Low | Show placeholder |
| Long review content | Low | Truncate with "Read more" |
| No similar movies | Low | Hide section entirely |

## Security Considerations

- AsyncImage loads from TMDB CDN only
- Links use HTTPS URLs
- No user-generated content

## Next Steps

- Complete Phase 3: Integration
- Wire up data flow in ViewModel
- Add navigation for similar movies
