import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        title: String,
        subtitle: String,
        systemImage: String = "film",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: DSSpacing.xl) {
            // Illustration
            Image(systemName: systemImage)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(DSColors.secondaryTextSwiftUI.opacity(0.6))

            // Text content
            VStack(spacing: DSSpacing.sm) {
                Text(title)
                    .font(DSTypography.h3SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.lg)
            }

            // Action button
            if let actionTitle = actionTitle, let action = action {
                DSActionButton(
                    title: actionTitle,
                    style: .primary
                ) {
                    action()
                }
                .padding(.top, DSSpacing.md)
            }

            Spacer()
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Convenience factory methods

extension EmptyStateView {
    static func noMoviesFound(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            title: "No Movies Found",
            subtitle: "We couldn't find any movies matching your search. Try adjusting your filters or search terms.",
            systemImage: "magnifyingglass",
            actionTitle: "Clear Filters",
            action: action
        )
    }

    static func emptyWatchlist(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            title: "Your Watchlist is Empty",
            subtitle: "Start building your movie collection by adding films you want to watch later.",
            systemImage: "bookmark",
            actionTitle: "Browse Movies",
            action: action
        )
    }

    static func emptyFavorites(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            title: "No Favorites Yet",
            subtitle: "Mark movies as favorites to easily find them later.",
            systemImage: "heart",
            actionTitle: "Discover Movies",
            action: action
        )
    }

    static func emptySearchResults() -> EmptyStateView {
        EmptyStateView(
            title: "No Results",
            subtitle: "Try searching for a different movie title, actor, or director.",
            systemImage: "magnifyingglass"
        )
    }

    static func noInternetConnection(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            title: "No Internet Connection",
            subtitle: "Please check your connection and try again.",
            systemImage: "wifi.slash",
            actionTitle: "Retry",
            action: action
        )
    }

    static func comingSoon() -> EmptyStateView {
        EmptyStateView(
            title: "Coming Soon",
            subtitle: "This feature is under development and will be available in a future update.",
            systemImage: "wrench.and.screwdriver"
        )
    }

    static func maintenanceMode() -> EmptyStateView {
        EmptyStateView(
            title: "Under Maintenance",
            subtitle: "We're making improvements to bring you a better experience. Please check back later.",
            systemImage: "gear"
        )
    }

    static func emptyGenre(genre: String, action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            title: "No \(genre) Movies",
            subtitle: "We couldn't find any movies in this genre. Explore other categories or check back later.",
            systemImage: "film",
            actionTitle: "Browse All Movies",
            action: action
        )
    }
}

// MARK: - Previews

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmptyStateView.noMoviesFound {
                print("Clear filters tapped")
            }
            .previewDisplayName("No Movies Found")

            EmptyStateView.emptyWatchlist {
                print("Browse movies tapped")
            }
            .previewDisplayName("Empty Watchlist")

            EmptyStateView.emptySearchResults()
                .previewDisplayName("Empty Search")

            EmptyStateView.comingSoon()
                .previewDisplayName("Coming Soon")
        }
        .background(DSColors.backgroundSwiftUI)
    }
}
