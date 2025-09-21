import SwiftUI

@available(iOS 15.0, *)
struct SearchView: View {
    private let container: AppContainer
    @StateObject private var viewModel: SearchViewModel
    @Environment(\.dsTheme) private var theme

    init(container: AppContainer) {
        self.container = container
        self._viewModel = StateObject(wrappedValue: SearchViewModel(
            searchMoviesUseCase: container.searchMoviesUseCase(),
            posterImagesRepository: container.posterImagesRepository()
        ))
    }

    var body: some View {
        NavigationView {
            ZStack {
                DSColors.primaryBackgroundSwiftUI(for: theme)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search header
                    VStack(spacing: DSSpacing.md) {
                        DSSearchBar(
                            text: $viewModel.searchQuery,
                            placeholder: "Search movies...",
                            onCommit: {
                                viewModel.performSearch()
                            }
                        )

                        // Suggestions dropdown
                        if !viewModel.suggestions.isEmpty && !viewModel.searchQuery.isEmpty {
                            SearchSuggestionsList(
                                suggestions: viewModel.suggestions,
                                onSuggestionTap: { suggestion in
                                    viewModel.searchQuery = suggestion
                                    viewModel.performSearch()
                                }
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .padding(DSSpacing.Padding.container)
                    .background(DSColors.primaryBackgroundSwiftUI(for: theme))
                    .zIndex(1)

                    // Content
                    ZStack {
                        if viewModel.searchQuery.isEmpty {
                            emptySearchView
                        } else if viewModel.isLoading && viewModel.searchResults.isEmpty {
                            loadingView
                        } else if viewModel.searchResults.isEmpty && !viewModel.isLoading {
                            noResultsView
                        } else {
                            searchResultsList
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $viewModel.selectedMovie) { movie in
            MovieDetailsView(
                viewModel: container.observableMovieDetailsViewModel(movie: movie.movie)
            )
        }
    }

    private var emptySearchView: some View {
        VStack(spacing: DSSpacing.lg) {
            Spacer()

            VStack(spacing: DSSpacing.md) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))

                Text("Discover Movies")
                    .font(DSTypography.title2SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

                Text("Search for your favorite movies and discover new ones")
                    .font(DSTypography.bodySwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Recent searches or popular searches could go here
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Popular Searches")
                    .font(DSTypography.title3SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DSSpacing.sm) {
                    ForEach(viewModel.popularSearches, id: \.self) { search in
                        Button {
                            viewModel.searchQuery = search
                            viewModel.performSearch()
                        } label: {
                            Text(search)
                                .font(DSTypography.subheadlineSwiftUI())
                                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                                .padding(.horizontal, DSSpacing.md)
                                .padding(.vertical, DSSpacing.sm)
                                .frame(maxWidth: .infinity)
                                .background(DSColors.secondaryBackgroundSwiftUI(for: theme))
                                .cornerRadius(DSSpacing.CornerRadius.medium)
                        }
                    }
                }
            }
            .padding(DSSpacing.Padding.container)
        }
    }

    private var loadingView: some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                ForEach(0..<8, id: \.self) { _ in
                    HStack(spacing: DSSpacing.md) {
                        DSSkeletonView(width: 60, height: 90, cornerRadius: DSSpacing.CornerRadius.small)

                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            DSSkeletonView(width: 200, height: 16)
                            DSSkeletonView(width: 150, height: 14)
                            DSSkeletonView(width: 100, height: 14)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, DSSpacing.Padding.container)
                }
            }
            .padding(.vertical, DSSpacing.md)
        }
    }

    private var noResultsView: some View {
        VStack(spacing: DSSpacing.lg) {
            Spacer()

            VStack(spacing: DSSpacing.md) {
                Image(systemName: "film.stack")
                    .font(.system(size: 60))
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))

                Text("No Results Found")
                    .font(DSTypography.title2SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

                Text("Try searching with different keywords or check your spelling")
                    .font(DSTypography.bodySwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(DSSpacing.Padding.container)
    }

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.md) {
                ForEach(viewModel.searchResults, id: \.title) { movie in
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
                }

                if viewModel.isLoadingMore {
                    HStack {
                        DSLoadingSpinner()
                        Text("Loading more...")
                            .font(DSTypography.caption1SwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                    }
                    .padding(DSSpacing.lg)
                }
            }
            .padding(.horizontal, DSSpacing.Padding.container)
            .padding(.vertical, DSSpacing.md)
        }
        .onAppear {
            if viewModel.searchResults.count >= 15 {
                viewModel.loadNextPage()
            }
        }
    }
}