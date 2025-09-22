import SwiftUI
import YouTubePlayerKit

struct MovieTrailerPlayerView: View {
    let videoID: String
    let title: String
    @Environment(\.dismiss) var dismiss
    @State private var youTubePlayer: YouTubePlayer
    @State private var isLoading = true
    @State private var hasError = false

    init(videoID: String, title: String) {
        self.videoID = videoID
        self.title = title
        self._youTubePlayer = State(initialValue: YouTubePlayer(
            source: .video(id: videoID)
        ))
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
                        playerView
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
            // Player is initialized with source, no need to update
        }
    }

    private var playerView: some View {
        YouTubePlayerKit.YouTubePlayerView(youTubePlayer)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    if isLoading {
                        Color.black.opacity(0.8)

                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)

                            Text("Loading trailer...")
                                .font(DSTypography.h5SwiftUI(weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
            )
            .onReceive(youTubePlayer.statePublisher) { state in
                switch state {
                case .idle:
                    isLoading = true
                    hasError = false
                case .ready:
                    isLoading = false
                    hasError = false
                case .error:
                    isLoading = false
                    hasError = true
                default:
                    isLoading = false
                }
            }
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
                // Recreate player instance for retry
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

struct MovieTrailerPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MovieTrailerPlayerView(
            videoID: "dQw4w9WgXcQ",
            title: "Sample Trailer"
        )
    }
}
