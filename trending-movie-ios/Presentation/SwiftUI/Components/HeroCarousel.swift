import SwiftUI

@available(iOS 15.0, *)
struct HeroCarousel: View {
    let movies: [MoviesListItemViewModel]
    let onTap: (MoviesListItemViewModel) -> Void
    let onWatchlistTap: ((MoviesListItemViewModel) -> Void)?
    let onFavoriteTap: ((MoviesListItemViewModel) -> Void)?

    @State private var currentIndex = 0
    @State private var timer: Timer?

    var body: some View {
        if movies.isEmpty {
            DSHeroCarouselSkeleton()
        } else {
            TabView(selection: $currentIndex) {
                ForEach(Array(movies.enumerated()), id: \.element.title) { index, movie in
                    MovieCard(
                        movie: movie,
                        style: .hero,
                        onTap: { onTap(movie) },
                        onWatchlistTap: onWatchlistTap != nil ? { onWatchlistTap?(movie) } : nil,
                        onFavoriteTap: onFavoriteTap != nil ? { onFavoriteTap?(movie) } : nil
                    )
                    .tag(index)
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.6)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .onAppear {
                startAutoScroll()
            }
            .onDisappear {
                stopAutoScroll()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                startAutoScroll()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                stopAutoScroll()
            }
        }
    }

    private func startAutoScroll() {
        guard movies.count > 1 else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % movies.count
            }
        }
    }

    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
}

@available(iOS 15.0, *)
struct CategoryCarousel: View {
    let title: String
    let movies: [MoviesListItemViewModel]
    let onTap: (MoviesListItemViewModel) -> Void
    let onSeeAll: (() -> Void)?

    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            // Section header
            HStack {
                Text(title)
                    .font(DSTypography.title3SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

                Spacer()

                if let onSeeAll = onSeeAll {
                    Button("See All", action: onSeeAll)
                        .font(DSTypography.subheadlineSwiftUI(weight: .medium))
                        .foregroundColor(DSColors.accentSwiftUI(for: theme))
                }
            }
            .padding(.horizontal, DSSpacing.Padding.container)

            // Horizontal scroll view
            if movies.isEmpty {
                DSCarouselSkeleton()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DSSpacing.md) {
                        ForEach(movies, id: \.title) { movie in
                            MovieCard(
                                movie: movie,
                                style: .standard,
                                onTap: { onTap(movie) }
                            )
                        }
                    }
                    .padding(.horizontal, DSSpacing.Padding.container)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct CastCarousel: View {
    let cast: [CastMember]
    let onTap: ((CastMember) -> Void)?

    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Cast & Crew")
                .font(DSTypography.title3SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                .padding(.horizontal, DSSpacing.Padding.container)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.md) {
                    ForEach(cast, id: \.id) { member in
                        CastMemberCard(
                            member: member,
                            onTap: onTap != nil ? { onTap?(member) } : nil
                        )
                    }
                }
                .padding(.horizontal, DSSpacing.Padding.container)
            }
        }
    }
}

struct CastMember {
    let id: String
    let name: String
    let character: String?
    let profilePath: String?
}

@available(iOS 15.0, *)
struct CastMemberCard: View {
    let member: CastMember
    let onTap: (() -> Void)?

    @Environment(\.dsTheme) private var theme
    @State private var profileImage: UIImage?

    var body: some View {
        Button(action: onTap ?? {}) {
            VStack(spacing: DSSpacing.xs) {
                // Profile image
                Group {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Circle()
                            .fill(DSColors.shimmerBackground(for: theme).swiftUIColor)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                                    .font(.title2)
                            )
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())

                // Name and character
                VStack(spacing: DSSpacing.xxs) {
                    Text(member.name)
                        .font(DSTypography.caption1SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    if let character = member.character {
                        Text(character)
                            .font(DSTypography.caption2SwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(width: 80)
            }
        }
        .disabled(onTap == nil)
        .onAppear {
            loadProfileImage()
        }
    }

    private func loadProfileImage() {
        // This would load the profile image from TMDB
        // For now, just use a placeholder
        profileImage = UIImage(systemName: "person.crop.circle.fill")
    }
}