import SwiftUI

@available(iOS 15.0, *)
struct WatchlistView: View {
    private let container: AppContainer
    @StateObject private var storage = MovieStorage.shared
    @State private var selectedSegment = 0
    @State private var selectedMovie: HomeViewModel.MovieWrapper?
    @Environment(\.dsTheme) private var theme

    private let segments = ["Watchlist", "Favorites"]

    init(container: AppContainer) {
        self.container = container
    }

    var body: some View {
        NavigationView {
            ZStack {
                DSColors.primaryBackgroundSwiftUI(for: theme)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with segmented control
                    VStack(spacing: DSSpacing.md) {
                        Text("My Movies")
                            .font(DSTypography.largeTitleSwiftUI(weight: .bold))
                            .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        DSSegmentedControl(
                            segments: segments,
                            selection: $selectedSegment
                        )
                    }
                    .padding(DSSpacing.Padding.container)
                    .background(DSColors.primaryBackgroundSwiftUI(for: theme))

                    // Content
                    TabView(selection: $selectedSegment) {
                        WatchlistTab(
                            movies: storage.watchlistMovies,
                            onMovieTap: { movie in
                                selectedMovie = HomeViewModel.MovieWrapper(movie: movie)
                            },
                            onRemove: { movie in
                                storage.removeFromWatchlist(movie)
                            }
                        )
                        .tag(0)

                        FavoritesTab(
                            movies: storage.favoriteMovies,
                            onMovieTap: { movie in
                                selectedMovie = HomeViewModel.MovieWrapper(movie: movie)
                            },
                            onRemove: { movie in
                                storage.removeFromFavorites(movie)
                            }
                        )
                        .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: selectedSegment)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedMovie) { movie in
            MovieDetailsView(
                viewModel: container.observableMovieDetailsViewModel(movie: movie.movie)
            )
        }
    }
}

@available(iOS 15.0, *)
struct WatchlistTab: View {
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void
    let onRemove: (Movie) -> Void

    @Environment(\.dsTheme) private var theme

    var body: some View {
        if movies.isEmpty {
            emptyWatchlistView
        } else {
            moviesList
        }
    }

    private var emptyWatchlistView: some View {
        VStack(spacing: DSSpacing.lg) {
            Spacer()

            VStack(spacing: DSSpacing.md) {
                Image(systemName: "bookmark")
                    .font(.system(size: 60))
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))

                Text("Your Watchlist is Empty")
                    .font(DSTypography.title2SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

                Text("Movies you want to watch will appear here")
                    .font(DSTypography.bodySwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(DSSpacing.Padding.container)
    }

    private var moviesList: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.md) {
                ForEach(movies, id: \.id) { movie in
                    WatchlistMovieRow(
                        movie: movie,
                        onTap: { onMovieTap(movie) },
                        onRemove: { onRemove(movie) }
                    )
                }
            }
            .padding(.horizontal, DSSpacing.Padding.container)
            .padding(.vertical, DSSpacing.md)
        }
    }
}

@available(iOS 15.0, *)
struct FavoritesTab: View {
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void
    let onRemove: (Movie) -> Void

    @Environment(\.dsTheme) private var theme

    var body: some View {
        if movies.isEmpty {
            emptyFavoritesView
        } else {
            moviesList
        }
    }

    private var emptyFavoritesView: some View {
        VStack(spacing: DSSpacing.lg) {
            Spacer()

            VStack(spacing: DSSpacing.md) {
                Image(systemName: "heart")
                    .font(.system(size: 60))
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))

                Text("No Favorite Movies")
                    .font(DSTypography.title2SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

                Text("Movies you love will appear here")
                    .font(DSTypography.bodySwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(DSSpacing.Padding.container)
    }

    private var moviesList: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.md) {
                ForEach(movies, id: \.id) { movie in
                    WatchlistMovieRow(
                        movie: movie,
                        onTap: { onMovieTap(movie) },
                        onRemove: { onRemove(movie) }
                    )
                }
            }
            .padding(.horizontal, DSSpacing.Padding.container)
            .padding(.vertical, DSSpacing.md)
        }
    }
}

@available(iOS 15.0, *)
struct WatchlistMovieRow: View {
    let movie: Movie
    let onTap: () -> Void
    let onRemove: () -> Void

    @Environment(\.dsTheme) private var theme
    @State private var posterImage: UIImage?
    @State private var showingRemoveAlert = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSSpacing.md) {
                // Poster thumbnail
                Group {
                    if let posterImage = posterImage {
                        Image(uiImage: posterImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(DSColors.shimmerBackground(for: theme).swiftUIColor)
                            .overlay(
                                DSLoadingSpinner()
                                    .scaleEffect(0.5)
                            )
                    }
                }
                .frame(width: 60, height: 90)
                .cornerRadius(DSSpacing.CornerRadius.small)
                .clipped()

                // Movie info
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(movie.title ?? "Unknown Title")
                        .font(DSTypography.headlineSwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                        .lineLimit(2)

                    if let releaseDate = movie.releaseDate {
                        Text(dateFormatter.string(from: releaseDate))
                            .font(DSTypography.subheadlineSwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                    }

                    if let voteAverage = movie.voteAverage {
                        HStack(spacing: DSSpacing.xxs) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)

                            Text(voteAverage)
                                .font(DSTypography.caption1SwiftUI(weight: .medium))
                                .foregroundColor(DSColors.accentSwiftUI(for: theme))
                        }
                    }

                    if let overview = movie.overview, !overview.isEmpty {
                        Text(overview)
                            .font(DSTypography.caption1SwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                            .lineLimit(2)
                    }
                }

                Spacer()

                // Remove button
                Button {
                    showingRemoveAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                        .frame(width: 44, height: 44)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(DSSpacing.CornerRadius.medium)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(DSSpacing.Padding.card)
            .background(DSColors.secondaryBackgroundSwiftUI(for: theme))
            .cornerRadius(DSSpacing.CornerRadius.card)
        }
        .alert("Remove Movie", isPresented: $showingRemoveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                onRemove()
            }
        } message: {
            Text("Are you sure you want to remove this movie from your list?")
        }
        .onAppear {
            loadPosterImage()
        }
    }

    private func loadPosterImage() {
        // This would load the poster image from the movie's posterPath
        // For now, we'll use a placeholder
        posterImage = UIImage(systemName: "photo")
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}