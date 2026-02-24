# Phase 4: Enhanced Empty States

**Status:** Pending
**Priority:** Medium
**Effort:** Medium
**Est. Time:** 1 hour
**Depends on:** Phase 3

---

## Overview

Improve empty states with trending movies carousel and alternative search suggestions.

## Requirements

### Functional
- Initial state shows trending movies below popular searches
- No results state shows alternative search suggestions
- Actionable guidance for users

### Non-Functional
- Horizontal carousel with smooth scrolling
- Lazy loading for performance
- Accessible labels

## Implementation Steps

### Step 1: Add Trending Movies to ViewModel

**File:** `SearchViewModel.swift`

```swift
@MainActor
class SearchViewModel: ObservableObject {
    // ... existing properties ...

    // Add trending movies
    @Published var trendingMovies: [MoviesListItemViewModel] = []

    private let trendingUseCase: TrendingMoviesUseCaseProtocol?

    // Update init (optional dependency for backward compatibility)
    nonisolated init(
        searchMoviesUseCase: SearchMoviesUseCaseProtocol,
        historyStore: SearchHistoryStore = SearchHistoryStore(),
        trendingUseCase: TrendingMoviesUseCaseProtocol? = nil
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.historyStore = historyStore
        self.trendingUseCase = trendingUseCase

        Task { @MainActor in
            self.searchHistory = historyStore.recentSearches
            setupSearchDebouncing()
            loadTrendingMovies()
        }
    }

    // Add method
    func loadTrendingMovies() {
        guard let trendingUseCase = trendingUseCase else { return }

        trendingUseCase.execute(
            requestValue: TrendingMoviesUseCaseRequestValue(page: 1),
            cached: { [weak self] moviesPage in
                Task { @MainActor in
                    self?.trendingMovies = moviesPage.movies.map {
                        MoviesListItemViewModel(movie: $0)
                    }
                }
            },
            completion: { _ in }
        )
    }

    // Add alternative suggestions method
    func getAlternativeSuggestions(for query: String) -> [String] {
        let lowercase = query.lowercased()

        // Find similar popular searches
        let similar = popularSearches.filter { search in
            search.lowercased().contains(lowercase) ||
            lowercase.contains(search.lowercased())
        }

        // Add some default suggestions if not enough
        let defaults = ["Marvel", "Comedy", "Action", "2024"]
        let combined = similar + defaults.filter { !similar.contains($0) }

        return Array(combined.prefix(5))
    }
}
```

### Step 2: Create Trending Movie Card Component

**File:** `SearchView.swift`

```swift
// Compact trending card for horizontal carousel
private struct TrendingMovieCard: View {
    let movie: MoviesListItemViewModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Poster
                AsyncImage(url: movie.posterURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                            .overlay(
                                CinemaxIconView(.film, size: .medium, color: DSColors.tertiaryTextSwiftUI)
                            )
                    default:
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                            .shimmer()
                    }
                }
                .frame(width: 100, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Title
                Text(movie.title)
                    .font(DSTypography.bodySmallSwiftUI(weight: .medium))
                    .foregroundColor(DSColors.primaryTextSwiftUI)
                    .lineLimit(2)
                    .frame(width: 100, alignment: .leading)

                // Rating
                HStack(spacing: 4) {
                    CinemaxIconView(.star, size: .extraSmall, color: DSColors.warningSwiftUI)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(DSTypography.captionSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(movie.title), rated \(movie.voteAverage)")
    }
}
```

### Step 3: Create Trending Carousel Section

**File:** `SearchView.swift`

```swift
private var trendingCarouselSection: some View {
    VStack(alignment: .leading, spacing: 12) {
        HStack {
            CinemaxIconView(.trending, size: .small, color: DSColors.accentSwiftUI)
            Text("Trending Now")
                .font(DSTypography.h5SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)

            Spacer()
        }

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(viewModel.trendingMovies.prefix(10)) { movie in
                    TrendingMovieCard(movie: movie) {
                        viewModel.searchQuery = movie.title
                        viewModel.performSearch()
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    .padding(20)
    .background(DSColors.surfaceSwiftUI.opacity(0.5))
    .clipShape(RoundedRectangle(cornerRadius: 16))
}
```

