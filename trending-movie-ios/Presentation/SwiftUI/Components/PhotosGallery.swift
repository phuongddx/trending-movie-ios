import SwiftUI

struct PhotosGallery: View {
    let images: MovieImages
    let onViewAll: () -> Void

    private let posterRepository = RealPosterImagesRepository()

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            // Header
            HStack {
                Text("Photos")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                Spacer()

                Button(action: onViewAll) {
                    HStack(spacing: DSSpacing.xxs) {
                        Text("View All")
                            .font(DSTypography.bodyMediumSwiftUI())
                            .foregroundColor(DSColors.accentSwiftUI)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(DSColors.accentSwiftUI)
                    }
                }
            }

            // Photo thumbnails
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.md) {
                    // Show first 5 backdrops
                    ForEach(images.backdrops.prefix(5), id: \.filePath) { image in
                        PhotoThumbnail(imagePath: image.filePath)
                    }
                }
            }
        }
    }
}

struct PhotoThumbnail: View {
    let imagePath: String
    @State private var isShowingFullScreen = false
    private let posterRepository = RealPosterImagesRepository()

    var body: some View {
        Button(action: {
            isShowingFullScreen = true
        }) {
            if let imageURL = posterRepository.getImageURL(for: imagePath, size: ImageSize.medium) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                            .frame(width: 150, height: 100)
                            .overlay(
                                ProgressView()
                                    .tint(DSColors.secondaryTextSwiftUI)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 100)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                            .frame(width: 150, height: 100)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(DSSpacing.CornerRadius.small)
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            }
        }
        .sheet(isPresented: $isShowingFullScreen) {
            FullScreenImageView(imagePath: imagePath)
        }
    }
}

struct FullScreenImageView: View {
    let imagePath: String
    @Environment(\.dismiss) var dismiss
    private let posterRepository = RealPosterImagesRepository()

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                if let imageURL = posterRepository.getImageURL(for: imagePath, size: ImageSize.original) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.white)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PhotosGallery_Previews: PreviewProvider {
    static var previews: some View {
        PhotosGallery(
            images: MovieImages(
                backdrops: [
                    MovieImage(filePath: "/sample1.jpg", width: 1920, height: 1080),
                    MovieImage(filePath: "/sample2.jpg", width: 1920, height: 1080)
                ],
                posters: []
            ),
            onViewAll: {}
        )
        .padding()
        .background(DSColors.backgroundSwiftUI)
    }
}