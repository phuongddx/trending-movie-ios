import SwiftUI
// TODO: Add YouTubePlayerKit package dependency before using
// import YouTubePlayerKit

struct YouTubePlayerView: View {
    let videoID: String
    let title: String
    @Environment(\.dismiss) var dismiss
    // @State private var youTubePlayer: YouTubePlayer  // Uncomment after adding YouTubePlayerKit
    @State private var isLoading = true
    @State private var hasError = false

    init(videoID: String, title: String) {
        self.videoID = videoID
        self.title = title
        // TODO: Initialize YouTubePlayer after adding YouTubePlayerKit package
        /*
        self._youTubePlayer = State(initialValue: YouTubePlayer(
            source: .video(id: videoID),
            configuration: .init(
                autoPlay: true,
                showControls: true,
                showFullscreenButton: true,
                startTime: 0,
                endTime: nil,
                showAnnotations: false,
                showRelatedVideos: false,
                loopEnabled: false,
                enableJavaScriptAPI: false
            )
        ))
        */
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack {
                    if hasError {
                        errorView
                    } else {
                        placeholderView
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(DSTypography.h4SwiftUI(weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .preferredColorScheme(.dark)
        }
        .onAppear {
            // TODO: Update player source after adding YouTubePlayerKit
            // youTubePlayer.update(source: .video(id: videoID))
            isLoading = false
        }
    }

    private var placeholderView: some View {
        VStack(spacing: 24) {
            Image(systemName: "play.rectangle")
                .font(.system(size: 64))
                .foregroundColor(.white)

            Text("YouTube Player")
                .font(DSTypography.h3SwiftUI(weight: .semibold))
                .foregroundColor(.white)

            Text("Video ID: \(videoID)")
                .font(DSTypography.h5SwiftUI(weight: .regular))
                .foregroundColor(DSColors.secondaryTextSwiftUI)

            Text("Add YouTubePlayerKit package to enable trailer playback")
                .font(DSTypography.h6SwiftUI(weight: .regular))
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Open in YouTube") {
                if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(hex: "#12CDD9"))
            .foregroundColor(.white)
            .font(DSTypography.h4SwiftUI(weight: .medium))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorView: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.white)

            Text("Unable to load trailer")
                .font(DSTypography.h3SwiftUI(weight: .semibold))
                .foregroundColor(.white)

            Text("Please check your internet connection and try again.")
                .font(DSTypography.h5SwiftUI(weight: .regular))
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Retry") {
                hasError = false
                isLoading = true
                // TODO: Retry player after adding YouTubePlayerKit
                // youTubePlayer.update(source: .video(id: videoID))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(hex: "#12CDD9"))
            .foregroundColor(.white)
            .font(DSTypography.h4SwiftUI(weight: .medium))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct YouTubePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubePlayerView(
            videoID: "dQw4w9WgXcQ",
            title: "Sample Trailer"
        )
    }
}