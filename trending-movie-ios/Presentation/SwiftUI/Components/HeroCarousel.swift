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
            ZStack(alignment: .bottom) {
                TabView(selection: $currentIndex) {
                    ForEach(Array(movies.prefix(3).enumerated()), id: \.element.id) { index, movie in
                        HeroSlide(
                            movie: movie,
                            onTap: { onTap(movie) }
                        )
                        .tag(index)
                    }
                }
                .frame(height: 174)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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

                CustomPageIndicator(numberOfPages: min(movies.count, 3), currentIndex: $currentIndex)
                    .padding(.bottom, 8)
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

struct HeroSlide: View {
    let movie: MoviesListItemViewModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                GeometryReader { geometry in
                    ZStack {
                        if let posterPath = movie.posterImagePath {
                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w780\(posterPath)")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            } placeholder: {
                                Rectangle()
                                    .fill(DSColors.surfaceSwiftUI)
                            }
                        } else {
                            Rectangle()
                                .fill(DSColors.surfaceSwiftUI)
                        }

                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.black.opacity(0.2), location: 0),
                                .init(color: Color.black.opacity(1), location: 0.84)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .opacity(0.32)
                    }
                }
                .cornerRadius(16)

                VStack(alignment: .leading, spacing: 0) {
                    Text(movie.title)
                        .font(DSTypography.h4SwiftUI(weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(.leading, 16)
                .padding(.bottom, 16)
            }
            .frame(height: 154)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 40)
    }
}

struct CustomPageIndicator: View {
    let numberOfPages: Int
    @Binding var currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                if index == currentIndex {
                    Capsule()
                        .fill(Color(hex: "#12CDD9"))
                        .frame(width: 24, height: 8)
                } else {
                    Circle()
                        .fill(Color(hex: "#12CDD9").opacity(0.32))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentIndex)
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
                        ForEach(movies, id: \.id) { movie in
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