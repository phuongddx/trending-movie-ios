import SwiftUI

struct SearchView: View {
    private let container: AppContainer
    @StateObject private var viewModel: SearchViewModel

    // MARK: - Animation & Focus State
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @FocusState private var isSearchFocused: Bool

    init(container: AppContainer) {
        self.container = container
        self._viewModel = StateObject(wrappedValue: SearchViewModel(
            searchMoviesUseCase: container.searchMoviesUseCase(),
            trendingUseCase: container.trendingMoviesUseCase()
        ))
    }

    // MARK: - Animation Helpers
    private var defaultTransition: AnyTransition {
        reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity)
    }

    var body: some View {
        NavigationView {
            ZStack {
                DSColors.backgroundSwiftUI
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search header
                    searchHeader

                    // Content with state transitions
                    contentArea
                }

                // Hidden NavigationLink for programmatic navigation
                navigationLink
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Search Header
    private var searchHeader: some View {
        VStack(spacing: 16) {
            DSSearchField(
                text: $viewModel.searchQuery,
                placeholder: "Search movies...",
                onSearchTap: {
                    viewModel.performSearch()
                }
            )
            .focused($isSearchFocused)
            .scaleEffect(isSearchFocused ? 1.02 : 1.0)
            .shadow(
                color: isSearchFocused
                    ? DSColors.accentSwiftUI.opacity(0.3)
                    : Color.clear,
                radius: isSearchFocused ? 8 : 0
            )
            .animation(reduceMotion ? .linear(duration: 0) : .easeInOut(duration: 0.2), value: isSearchFocused)

            // Suggestions dropdown
            if !viewModel.suggestions.isEmpty && !viewModel.searchQuery.isEmpty {
                SearchSuggestionsList(
                    suggestions: viewModel.suggestions,
                    onSuggestionTap: { suggestion in
                        viewModel.searchQuery = suggestion
                        viewModel.performSearch()
                    }
                )
                .transition(defaultTransition)
            }
        }
        .padding(20)
        .background(DSColors.backgroundSwiftUI)
        .zIndex(1)
    }

    // MARK: - Content Area
    @ViewBuilder
    private var contentArea: some View {
        ZStack {
            if viewModel.searchQuery.isEmpty {
                emptySearchView
                    .transition(reduceMotion ? .opacity : .asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else if viewModel.isLoading && viewModel.searchResults.isEmpty {
                loadingView
                    .transition(.opacity)
            } else if viewModel.searchResults.isEmpty && !viewModel.isLoading {
                noResultsView
                    .transition(reduceMotion ? .opacity : .asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                searchResultsList
                    .transition(.opacity)
            }
        }
        .animation(reduceMotion ? .linear(duration: 0) : .easeInOut(duration: 0.25), value: viewModel.searchQuery.isEmpty)
        .animation(reduceMotion ? .linear(duration: 0) : .easeInOut(duration: 0.25), value: viewModel.isLoading)
    }

    // MARK: - Navigation Link
    @ViewBuilder
    private var navigationLink: some View {
        if let selectedMovie = viewModel.selectedMovie {
            NavigationLink(
                destination: MovieDetailsView(
                    viewModel: container.observableMovieDetailsViewModel(movie: selectedMovie.movie)
                ),
                isActive: Binding(
                    get: { viewModel.selectedMovie != nil },
                    set: { if !$0 { viewModel.selectedMovie = nil } }
                )
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

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

                // Recent Searches (if any)
                if !viewModel.searchHistory.isEmpty {
                    recentSearchesSection
                }

                // Trending carousel
                if !viewModel.trendingMovies.isEmpty {
                    trendingCarouselSection
                }

                // Popular Searches
                popularSearchesSection
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Trending Carousel Section
    private var trendingCarouselSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CinemaxIconView(.star, size: .small, color: DSColors.accentSwiftUI)
                Text("Trending Now")
                    .font(DSTypography.h5SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(viewModel.trendingMovies.prefix(10), id: \.id) { movie in
                        TrendingMovieCard(movie: movie, reduceMotion: reduceMotion) {
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
        .padding(.horizontal, 20)
    }

    // MARK: - Recent Searches Section
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CinemaxIconView(.clock, size: .small, color: DSColors.accentSwiftUI)
                Text("Recent Searches")
                    .font(DSTypography.h5SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                Spacer()

                Button("Clear") {
                    viewModel.clearSearchHistory()
                }
                .font(DSTypography.captionSwiftUI())
                .foregroundColor(DSColors.tertiaryTextSwiftUI)
            }

            ForEach(viewModel.searchHistory, id: \.self) { query in
                RecentSearchRow(
                    query: query,
                    onTap: {
                        viewModel.searchQuery = query
                        viewModel.performSearch()
                    },
                    onDelete: {
                        viewModel.removeFromHistory(query)
                    }
                )
            }
        }
        .padding(20)
        .background(DSColors.surfaceSwiftUI)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }

    // MARK: - Popular Searches Section
    private var popularSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CinemaxIconView(.star, size: .small, color: DSColors.accentSwiftUI)
                Text("Popular Searches")
                    .font(DSTypography.h5SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(viewModel.popularSearches, id: \.self) { search in
                    BouncyTag(title: search, reduceMotion: reduceMotion) {
                        viewModel.searchQuery = search
                        viewModel.performSearch()
                    }
                }
            }
        }
        .padding(20)
    }

    private var loadingView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<8, id: \.self) { _ in
                    HStack(spacing: 16) {
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                            .frame(width: 60, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 8) {
                            Rectangle()
                                .fill(DSColors.surfaceSwiftUI)
                                .frame(width: 200, height: 16)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            Rectangle()
                                .fill(DSColors.surfaceSwiftUI)
                                .frame(width: 150, height: 14)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            Rectangle()
                                .fill(DSColors.surfaceSwiftUI)
                                .frame(width: 100, height: 14)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 16)
        }
        .accessibilityLabel("Loading movies")
        .accessibilityHidden(true) // Skeleton not meaningful to screen reader
    }

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

                // Alternative suggestions
                let suggestions = viewModel.getAlternativeSuggestions(for: viewModel.searchQuery)
                if !suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            CinemaxIconView(.search, size: .small, color: DSColors.accentSwiftUI)
                            Text("Try searching for:")
                                .font(DSTypography.h5SwiftUI(weight: .semibold))
                                .foregroundColor(DSColors.primaryTextSwiftUI)
                        }

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                BouncyTag(title: suggestion, reduceMotion: reduceMotion) {
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
                    HStack {
                        CinemaxIconView(.question, size: .small, color: DSColors.accentSwiftUI)
                        Text("Search Tips")
                            .font(DSTypography.h5SwiftUI(weight: .semibold))
                            .foregroundColor(DSColors.primaryTextSwiftUI)
                    }

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

    // MARK: - Search Tip Helper
    private func searchTip(_ text: String) -> some View {
        HStack(spacing: 8) {
            CinemaxIconView(.tick, size: .small, color: DSColors.accentSwiftUI)
            Text(text)
                .font(DSTypography.bodySmallSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)
        }
    }

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Results count header
                if !viewModel.searchResults.isEmpty {
                    resultsCountHeader
                        .transition(.opacity)
                }

                // Staggered results animation
                ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, movie in
                    MovieCard(
                        movie: movie,
                        style: .compact,
                        onTap: {
                            viewModel.selectMovie(movie)
                        },
                        onWatchlistTap: {
                            viewModel.toggleWatchlist(movie)
                        },
                        onFavoriteTap: {
                            viewModel.toggleFavorite(movie)
                        }
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(movie.title), \(movie.releaseDate)")
                    .transition(defaultTransition)
                    .animation(
                        reduceMotion ? .linear(duration: 0) : .spring(response: 0.3).delay(Double(index) * 0.05),
                        value: viewModel.searchResults.count
                    )
                }

                if viewModel.isLoadingMore {
                    loadingMoreIndicator
                        .transition(.opacity)
                        .animation(.easeIn(duration: 0.2), value: viewModel.isLoadingMore)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .onAppear {
            if viewModel.searchResults.count >= 15 {
                viewModel.loadNextPage()
            }
        }
    }

    // MARK: - Loading More Indicator
    private var loadingMoreIndicator: some View {
        HStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DSColors.accentSwiftUI))
            Text("Loading more...")
                .font(DSTypography.bodySmallSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)
        }
        .padding(24)
        .accessibilityLabel("Loading more results")
    }

    // MARK: - Results Count Header
    private var resultsCountHeader: some View {
        HStack {
            Text("\(viewModel.searchResults.count) movies found")
                .font(DSTypography.bodySmallSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)

            Spacer()

            if viewModel.searchResults.count > 0 {
                Text("Page \(viewModel.currentPage)")
                    .font(DSTypography.captionSwiftUI())
                    .foregroundColor(DSColors.tertiaryTextSwiftUI)
            }
        }
        .padding(.horizontal, 0)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(viewModel.searchResults.count) movies found")
    }
}

// MARK: - Recent Search Row Component
private struct RecentSearchRow: View {
    let query: String
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Button(action: onTap) {
                HStack {
                    CinemaxIconView(.clock, size: .small, color: DSColors.tertiaryTextSwiftUI)
                    Text(query)
                        .font(DSTypography.bodyMediumSwiftUI())
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                    Spacer()
                }
            }
            .accessibilityLabel("Search for \(query)")
            .accessibilityHint("Tap to search again")

            Button(action: onDelete) {
                CinemaxIconView(.remove, size: .small, color: DSColors.tertiaryTextSwiftUI)
            }
            .accessibilityLabel("Remove \(query) from history")
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
    }
}

// MARK: - Bouncy Tag Component
private struct BouncyTag: View {
    let title: String
    let reduceMotion: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.bodySmallSwiftUI(weight: .medium))
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(DSColors.surfaceSwiftUI)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DSColors.accentSwiftUI.opacity(0.3), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(reduceMotion ? .linear(duration: 0) : .spring(response: 0.15), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel("Search for \(title)")
    }
}

// MARK: - Trending Movie Card Component
private struct TrendingMovieCard: View {
    let movie: MoviesListItemViewModel
    let reduceMotion: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    // Helper to create poster URL
    private var posterURL: URL? {
        guard let path = movie.posterImagePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w200\(path)")
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Poster
                AsyncImage(url: posterURL) { phase in
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
                    CinemaxIconView(.star, size: .small, color: DSColors.warningSwiftUI)
                    Text(movie.voteAverage)
                        .font(DSTypography.captionSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                }
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(reduceMotion ? .linear(duration: 0) : .spring(response: 0.15), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(movie.title), rated \(movie.voteAverage)")
    }
}
