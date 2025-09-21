import SwiftUI

@available(iOS 15.0, *)
struct MovieDetailHero: View {
    let movie: Movie
    let posterImage: UIImage?
    let onWatchlistTap: () -> Void
    let onFavoriteTap: () -> Void
    let onShareTap: () -> Void

    @Environment(\.dsTheme) private var theme
    @StateObject private var storage = MovieStorage.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            // Backdrop image (using poster as backdrop)
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
                    DSColors.primaryBackgroundSwiftUI(for: theme).opacity(0.6),
                    DSColors.primaryBackgroundSwiftUI(for: theme).opacity(0.9),
                    DSColors.primaryBackgroundSwiftUI(for: theme)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Content overlay
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                HStack(alignment: .top) {
                    // Movie poster thumbnail
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
                    .frame(width: 120)
                    .cornerRadius(DSSpacing.CornerRadius.medium)
                    .shadow(
                        color: Color.black.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )

                    // Movie info
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text(movie.title ?? "Unknown Title")
                            .font(DSTypography.title1SwiftUI(weight: .bold))
                            .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                            .lineLimit(3)

                        // Rating and metadata
                        HStack(spacing: DSSpacing.md) {
                            if let voteAverage = movie.voteAverage {
                                HStack(spacing: DSSpacing.xxs) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)

                                    Text(voteAverage)
                                        .font(DSTypography.subheadlineSwiftUI(weight: .semibold))
                                        .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                                }
                                .padding(.horizontal, DSSpacing.sm)
                                .padding(.vertical, DSSpacing.xs)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(DSSpacing.CornerRadius.small)
                            }

                            Spacer()
                        }

                        // Release date
                        if let releaseDate = movie.releaseDate {
                            Text(dateFormatter.string(from: releaseDate))
                                .font(DSTypography.subheadlineSwiftUI())
                                .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
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
                        icon: "play.fill"
                    ) {
                        // Handle play trailer
                    }

                    DSIconButton(
                        icon: storage.isInWatchlist(movie) ? "bookmark.fill" : "bookmark",
                        style: .ghost,
                        action: onWatchlistTap
                    )

                    DSIconButton(
                        icon: storage.isFavorite(movie) ? "heart.fill" : "heart",
                        style: .ghost,
                        action: onFavoriteTap
                    )

                    DSIconButton(
                        icon: "square.and.arrow.up",
                        style: .ghost,
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
}

@available(iOS 15.0, *)
struct MovieDetailTabs: View {
    let movie: Movie
    @State private var selectedTab = 0

    @Environment(\.dsTheme) private var theme

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
                                    .font(DSTypography.bodySwiftUI(weight: selectedTab == index ? .semibold : .regular))
                            }
                            .foregroundColor(selectedTab == index ? DSColors.accentSwiftUI(for: theme) : DSColors.secondaryTextSwiftUI(for: theme))

                            // Active indicator
                            Rectangle()
                                .fill(DSColors.accentSwiftUI(for: theme))
                                .frame(height: 2)
                                .opacity(selectedTab == index ? 1 : 0)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .background(DSColors.secondaryBackgroundSwiftUI(for: theme))

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

@available(iOS 15.0, *)
struct OverviewTab: View {
    let movie: Movie

    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            // Synopsis
            if let overview = movie.overview, !overview.isEmpty {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Synopsis")
                        .font(DSTypography.title3SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

                    Text(overview)
                        .font(DSTypography.bodySwiftUI())
                        .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                        .lineSpacing(4)
                }
            }

            // Details
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Details")
                    .font(DSTypography.title3SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

                VStack(spacing: DSSpacing.xs) {
                    if let releaseDate = movie.releaseDate {
                        detailRow(title: "Release Date", value: dateFormatter.string(from: releaseDate))
                    }

                    if let voteAverage = movie.voteAverage {
                        detailRow(title: "Rating", value: voteAverage)
                    }
                }
                .padding(DSSpacing.Padding.card)
                .background(DSColors.secondaryBackgroundSwiftUI(for: theme))
                .cornerRadius(DSSpacing.CornerRadius.card)
            }

            Spacer(minLength: DSSpacing.xxl)
        }
        .padding(DSSpacing.Padding.container)
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(DSTypography.subheadlineSwiftUI(weight: .medium))
                .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))

            Spacer()

            Text(value)
                .font(DSTypography.subheadlineSwiftUI())
                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
}

@available(iOS 15.0, *)
struct CastTab: View {
    let movie: Movie

    @Environment(\.dsTheme) private var theme

    // Mock cast data
    private let mockCast = [
        CastMember(id: "1", name: "Actor One", character: "Main Character", profilePath: nil),
        CastMember(id: "2", name: "Actor Two", character: "Supporting Role", profilePath: nil),
        CastMember(id: "3", name: "Actor Three", character: "Villain", profilePath: nil),
        CastMember(id: "4", name: "Actor Four", character: "Love Interest", profilePath: nil),
        CastMember(id: "5", name: "Actor Five", character: "Comic Relief", profilePath: nil)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            CastCarousel(cast: mockCast) { member in
                // Handle cast member tap
            }

            Spacer(minLength: DSSpacing.xxl)
        }
        .padding(.top, DSSpacing.md)
    }
}

@available(iOS 15.0, *)
struct SimilarTab: View {
    let movie: Movie

    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            Text("Similar Movies")
                .font(DSTypography.title3SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                .padding(.horizontal, DSSpacing.Padding.container)

            // This would show similar movies
            Text("Similar movies would be loaded here from the API")
                .font(DSTypography.bodySwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                .padding(DSSpacing.Padding.container)

            Spacer(minLength: DSSpacing.xxl)
        }
        .padding(.top, DSSpacing.md)
    }
}