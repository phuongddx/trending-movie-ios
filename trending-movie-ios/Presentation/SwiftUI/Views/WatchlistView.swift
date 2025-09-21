import SwiftUI

@available(iOS 15.0, *)
struct WatchlistView: View {
    private let container: AppContainer
    @StateObject private var storage = MovieStorage.shared
    @State private var selectedSegment = 0
    @State private var selectedMovie: HomeViewModel.MovieWrapper?

    private let segments = ["Watchlist", "Favorites"]

    init(container: AppContainer) {
        self.container = container
    }

    var body: some View {
        NavigationView {
            ZStack {
                DSColors.backgroundSwiftUI
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with segmented control
                    VStack(spacing: 16) {
                        Text("My Movies")
                            .font(DSTypography.h1SwiftUI(weight: .semibold))
                            .foregroundColor(DSColors.primaryTextSwiftUI)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 0) {
                            ForEach(0..<segments.count, id: \.self) { index in
                                DSTag(
                                    title: segments[index],
                                    isSelected: selectedSegment == index,
                                    action: { selectedSegment = index }
                                )
                                if index < segments.count - 1 {
                                    Spacer(minLength: 8)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(DSColors.backgroundSwiftUI)

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
                    .foregroundColor(DSColors.secondaryTextSwiftUI)

                Text("Your Watchlist is Empty")
                    .font(DSTypography.h3SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                Text("Movies you want to watch will appear here")
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(DSSpacing.Padding.container)
    }

    private var moviesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(movies, id: \.id) { movie in
                    WatchlistMovieRow(
                        movie: movie,
                        onTap: { onMovieTap(movie) },
                        onRemove: { onRemove(movie) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

@available(iOS 15.0, *)
struct FavoritesTab: View {
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void
    let onRemove: (Movie) -> Void

    var body: some View {
        if movies.isEmpty {
            emptyFavoritesView
        } else {
            moviesList
        }
    }

    private var emptyFavoritesView: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                CinemaxIconView(.heart, size: .extraLarge, color: DSColors.secondaryTextSwiftUI)

                Text("No Favorite Movies")
                    .font(DSTypography.h3SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                Text("Movies you love will appear here")
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(20)
    }

    private var moviesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(movies, id: \.id) { movie in
                    WatchlistMovieRow(
                        movie: movie,
                        onTap: { onMovieTap(movie) },
                        onRemove: { onRemove(movie) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

@available(iOS 15.0, *)
struct WatchlistMovieRow: View {
    let movie: Movie
    let onTap: () -> Void
    let onRemove: () -> Void

    @State private var posterImage: UIImage?
    @State private var showingRemoveAlert = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Poster thumbnail
                Group {
                    if let posterImage = posterImage {
                        Image(uiImage: posterImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                            .overlay(
                                CinemaxIconView(.film, size: .medium, color: DSColors.tertiaryTextSwiftUI)
                            )
                    }
                }
                .frame(width: 60, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Movie info
                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.title ?? "Unknown Title")
                        .font(DSTypography.h5SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                        .lineLimit(2)

                    if let releaseDate = movie.releaseDate {
                        Text(dateFormatter.string(from: releaseDate))
                            .font(DSTypography.bodyMediumSwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                    }

                    if let voteAverage = movie.voteAverage {
                        DSRating(
                            rating: parseRating(voteAverage),
                            maxRating: 5,
                            size: .small,
                            showValue: true
                        )
                    }

                    if let overview = movie.overview, !overview.isEmpty {
                        Text(overview)
                            .font(DSTypography.bodySmallSwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                            .lineLimit(2)
                    }
                }

                Spacer()

                // Remove button
                DSIconButton(
                    icon: .trashBin,
                    style: .destructive,
                    size: .medium,
                    action: { showingRemoveAlert = true }
                )
            }
            .padding(16)
            .background(DSColors.surfaceSwiftUI)
            .clipShape(RoundedRectangle(cornerRadius: 12))
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

    private func parseRating(_ voteAverage: String) -> Double {
        if let doubleValue = Double(voteAverage) {
            return min(doubleValue / 2.0, 5.0) // Convert from 10-point to 5-point scale
        }
        return 0.0
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}