import SwiftUI

@available(iOS 15.0, *)
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

    @Environment(\.dsTheme) private var theme
    @State private var posterImage: UIImage?
    @State private var imageLoadTask: Cancellable?
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
                                    .scaleEffect(0.8)
                            )
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.5)
                .clipped()

                // Gradient overlay
                LinearGradient(
                    colors: [
                        Color.clear,
                        DSColors.primaryBackgroundSwiftUI(for: theme).opacity(0.8),
                        DSColors.primaryBackgroundSwiftUI(for: theme)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Content overlay
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    HStack {
                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text(movie.title)
                                .font(DSTypography.title1SwiftUI(weight: .bold))
                                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                                .lineLimit(2)

                            Text(movie.releaseDate)
                                .font(DSTypography.subheadlineSwiftUI())
                                .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))

                            Text(movie.voteAverage)
                                .font(DSTypography.caption1SwiftUI(weight: .medium))
                                .foregroundColor(DSColors.accentSwiftUI(for: theme))
                        }

                        Spacer()

                        // Rating chip
                        ratingChip
                    }

                    // Action buttons
                    HStack(spacing: DSSpacing.md) {
                        DSActionButton(title: "Play", style: .primary, icon: "play.fill") {
                            onTap()
                        }

                        if let onWatchlistTap = onWatchlistTap {
                            DSIconButton(
                                icon: isInWatchlist ? "bookmark.fill" : "bookmark",
                                style: .ghost,
                                action: onWatchlistTap
                            )
                        }

                        if let onFavoriteTap = onFavoriteTap {
                            DSIconButton(
                                icon: isFavorite ? "heart.fill" : "heart",
                                style: .ghost,
                                action: onFavoriteTap
                            )
                        }

                        Spacer()
                    }
                }
                .padding(DSSpacing.Padding.container)
            }
        }
        .onAppear { loadPosterImage() }
        .onDisappear { imageLoadTask?.cancel() }
    }

    private var standardCard: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                // Poster image
                Group {
                    if let posterImage = posterImage {
                        Image(uiImage: posterImage)
                            .resizable()
                            .aspectRatio(2/3, contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(DSColors.shimmerBackground(for: theme).swiftUIColor)
                            .aspectRatio(2/3, contentMode: .fill)
                            .overlay(
                                DSLoadingSpinner()
                                    .scaleEffect(0.5)
                            )
                    }
                }
                .frame(width: 140)
                .cornerRadius(DSSpacing.CornerRadius.medium)
                .clipped()

                // Movie info
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(movie.title)
                        .font(DSTypography.subheadlineSwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                        .lineLimit(2)

                    Text(movie.releaseDate)
                        .font(DSTypography.caption1SwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                        .lineLimit(1)

                    Text(movie.voteAverage)
                        .font(DSTypography.caption2SwiftUI(weight: .medium))
                        .foregroundColor(DSColors.accentSwiftUI(for: theme))
                }
                .frame(width: 140, alignment: .leading)
            }
        }
        .onAppear { loadPosterImage() }
        .onDisappear { imageLoadTask?.cancel() }
    }

    private var compactCard: some View {
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
                    Text(movie.title)
                        .font(DSTypography.headlineSwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                        .lineLimit(2)

                    Text(movie.releaseDate)
                        .font(DSTypography.subheadlineSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))

                    Text(movie.voteAverage)
                        .font(DSTypography.caption1SwiftUI(weight: .medium))
                        .foregroundColor(DSColors.accentSwiftUI(for: theme))

                    if !movie.overview.isEmpty {
                        Text(movie.overview)
                            .font(DSTypography.caption1SwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                            .lineLimit(2)
                    }
                }

                Spacer()

                // Action buttons
                VStack(spacing: DSSpacing.xs) {
                    if let onWatchlistTap = onWatchlistTap {
                        DSIconButton(
                            icon: isInWatchlist ? "bookmark.fill" : "bookmark",
                            style: .secondary,
                            action: onWatchlistTap
                        )
                    }

                    if let onFavoriteTap = onFavoriteTap {
                        DSIconButton(
                            icon: isFavorite ? "heart.fill" : "heart",
                            style: .secondary,
                            action: onFavoriteTap
                        )
                    }
                }
            }
            .padding(DSSpacing.Padding.card)
            .background(DSColors.secondaryBackgroundSwiftUI(for: theme))
            .cornerRadius(DSSpacing.CornerRadius.card)
        }
        .onAppear { loadPosterImage() }
        .onDisappear { imageLoadTask?.cancel() }
    }

    private var ratingChip: some View {
        HStack(spacing: DSSpacing.xxs) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(.yellow)

            Text(movie.voteAverage)
                .font(DSTypography.caption1SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(Color.black.opacity(0.6))
        .cornerRadius(DSSpacing.CornerRadius.small)
    }

    private var isInWatchlist: Bool {
        let movieModel = Movie(
            id: movie.title, // Using title as ID since MoviesListItemViewModel doesn't expose the actual ID
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
            id: movie.title,
            title: movie.title,
            posterPath: movie.posterImagePath,
            overview: movie.overview,
            releaseDate: nil,
            voteAverage: movie.voteAverage
        )
        return storage.isFavorite(movieModel)
    }

    private func loadPosterImage() {
        imageLoadTask = movie.loadPosterImage { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    posterImage = UIImage(data: data)
                case .failure:
                    posterImage = UIImage(named: "placeholder-bg")
                }
            }
        }
    }
}