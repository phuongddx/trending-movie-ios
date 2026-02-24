import SwiftUI

struct MovieRowView: View {
    let movie: MoviesListItemViewModel
    let onWatchlistToggle: (() -> Void)?
    let onFavoriteToggle: (() -> Void)?
    let onShare: (() -> Void)?

    @StateObject private var storage = MovieStorage.shared

    init(
        movie: MoviesListItemViewModel,
        onWatchlistToggle: (() -> Void)? = nil,
        onFavoriteToggle: (() -> Void)? = nil,
        onShare: (() -> Void)? = nil
    ) {
        self.movie = movie
        self.onWatchlistToggle = onWatchlistToggle
        self.onFavoriteToggle = onFavoriteToggle
        self.onShare = onShare
    }

    private var movieModel: Movie {
        Movie(
            id: movie.id,
            title: movie.title,
            posterPath: movie.posterImagePath,
            overview: movie.overview,
            releaseDate: dateFormatter.date(from: movie.releaseDate),
            voteAverage: movie.voteAverage
        )
    }

    private var isInWatchlist: Bool {
        storage.isInWatchlist(movieModel)
    }

    private var isFavorite: Bool {
        storage.isFavorite(movieModel)
    }

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            posterImageView
            movieInfoView
            Spacer()
            actionButtonsView
        }
        .padding(DSSpacing.Padding.card)
        .frame(minHeight: 100)
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(DSSpacing.CornerRadius.card)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(movie.title), \(movie.releaseDate), rated \(movie.voteAverage) out of 10")
        .accessibilityHint("Double tap to view details")
    }

    // MARK: - Date Formatter
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }

    private var posterImageView: some View {
        MoviePosterImage.compact(posterPath: movie.posterImagePath)
            .frame(width: 60, height: 90)
    }

    private var movieInfoView: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(movie.title)
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)
                .lineLimit(2)

            Text(movie.releaseDate)
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .lineLimit(1)

            Text(movie.voteAverage)
                .font(DSTypography.bodySmallSwiftUI())
                .foregroundColor(DSColors.accentSwiftUI)
                .lineLimit(1)

            if !movie.overview.isEmpty {
                Text(movie.overview)
                    .font(DSTypography.bodySmallSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .lineLimit(3)
                    .padding(.top, DSSpacing.xxs)
            }
        }
    }

    // MARK: - Action Buttons View
    private var actionButtonsView: some View {
        HStack(spacing: DSSpacing.sm) {
            // Primary: Watchlist
            Button(action: { toggleWatchlist() }) {
                Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 20))
                    .foregroundColor(isInWatchlist ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI)
            }
            .frame(width: 44, height: 44)
            .accessibilityLabel(isInWatchlist ? "Remove from watchlist" : "Add to watchlist")
            .accessibilityAction(named: isInWatchlist ? "Remove from watchlist" : "Add to watchlist") {
                toggleWatchlist()
            }

            // Overflow menu
            Menu {
                Button(action: { toggleFavorite() }) {
                    Label(
                        isFavorite ? "Remove from favorites" : "Add to favorites",
                        systemImage: isFavorite ? "heart.fill" : "heart"
                    )
                }
                Button(action: { shareMovie() }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("More options")
        }
    }

    // MARK: - Actions
    private func toggleWatchlist() {
        if isInWatchlist {
            storage.removeFromWatchlist(movieModel)
        } else {
            storage.addToWatchlist(movieModel)
        }
        onWatchlistToggle?()
    }

    private func toggleFavorite() {
        if isFavorite {
            storage.removeFromFavorites(movieModel)
        } else {
            storage.addToFavorites(movieModel)
        }
        onFavoriteToggle?()
    }

    private func shareMovie() {
        onShare?()
    }
}

@available(iOS 13.0, *)
struct EmptyMoviesView: View {
    let message: String

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            Image(systemName: "film")
                .font(.system(size: 60))
                .foregroundColor(DSColors.secondaryTextSwiftUI)

            Text(message)
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .multilineTextAlignment(.center)
        }
        .padding(DSSpacing.xxl)
    }
}

@available(iOS 13.0, *)
struct MovieRowSkeleton: View {
    var body: some View {
        DSMovieCardSkeleton()
            .background(Color.clear)
    }
}

// MARK: - Preview
struct MovieRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock data for preview
        let mockMovie = MoviesListItemViewModel(
            movie: Movie(
                id: "1",
                title: "Sample Movie",
                posterPath: nil,
                overview: "This is a sample movie overview that shows multiple lines of text.",
                releaseDate: Date(),
                voteAverage: "8.5"
            )
        )

        return VStack {
            MovieRowView(movie: mockMovie)
            MovieRowSkeleton()
            EmptyMoviesView(message: "No movies found")
        }
        .padding()
        .background(DSColors.backgroundSwiftUI)
        .previewLayout(.sizeThatFits)
    }
}