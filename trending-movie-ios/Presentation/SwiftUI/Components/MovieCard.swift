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
                            .fill(DSColors.surfaceSwiftUI)
                            .overlay(
                                CinemaxIconView(.film, size: .extraLarge, color: DSColors.tertiaryTextSwiftUI)
                            )
                    }
                }
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
        .onAppear { loadPosterImage() }
        .onDisappear { imageLoadTask?.cancel() }
    }

    private var standardCard: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Poster image
                Group {
                    if let posterImage = posterImage {
                        Image(uiImage: posterImage)
                            .resizable()
                            .aspectRatio(2/3, contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                            .aspectRatio(2/3, contentMode: .fill)
                            .overlay(
                                CinemaxIconView(.film, size: .large, color: DSColors.tertiaryTextSwiftUI)
                            )
                    }
                }
                .frame(width: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Movie info
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(DSTypography.bodyMediumSwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                        .lineLimit(2)

                    Text(movie.releaseDate)
                        .font(DSTypography.bodySmallSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                        .lineLimit(1)

                    DSRating(
                        rating: parseRating(movie.voteAverage),
                        maxRating: 5,
                        size: .small,
                        showValue: false
                    )
                }
                .frame(width: 140, alignment: .leading)
            }
        }
        .onAppear { loadPosterImage() }
        .onDisappear { imageLoadTask?.cancel() }
    }

    private var compactCard: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
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
        .onAppear { loadPosterImage() }
        .onDisappear { imageLoadTask?.cancel() }
    }

    private func parseRating(_ voteAverage: String) -> Double {
        if let doubleValue = Double(voteAverage) {
            return min(doubleValue / 2.0, 5.0) // Convert from 10-point to 5-point scale
        }
        return 0.0
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