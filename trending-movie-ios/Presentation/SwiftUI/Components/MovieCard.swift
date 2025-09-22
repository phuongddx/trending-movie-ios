import SwiftUI

struct MovieCard: View {
    enum Style {
        case hero
        case standard
        case compact
    }

    let movie: MoviesListItemViewModel
    let style: Style
    let onTap: () -> Void
    let onWatchlistTap: (() -> Void)?
    let onFavoriteTap: (() -> Void)?

    @StateObject private var storage = MovieStorage.shared

    init(movie: MoviesListItemViewModel,
         style: Style = .standard,
         onTap: @escaping () -> Void,
         onWatchlistTap: (() -> Void)? = nil,
         onFavoriteTap: (() -> Void)? = nil) {
        self.movie = movie
        self.style = style
        self.onTap = onTap
        self.onWatchlistTap = onWatchlistTap
        self.onFavoriteTap = onFavoriteTap
    }

    var body: some View {
        switch style {
        case .hero:
            heroCard
        case .standard:
            standardCard
        case .compact:
            compactCard
        }
    }

    private var heroCard: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Backdrop image
                MoviePosterImage.hero(posterPath: movie.posterImagePath)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                    .clipped()

                // Gradient overlay
                LinearGradient(
                    colors: [
                        Color.clear,
                        DSColors.backgroundSwiftUI.opacity(0.8),
                        DSColors.backgroundSwiftUI
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Content overlay
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(movie.title)
                                .font(DSTypography.h2SwiftUI(weight: .semibold))
                                .foregroundColor(DSColors.primaryTextSwiftUI)
                                .lineLimit(2)

                            Text(movie.releaseDate)
                                .font(DSTypography.bodyMediumSwiftUI())
                                .foregroundColor(DSColors.secondaryTextSwiftUI)

                            DSRating(rating: parseRating(movie.voteAverage), size: .medium)
                        }

                        Spacer()
                    }

                    // Action buttons
                    HStack(spacing: 12) {
                        DSActionButton(title: "Play", style: .primary, icon: .pause) {
                            onTap()
                        }

                        if let onWatchlistTap = onWatchlistTap {
                            DSIconButton(
                                icon: isInWatchlist ? .download : .downloadOffline,
                                style: .secondary,
                                action: onWatchlistTap
                            )
                        }

                        if let onFavoriteTap = onFavoriteTap {
                            DSIconButton(
                                icon: isFavorite ? .heart : .heart,
                                style: .secondary,
                                action: onFavoriteTap
                            )
                        }

                        Spacer()
                    }
                }
                .padding(20)
            }
        }
    }

    private var standardCard: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    // Poster image
                    if let posterPath = movie.posterImagePath {
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

                    // Rating badge
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#FF8700"))

                        Text(String(format: "%.1f", min(parseRating(movie.voteAverage) * 2, 10)))
                            .font(DSTypography.h6SwiftUI(weight: .semibold))
                            .foregroundColor(Color(hex: "#FF8700"))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
                    .padding(8)
                }
                .frame(width: 135, height: 178)
                .clipped()
                .cornerRadius(12, corners: [.topLeft, .topRight])

                // Movie info
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(DSTypography.h5SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(getGenreText())
                        .font(DSTypography.h7SwiftUI(weight: .medium))
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .frame(width: 135, alignment: .leading)
            }
            .background(DSColors.surfaceSwiftUI)
            .cornerRadius(12)
        }
    }

    private func getGenreText() -> String {
        // In real implementation, this would come from movie genres
        return "Action"
    }

    private var compactCard: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Poster thumbnail
                MoviePosterImage.compact(posterPath: movie.posterImagePath)
                    .frame(width: 60, height: 90)

                // Movie info
                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.title)
                        .font(DSTypography.h5SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                        .lineLimit(2)

                    Text(movie.releaseDate)
                        .font(DSTypography.bodyMediumSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)

                    DSRating(
                        rating: parseRating(movie.voteAverage),
                        maxRating: 5,
                        size: .small,
                        showValue: true
                    )

                    if !movie.overview.isEmpty {
                        Text(movie.overview)
                            .font(DSTypography.bodySmallSwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                            .lineLimit(2)
                    }
                }

                Spacer()

                // Action buttons
                VStack(spacing: 8) {
                    if let onWatchlistTap = onWatchlistTap {
                        DSIconButton(
                            icon: isInWatchlist ? .download : .downloadOffline,
                            style: .secondary,
                            size: .small,
                            action: onWatchlistTap
                        )
                    }

                    if let onFavoriteTap = onFavoriteTap {
                        DSIconButton(
                            icon: .heart,
                            style: .secondary,
                            size: .small,
                            action: onFavoriteTap
                        )
                    }
                }
            }
            .padding(16)
            .background(DSColors.surfaceSwiftUI)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func parseRating(_ voteAverage: String) -> Double {
        if let doubleValue = Double(voteAverage) {
            return min(doubleValue / 2.0, 5.0) // Convert from 10-point to 5-point scale
        }
        return 0.0
    }

    private var isInWatchlist: Bool {
        let movieModel = Movie(
            id: movie.id, // Now using the actual TMDB movie ID
            title: movie.title,
            posterPath: movie.posterImagePath,
            overview: movie.overview,
            releaseDate: nil,
            voteAverage: movie.voteAverage
        )
        return storage.isInWatchlist(movieModel)
    }

    private var isFavorite: Bool {
        let movieModel = Movie(
            id: movie.id, // Now using the actual TMDB movie ID
            title: movie.title,
            posterPath: movie.posterImagePath,
            overview: movie.overview,
            releaseDate: nil,
            voteAverage: movie.voteAverage
        )
        return storage.isFavorite(movieModel)
    }

}