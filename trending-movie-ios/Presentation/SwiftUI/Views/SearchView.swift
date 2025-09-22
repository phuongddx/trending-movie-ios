import SwiftUI

struct SearchView: View {
    private let container: AppContainer
    @StateObject private var viewModel: SearchViewModel

    init(container: AppContainer) {
        self.container = container
        self._viewModel = StateObject(wrappedValue: SearchViewModel(
            searchMoviesUseCase: container.searchMoviesUseCase()
        ))
    }

    var body: some View {
        NavigationView {
            ZStack {
                DSColors.backgroundSwiftUI
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search header
                    VStack(spacing: 16) {
                        DSSearchField(
                            text: $viewModel.searchQuery,
                            placeholder: "Search movies...",
                            onSearchTap: {
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
                    .padding(20)
                    .background(DSColors.backgroundSwiftUI)
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
        VStack(spacing: 24) {
            Spacer()

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

            Spacer()

            // Recent searches or popular searches could go here
            VStack(alignment: .leading, spacing: 12) {
                Text("Popular Searches")
                    .font(DSTypography.h5SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(viewModel.popularSearches, id: \.self) { search in
                        DSTag(
                            title: search,
                            action: {
                                viewModel.searchQuery = search
                                viewModel.performSearch()
                            }
                        )
                    }
                }
            }
            .padding(20)
        }
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
    }

    private var noResultsView: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                CinemaxIconView(.noResults, size: .extraLarge, color: DSColors.secondaryTextSwiftUI)

                Text("No Results Found")
                    .font(DSTypography.h3SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                Text("Try searching with different keywords or check your spelling")
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(20)
    }

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
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
                        CinemaxIconView(.clock, size: .medium, color: DSColors.secondaryTextSwiftUI)
                        Text("Loading more...")
                            .font(DSTypography.bodySmallSwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                    }
                    .padding(24)
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
}
