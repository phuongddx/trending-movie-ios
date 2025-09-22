import SwiftUI

struct MovieActions: View {
    let movie: Movie
    let onWatchlistTap: () -> Void
    let onFavoriteTap: () -> Void
    let onShareTap: () -> Void
    let onPlayTrailer: (() -> Void)?

    @StateObject private var storage = MovieStorage.shared

    init(
        movie: Movie,
        onWatchlistTap: @escaping () -> Void,
        onFavoriteTap: @escaping () -> Void,
        onShareTap: @escaping () -> Void,
        onPlayTrailer: (() -> Void)? = nil
    ) {
        self.movie = movie
        self.onWatchlistTap = onWatchlistTap
        self.onFavoriteTap = onFavoriteTap
        self.onShareTap = onShareTap
        self.onPlayTrailer = onPlayTrailer
    }

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            // Play Trailer button (if video available)
            if let onPlayTrailer = onPlayTrailer {
                DSActionButton(
                    title: "Play Trailer",
                    style: .primary,
                    icon: .pause
                ) {
                    onPlayTrailer()
                }
            }

            // Secondary actions
            HStack(spacing: DSSpacing.sm) {
                // Watchlist button
                DSIconButton(
                    icon: storage.isInWatchlist(movie) ? .download : .download,
                    style: .text,
                    action: onWatchlistTap
                )
                .accessibility(
                    label: storage.isInWatchlist(movie) ? "Remove from Watchlist" : "Add to Watchlist"
                )

                // Favorite button
                DSIconButton(
                    icon: storage.isFavorite(movie) ? .heart : .heart,
                    style: .text,
                    action: onFavoriteTap
                )
                .accessibility(
                    label: storage.isFavorite(movie) ? "Remove from Favorites" : "Add to Favorites"
                )

                // Share button
                DSIconButton(
                    icon: .share,
                    style: .text,
                    action: onShareTap
                )
                .accessibility(label: "Share Movie")
            }

            Spacer()
        }
    }
}

// MARK: - Compact Variant

struct MovieActionsCompact: View {
    let movie: Movie
    let onWatchlistTap: () -> Void
    let onFavoriteTap: () -> Void
    let onShareTap: () -> Void

    @StateObject private var storage = MovieStorage.shared

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            // Watchlist
            Button(action: onWatchlistTap) {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: storage.isInWatchlist(movie) ? "bookmark.fill" : "bookmark")
                        .font(.body)
                        .foregroundColor(storage.isInWatchlist(movie) ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI)

                    Text(storage.isInWatchlist(movie) ? "Added" : "Watchlist")
                        .font(DSTypography.bodySmallSwiftUI(weight: .medium))
                        .foregroundColor(storage.isInWatchlist(movie) ? DSColors.accentSwiftUI : DSColors.primaryTextSwiftUI)
                }
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: DSSpacing.CornerRadius.small)
                        .fill(storage.isInWatchlist(movie) ? DSColors.accentSwiftUI.opacity(0.1) : DSColors.surfaceSwiftUI)
                        .stroke(storage.isInWatchlist(movie) ? DSColors.accentSwiftUI : DSColors.borderSwiftUI, lineWidth: 1)
                )
            }

            // Favorite
            Button(action: onFavoriteTap) {
                Image(systemName: storage.isFavorite(movie) ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(storage.isFavorite(movie) ? .red : DSColors.secondaryTextSwiftUI)
            }

            // Share
            Button(action: onShareTap) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
            }

            Spacer()
        }
    }
}

// MARK: - Floating Action Buttons

struct MovieActionsFloating: View {
    let movie: Movie
    let onWatchlistTap: () -> Void
    let onFavoriteTap: () -> Void
    let onShareTap: () -> Void

    @StateObject private var storage = MovieStorage.shared

    var body: some View {
        VStack(spacing: DSSpacing.sm) {
            // Watchlist FAB
            Button(action: onWatchlistTap) {
                Image(systemName: storage.isInWatchlist(movie) ? "bookmark.fill" : "bookmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(storage.isInWatchlist(movie) ? DSColors.accentSwiftUI : Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            }

            // Favorite FAB
            Button(action: onFavoriteTap) {
                Image(systemName: storage.isFavorite(movie) ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundColor(storage.isFavorite(movie) ? .white : .white)
                    .frame(width: 44, height: 44)
                    .background(storage.isFavorite(movie) ? Color.red : Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            }

            // Share FAB
            Button(action: onShareTap) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
    }
}

// MARK: - Bottom Sheet Actions

struct MovieActionsBottomSheet: View {
    let movie: Movie
    let onWatchlistTap: () -> Void
    let onFavoriteTap: () -> Void
    let onShareTap: () -> Void
    let onRateTap: (() -> Void)?
    let onPlayTrailer: (() -> Void)?

    @StateObject private var storage = MovieStorage.shared

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            // Main action
            if let onPlayTrailer = onPlayTrailer {
                DSActionButton(
                    title: "Watch Trailer",
                    style: .primary,
                    icon: .pause
                ) {
                    onPlayTrailer()
                }
            }

            // Secondary actions grid
            HStack(spacing: DSSpacing.lg) {
                actionButton(
                    icon: storage.isInWatchlist(movie) ? "bookmark.fill" : "bookmark",
                    title: storage.isInWatchlist(movie) ? "In Watchlist" : "Add to Watchlist",
                    color: storage.isInWatchlist(movie) ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI,
                    action: onWatchlistTap
                )

                actionButton(
                    icon: storage.isFavorite(movie) ? "heart.fill" : "heart",
                    title: storage.isFavorite(movie) ? "Favorited" : "Add to Favorites",
                    color: storage.isFavorite(movie) ? .red : DSColors.secondaryTextSwiftUI,
                    action: onFavoriteTap
                )

                actionButton(
                    icon: "square.and.arrow.up",
                    title: "Share",
                    color: DSColors.secondaryTextSwiftUI,
                    action: onShareTap
                )

                if let onRateTap = onRateTap {
                    actionButton(
                        icon: "star",
                        title: "Rate",
                        color: .yellow,
                        action: onRateTap
                    )
                }
            }
        }
        .padding(DSSpacing.lg)
    }

    private func actionButton(
        icon: String,
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: DSSpacing.xs) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(DSTypography.captionSwiftUI())
                    .foregroundColor(DSColors.primaryTextSwiftUI)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.sm)
        }
    }
}

// MARK: - Previews

struct MovieActions_Previews: PreviewProvider {
    static var previews: some View {
        let mockMovie = Movie(
            id: "1",
            title: "Sample Movie",
            posterPath: nil,
            overview: nil,
            releaseDate: nil,
            voteAverage: "8.5"
        )

        VStack(spacing: DSSpacing.xl) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Standard Actions")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))

                MovieActions(
                    movie: mockMovie,
                    onWatchlistTap: {},
                    onFavoriteTap: {},
                    onShareTap: {},
                    onPlayTrailer: {}
                )
            }

            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Compact Actions")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))

                MovieActionsCompact(
                    movie: mockMovie,
                    onWatchlistTap: {},
                    onFavoriteTap: {},
                    onShareTap: {}
                )
            }

            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Bottom Sheet Actions")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))

                MovieActionsBottomSheet(
                    movie: mockMovie,
                    onWatchlistTap: {},
                    onFavoriteTap: {},
                    onShareTap: {},
                    onRateTap: {},
                    onPlayTrailer: {}
                )
            }
        }
        .padding()
        .background(DSColors.backgroundSwiftUI)
    }
}