### Step 4: Update Empty Search View

**File:** `SearchView.swift`

```swift
private var emptySearchView: some View {
    ScrollView {
        VStack(spacing: 24) {
            // Hero section
            VStack(spacing: 16) {
                CinemaxIconView(.search, size: .extraLarge, color: DSColors.secondaryTextSwiftUI)

                Text("Discover Movies")
                    .font(DSTypography.h3SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                Text("Search for your favorite movies and discover new ones")
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            // Recent searches (if any)
            if !viewModel.searchHistory.isEmpty {
                recentSearchesSection
            }

            // Trending carousel (NEW)
            if !viewModel.trendingMovies.isEmpty {
                trendingCarouselSection
            }

            // Popular searches
            popularSearchesSection
        }
        .padding(.bottom, 40)
    }
}

private var recentSearchesSection: some View {
    // ... from Phase 2 ...
}

private var popularSearchesSection: some View {
    VStack(alignment: .leading, spacing: 12) {
        HStack {
            CinemaxIconView(.flame, size: .small, color: DSColors.accentSwiftUI)
            Text("Popular Searches")
                .font(DSTypography.h5SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)
        }

        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            ForEach(viewModel.popularSearches, id: \.self) { search in
                BouncyTag(title: search) {
                    viewModel.searchQuery = search
                    viewModel.performSearch()
                }
            }
        }
    }
    .padding(20)
}
```

### Step 5: Enhance No Results View

**File:** `SearchView.swift`

```swift
private var noResultsView: some View {
    ScrollView {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                CinemaxIconView(.noResults, size: .extraLarge, color: DSColors.secondaryTextSwiftUI)

                Text("No Results Found")
                    .font(DSTypography.h3SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                Text("We couldn't find movies matching \"\(viewModel.searchQuery)\"")
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            // Alternative suggestions (NEW)
            let suggestions = viewModel.getAlternativeSuggestions(for: viewModel.searchQuery)
            if !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Try searching for:")
                        .font(DSTypography.h5SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            BouncyTag(title: suggestion) {
                                viewModel.searchQuery = suggestion
                                viewModel.performSearch()
                            }
                        }
                    }
                }
                .padding(20)
                .background(DSColors.surfaceSwiftUI.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)
            }

            // Search tips
            VStack(alignment: .leading, spacing: 8) {
                Text("Search Tips")
                    .font(DSTypography.h5SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                VStack(alignment: .leading, spacing: 4) {
                    searchTip("Check your spelling")
                    searchTip("Try shorter keywords")
                    searchTip("Use the movie title or actor name")
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DSColors.surfaceSwiftUI.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 40)
    }
    .accessibilityElement(children: .combine)
}

private func searchTip(_ text: String) -> some View {
    HStack(spacing: 8) {
        CinemaxIconView(.tick, size: .extraSmall, color: DSColors.accentSwiftUI)
        Text(text)
            .font(DSTypography.bodySmallSwiftUI())
            .foregroundColor(DSColors.secondaryTextSwiftUI)
    }
}
```

## Todo Checklist

- [ ] Add `trendingMovies` property to SearchViewModel
- [ ] Add `loadTrendingMovies()` method
- [ ] Add `getAlternativeSuggestions()` method
- [ ] Create TrendingMovieCard component
- [ ] Create trendingCarouselSection
- [ ] Update emptySearchView with trending carousel
- [ ] Enhance noResultsView with suggestions and tips
- [ ] Create searchTip helper view

## Testing

### Manual Testing
1. Open SearchView - verify trending carousel loads
2. Tap trending movie - verify search executes
3. Search for nonsense - verify suggestions appear
4. Verify accessibility with VoiceOver

## Success Criteria

- [ ] Trending carousel shows 10 movies
- [ ] Carousel scrolls smoothly horizontally
- [ ] No results shows 5 suggestions
- [ ] Search tips displayed clearly
- [ ] All elements accessible

## Next Phase

→ [Phase 5: Visual Hierarchy](./phase-05-visual-hierarchy.md)
