import SwiftUI
import SDWebImage
import Factory

struct MoviePosterImage: View {
    let posterPath: String?
    let imageSize: ImageSize
    let aspectRatio: CGFloat
    let cornerRadius: CGFloat
    let showPlaceholder: Bool
    let showActivity: Bool

    @Injected(\AppContainer.posterImagesRepository) private var posterImagesRepository: PosterImagesRepository
    @State private var image: UIImage?
    @State private var isLoading: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var imageURL: URL? {
        guard let path = posterPath else { return nil }
        return posterImagesRepository.getImageURL(for: path, size: imageSize)
    }

    init(
        posterPath: String?,
        imageSize: ImageSize = .large,
        aspectRatio: CGFloat = 2/3,
        cornerRadius: CGFloat = 12,
        showPlaceholder: Bool = true,
        showActivity: Bool = true
    ) {
        self.posterPath = posterPath
        self.imageSize = imageSize
        self.aspectRatio = aspectRatio
        self.cornerRadius = cornerRadius
        self.showPlaceholder = showPlaceholder
        self.showActivity = showActivity
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: .fill)
                    .transition(reduceMotion ? .opacity : .opacity.animation(.easeInOut(duration: 0.3)))
            } else {
                placeholderView
                    .aspectRatio(aspectRatio, contentMode: .fill)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onAppear {
            loadImage()
        }
        .onChange(of: posterPath) { _ in
            loadImage()
        }
    }

    @ViewBuilder
    private var placeholderView: some View {
        if showPlaceholder {
            Rectangle()
                .fill(DSColors.surfaceSwiftUI)
                .overlay(
                    CinemaxIconView(
                        .film,
                        size: iconSize,
                        color: DSColors.tertiaryTextSwiftUI
                    )
                )
                .shimmer()
        } else {
            EmptyView()
        }
    }

    private var iconSize: DSIconSize {
        switch imageSize {
        case .thumbnail, .small:
            return .medium
        case .medium, .large:
            return .large
        case .extraLarge, .original:
            return .extraLarge
        }
    }

    private func loadImage() {
        guard let url = imageURL else {
            image = nil
            return
        }

        isLoading = true

        SDWebImageManager.shared.loadImage(
            with: url,
            options: [.refreshCached, .retryFailed],
            progress: nil
        ) { loadedImage, _, error, _, _, _ in
            DispatchQueue.main.async {
                self.isLoading = false
                if error == nil {
                    self.image = loadedImage
                }
            }
        }
    }
}

// MARK: - Convenience Initializers
extension MoviePosterImage {

    static func hero(posterPath: String?) -> MoviePosterImage {
        MoviePosterImage(
            posterPath: posterPath,
            imageSize: .extraLarge,
            aspectRatio: 16/9,
            cornerRadius: 0,
            showPlaceholder: true,
            showActivity: true
        )
    }

    static func standard(posterPath: String?) -> MoviePosterImage {
        MoviePosterImage(
            posterPath: posterPath,
            imageSize: .large,
            aspectRatio: 2/3,
            cornerRadius: 12,
            showPlaceholder: true,
            showActivity: true
        )
    }

    static func compact(posterPath: String?) -> MoviePosterImage {
        MoviePosterImage(
            posterPath: posterPath,
            imageSize: .medium,
            aspectRatio: 2/3,
            cornerRadius: 8,
            showPlaceholder: true,
            showActivity: false
        )
    }

    static func detail(posterPath: String?) -> MoviePosterImage {
        MoviePosterImage(
            posterPath: posterPath,
            imageSize: .extraLarge,
            aspectRatio: 2/3,
            cornerRadius: 16,
            showPlaceholder: true,
            showActivity: true
        )
    }
}

// MARK: - Preview
struct MoviePosterImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Standard poster
            MoviePosterImage.standard(posterPath: "/sample-poster.jpg")
                .frame(width: 140)

            // Hero style
            MoviePosterImage.hero(posterPath: "/sample-backdrop.jpg")
                .frame(height: 200)

            // Compact style
            MoviePosterImage.compact(posterPath: nil)
                .frame(width: 60, height: 90)
        }
        .padding()
        .background(DSColors.backgroundSwiftUI)
        .environmentObject(DSThemeManager.shared)
    }
}
