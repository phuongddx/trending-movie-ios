import SwiftUI

struct MovieDetailHero: View {
    let movie: Movie
    let onWatchlistTap: () -> Void
    let onFavoriteTap: () -> Void
    let onShareTap: () -> Void

    @StateObject private var storage = MovieStorage.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            // Backdrop image (using poster as backdrop)
            MoviePosterImage.hero(posterPath: movie.posterPath)
                .frame(height: UIScreen.main.bounds.height * 0.5)
                .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [
                    Color.clear,
                    DSColors.backgroundSwiftUI.opacity(0.6),
                    DSColors.backgroundSwiftUI.opacity(0.9),
                    DSColors.backgroundSwiftUI
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Content overlay
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                HStack(alignment: .top) {
                    // Movie poster thumbnail
                    MoviePosterImage.detail(posterPath: movie.posterPath)
                        .frame(width: 120)
                        .shadow(
                            color: Color.black.opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )

                    // Movie info
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text(movie.title ?? "Unknown Title")
                            .font(DSTypography.h1SwiftUI(weight: .semibold))
                            .foregroundColor(DSColors.primaryTextSwiftUI)
                            .lineLimit(2)

                        // Movie metadata (Duration, Director, Rating)
                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            // Duration and Director
                            HStack(spacing: DSSpacing.md) {
                                if let runtime = movie.runtime {
                                    Text(formatDuration(runtime))
                                        .font(DSTypography.bodySmallSwiftUI())
                                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                                }

                                if let director = movie.director {
                                    HStack(spacing: DSSpacing.xxs) {
                                        Text("Director:")
                                            .font(DSTypography.bodySmallSwiftUI())
                                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                                        Text(director)
                                            .font(DSTypography.bodySmallSwiftUI(weight: .medium))
                                            .foregroundColor(DSColors.primaryTextSwiftUI)
                                    }
                                }
                            }

                            // Age rating and genres
                            HStack(spacing: DSSpacing.sm) {
                                if let certification = movie.certification, !certification.isEmpty {
                                    AgeRatingBadge(rating: certification)
                                }

                                if let genres = movie.genres, !genres.isEmpty {
                                    Text(genres.prefix(2).joined(separator: ", "))
                                        .font(DSTypography.bodySmallSwiftUI())
                                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                                        .lineLimit(1)
                                }
                            }
                        }

                        if let tagline = movie.tagline, !tagline.isEmpty {
                            Text(tagline)
                                .font(DSTypography.bodyMediumSwiftUI())
                                .foregroundColor(DSColors.secondaryTextSwiftUI)
                                .italic()
                                .lineLimit(1)
                        }

                        // Rating and vote count
                        HStack(spacing: DSSpacing.md) {
                            if let voteAverage = movie.voteAverage {
                                HStack(spacing: DSSpacing.xxs) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)

                                    Text(voteAverage)
                                        .font(DSTypography.h4SwiftUI(weight: .semibold))
                                        .foregroundColor(DSColors.primaryTextSwiftUI)
                                }
                                .padding(.horizontal, DSSpacing.sm)
                                .padding(.vertical, DSSpacing.xs)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(DSSpacing.CornerRadius.small)
                            }

                            if let voteCount = movie.voteCount {
                                Text("(\(formatVoteCount(voteCount)))")
                                    .font(DSTypography.captionSwiftUI())
                                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                            }

                            Spacer()
                        }

                        // Release date
                        if let releaseDate = movie.releaseDate {
                            Text(dateFormatter.string(from: releaseDate))
                                .font(DSTypography.bodyMediumSwiftUI())
                                .foregroundColor(DSColors.secondaryTextSwiftUI)
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Action buttons
                HStack(spacing: DSSpacing.md) {
                    DSActionButton(
                        title: "Play Trailer",
                        style: .primary,
                        icon: .pause
                    ) {
                        // Handle play trailer
                    }

                    DSIconButton(
                        icon: storage.isInWatchlist(movie) ? .download : .download,
                        style: .text,
                        action: onWatchlistTap
                    )

                    DSIconButton(
                        icon: storage.isFavorite(movie) ? .heart : .heart,
                        style: .text,
                        action: onFavoriteTap
                    )

                    DSIconButton(
                        icon: .share,
                        style: .text,
                        action: onShareTap
                    )

                    Spacer()
                }
            }
            .padding(DSSpacing.Padding.container)
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)min"
        } else {
            return "\(remainingMinutes)min"
        }
    }

    private func formatVoteCount(_ count: Int) -> String {
        if count >= 1000 {
            let thousands = Double(count) / 1000.0
            return String(format: "%.1fk", thousands)
        } else {
            return "\(count)"
        }
    }
}

struct MovieDetailTabs: View {
    let movie: Movie
    @State private var selectedTab = 0


    private let tabs = [
        DSTabItem(title: "Overview", icon: "text.alignleft"),
        DSTabItem(title: "Cast", icon: "person.2"),
        DSTabItem(title: "Similar", icon: "square.grid.2x2")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = index
                        }
                    } label: {
                        VStack(spacing: DSSpacing.xs) {
                            HStack(spacing: DSSpacing.xs) {
                                Image(systemName: tab.icon)
                                    .font(.body)

                                Text(tab.title)
                                    .font(DSTypography.bodyMediumSwiftUI(weight: selectedTab == index ? .semibold : .regular))
                            }
                            .foregroundColor(selectedTab == index ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI)

                            // Active indicator
                            Rectangle()
                                .fill(DSColors.accentSwiftUI)
                                .frame(height: 2)
                                .opacity(selectedTab == index ? 1 : 0)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .background(DSColors.surfaceSwiftUI)

            // Tab content
            ScrollView {
                switch selectedTab {
                case 0:
                    OverviewTab(movie: movie)
                case 1:
                    CastTab(movie: movie)
                case 2:
                    SimilarTab(movie: movie)
                default:
                    OverviewTab(movie: movie)
                }
            }
        }
    }
}

