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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Text(title)
                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                Spacer()

                if let onSeeAll = onSeeAll {
                    Button("See All", action: onSeeAll)
                        .font(DSTypography.bodyMediumSwiftUI(weight: .medium))
                        .foregroundColor(DSColors.accentSwiftUI)
                }
            }
            .padding(.horizontal, 20)

            // Horizontal scroll view
            if movies.isEmpty {
                DSCarouselSkeleton()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(movies, id: \.title) { movie in
                            MovieCard(
                                movie: movie,
                                style: .standard,
                                onTap: { onTap(movie) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct CastCarousel: View {
    let cast: [CastMember]
    let onTap: ((CastMember) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast & Crew")
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(cast, id: \.id) { member in
                        CastMemberCard(
                            member: member,
                            onTap: onTap != nil ? { onTap?(member) } : nil
                        )
                    }
                }
                .padding(.horizontal, 20)
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

    @State private var profileImage: UIImage?

    var body: some View {
        Button(action: onTap ?? {}) {
            VStack(spacing: 8) {
                // Profile image
                Group {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Circle()
                            .fill(DSColors.surfaceSwiftUI)
                            .overlay(
                                CinemaxIconView(.person, size: .large, color: DSColors.secondaryTextSwiftUI)
                            )
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())

                // Name and character
                VStack(spacing: 4) {
                    Text(member.name)
                        .font(DSTypography.bodySmallSwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    if let character = member.character {
                        Text(character)
                            .font(DSTypography.captionSwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
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