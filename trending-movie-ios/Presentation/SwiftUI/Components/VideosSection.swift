import SwiftUI

struct VideosSection: View {
    let videos: [Video]
    let onViewAll: () -> Void

    @State private var selectedVideo: Video?

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            // Header
            HStack {
                Text("Videos")
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

            // Video thumbnails
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.md) {
                    ForEach(videos.prefix(5)) { video in
                        VideoThumbnail(video: video) {
                            selectedVideo = video
                            playVideo(video)
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedVideo) { video in
            VideoPlayerView(video: video)
        }
    }

    private func playVideo(_ video: Video) {
        if video.site == "YouTube" {
            if let url = URL(string: "https://www.youtube.com/watch?v=\(video.key)") {
                UIApplication.shared.open(url)
            }
        }
    }
}

struct VideoThumbnail: View {
    let video: Video
    let onTap: () -> Void

    @State private var thumbnailImage: UIImage?

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Thumbnail background
                if let thumbnailImage = thumbnailImage {
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(width: 200, height: 112)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(DSColors.surfaceSwiftUI)
                        .frame(width: 200, height: 112)
                        .overlay(
                            ProgressView()
                                .tint(DSColors.secondaryTextSwiftUI)
                        )
                }

                // Play button overlay
                Circle()
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .offset(x: 2) // Slight offset to center visually
                    )

                // Video title at bottom
                VStack {
                    Spacer()
                    Text(video.name)
                        .font(DSTypography.captionSwiftUI())
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .padding(.horizontal, DSSpacing.xs)
                        .padding(.vertical, DSSpacing.xxs)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }
            .frame(width: 200, height: 112)
            .cornerRadius(DSSpacing.CornerRadius.small)
            .shadow(
                color: Color.black.opacity(0.2),
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .onAppear {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        guard video.site == "YouTube" else { return }
        let thumbnailURL = "https://img.youtube.com/vi/\(video.key)/hqdefault.jpg"

        if let url = URL(string: thumbnailURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.thumbnailImage = image
                    }
                }
            }.resume()
        }
    }
}

struct VideoPlayerView: View {
    let video: Video

    var body: some View {
        NavigationView {
            VStack {
                if video.site == "YouTube" {
                    Text("Open in YouTube to play")
                        .font(DSTypography.bodyMediumSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                        .padding()

                    Button(action: {
                        if let url = URL(string: "https://www.youtube.com/watch?v=\(video.key)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Open YouTube")
                            .font(DSTypography.bodyMediumSwiftUI(weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, DSSpacing.lg)
                            .padding(.vertical, DSSpacing.sm)
                            .background(Color.red)
                            .cornerRadius(DSSpacing.CornerRadius.small)
                    }
                } else {
                    Text("Video player not available")
                        .font(DSTypography.bodyMediumSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                }
            }
            .navigationTitle(video.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismissal handled by sheet
                    }
                }
            }
        }
    }
}

struct VideosSection_Previews: PreviewProvider {
    static var previews: some View {
        VideosSection(
            videos: [
                Video(id: "1", key: "abc123", name: "Official Trailer", site: "YouTube", type: "Trailer", size: 1080),
                Video(id: "2", key: "def456", name: "Teaser", site: "YouTube", type: "Teaser", size: 1080)
            ],
            onViewAll: {}
        )
        .padding()
        .background(DSColors.backgroundSwiftUI)
    }
}