struct OverviewTab: View {
    let movie: Movie
    @State private var isShowingRateSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            // Watch Trailer button if videos available
            if let videos = movie.videos, !videos.isEmpty,
               let trailer = videos.first(where: { $0.type == "Trailer" }) ?? videos.first {
                DSActionButton(
                    title: "Watch Trailer",
                    style: .primary,
                    icon: .pause
                ) {
                    playVideo(trailer)
                }
                .padding(.horizontal, DSSpacing.Padding.container)
            }
            // Synopsis
            if let overview = movie.overview, !overview.isEmpty {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Synopsis")
                        .font(DSTypography.h4SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)

                    Text(overview)
                        .font(DSTypography.bodyMediumSwiftUI())
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                        .lineSpacing(4)
                }
                .padding(.horizontal, DSSpacing.Padding.container)
            }

            // Cast section
            if let credits = movie.credits, !credits.cast.isEmpty {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Cast")
                        .font(DSTypography.h4SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                        .padding(.horizontal, DSSpacing.Padding.container)

                    CastCarousel(cast: Array(credits.cast.prefix(10))) { member in
                        // Handle cast member tap
                    }
                }
            }

            // Videos section
            if let videos = movie.videos, !videos.isEmpty {
                VideosSection(
                    videos: videos,
                    onViewAll: {
                        // Handle view all videos
                    }
                )
                .padding(.horizontal, DSSpacing.Padding.container)
            }

            // Photos section
            if let images = movie.images, !images.backdrops.isEmpty {
                PhotosGallery(
                    images: images,
                    onViewAll: {
                        // Handle view all photos
                    }
                )
                .padding(.horizontal, DSSpacing.Padding.container)
            }

            // Rating section
            if let voteAverage = movie.voteAverage,
               let voteCount = movie.voteCount,
               let avgDouble = Double(voteAverage) {
                VStack(spacing: DSSpacing.md) {
                    RatingDistribution(
                        voteAverage: avgDouble,
                        voteCount: voteCount,
                        distribution: nil // We don't have distribution data from API
                    )
                    .padding(.horizontal, DSSpacing.Padding.container)

                    // Rate this movie button
                    DSActionButton(
                        title: "Rate this Movie",
                        style: .secondary
                    ) {
                        isShowingRateSheet = true
                    }
                    .padding(.horizontal, DSSpacing.Padding.container)
                }
            }

            // Details
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Details")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                VStack(spacing: DSSpacing.xs) {
                    if let releaseDate = movie.releaseDate {
                        detailRow(title: "Release Date", value: dateFormatter.string(from: releaseDate))
                    }

                    if let voteAverage = movie.voteAverage {
                        detailRow(title: "Rating", value: voteAverage)
                    }

                    if let genres = movie.genres, !genres.isEmpty {
                        detailRow(title: "Genres", value: genres.joined(separator: ", "))
                    }

                    if let runtime = movie.runtime {
                        let hours = runtime / 60
                        let minutes = runtime % 60
                        let runtimeText = hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
                        detailRow(title: "Runtime", value: runtimeText)
                    }

                    if let status = movie.status {
                        detailRow(title: "Status", value: status)
                    }

                    if let productionCountries = movie.productionCountries, !productionCountries.isEmpty {
                        detailRow(title: "Countries", value: productionCountries.joined(separator: ", "))
                    }

                    if let budget = movie.budget, budget > 0 {
                        if let budgetString = currencyFormatter.string(from: NSNumber(value: budget)) {
                            detailRow(title: "Budget", value: budgetString)
                        }
                    }

                    if let revenue = movie.revenue, revenue > 0 {
                        if let revenueString = currencyFormatter.string(from: NSNumber(value: revenue)) {
                            detailRow(title: "Box Office", value: revenueString)
                        }
                    }
                }
                .padding(DSSpacing.Padding.card)
                .background(DSColors.surfaceSwiftUI)
                .cornerRadius(DSSpacing.CornerRadius.card)
                .padding(.horizontal, DSSpacing.Padding.container)
            }

            Spacer(minLength: DSSpacing.xxl)
        }
        .sheet(isPresented: $isShowingRateSheet) {
            RateMovieSheet(
                movie: movie,
                onSubmit: { rating in
                    // Handle rating submission
                    print("User rated movie: \(rating)/10")
                }
            )
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(DSTypography.bodyMediumSwiftUI(weight: .medium))
                .foregroundColor(DSColors.secondaryTextSwiftUI)

            Spacer()

            Text(value)
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.primaryTextSwiftUI)
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private func playVideo(_ video: Video) {
        if video.site == "YouTube" {
            if let url = URL(string: "https://www.youtube.com/watch?v=\(video.key)") {
                UIApplication.shared.open(url)
            }
        }
    }
}

struct CastTab: View {
    let movie: Movie

    private var cast: [CastMember] {
        movie.credits?.cast ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            CastCarousel(cast: cast) { member in
                // Handle cast member tap
            }

            Spacer(minLength: DSSpacing.xxl)
        }
        .padding(.top, DSSpacing.md)
    }
}

struct SimilarTab: View {
    let movie: Movie


    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            Text("Similar Movies")
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)
                .padding(.horizontal, DSSpacing.Padding.container)

            // This would show similar movies
            Text("Similar movies would be loaded here from the API")
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .padding(DSSpacing.Padding.container)

            Spacer(minLength: DSSpacing.xxl)
        }
        .padding(.top, DSSpacing.md)
    }
}
