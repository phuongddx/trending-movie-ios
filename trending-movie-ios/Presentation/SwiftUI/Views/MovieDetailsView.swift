import SwiftUI

struct MovieDetailsView: View {
    @StateObject var viewModel: ObservableMovieDetailsViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var storage = MovieStorage.shared

    init(viewModel: ObservableMovieDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            DSColors.backgroundSwiftUI
                .ignoresSafeArea()

            if viewModel.loading == .fullScreen {
                loadingView
            } else {
                contentView
            }
        }
        .navigationBarHidden(true)
        .refreshable {
            await viewModel.refreshDetails()
        }
        .alert(viewModel.error, isPresented: $viewModel.isShowingError) {
            Button("OK") {
                viewModel.isShowingError = false
            }
        }
        .sheet(isPresented: $viewModel.isShowingTrailer) {
            if let videoID = viewModel.trailerVideoID {
                YouTubePlayerView(
                    videoID: videoID,
                    title: viewModel.trailerTitle
                )
            }
        }
        .onAppear {
            viewModel.viewDidLoad()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 24) {
            DSHeroCarouselSkeleton()

            ForEach(0..<3, id: \.self) { _ in
                Rectangle()
                    .fill(DSColors.surfaceSwiftUI)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            Spacer()
        }
        .padding(20)
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let movie = viewModel.movie {
                    // Backdrop Hero with overlay
                    ZStack {
                        MovieBackdropHero(movie: movie, height: 500)

                        // Header overlay
                        VStack {
                            MovieDetailsHeader(
                                title: movie.title ?? "",
                                isInWatchlist: storage.isInWatchlist(movie),
                                onBackTap: {
                                    dismiss()
                                },
                                onWishlistTap: {
                                    handleWatchlistTap(movie)
                                }
                            )

                            Spacer()
                        }
                    }
                    .frame(height: 500)

                    // Movie Metadata Bar
                    MovieMetadataBar(movie: movie)
                        .padding(.top, 24)

                    // Action Buttons
                    MovieActionButtons(
                        hasTrailer: movie.hasTrailer,
                        onTrailerTap: {
                            viewModel.playTrailer()
                        },
                        onDownloadTap: {
                            viewModel.downloadMovie()
                        },
                        onShareTap: {
                            viewModel.shareMovie()
                        }
                    )
                    .padding(.top, 24)

                    // Story Line Section
                    StoryLineSection(movie: movie)
                        .padding(.top, 24)

                    // Cast and Crew Section
                    CastCrewSection(movie: movie)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                }
            }
        }
    }

    private func handleWatchlistTap(_ movie: Movie) {
        if storage.isInWatchlist(movie) {
            storage.removeFromWatchlist(movie)
        } else {
            storage.addToWatchlist(movie)
        }
    }

    private func handleFavoriteTap(_ movie: Movie) {
        if storage.isFavorite(movie) {
            storage.removeFromFavorites(movie)
        } else {
            storage.addToFavorites(movie)
        }
    }

    private func handleShareTap(_ movie: Movie) {
        // Implement sharing functionality
        let shareText = "Check out \(movie.title ?? "this movie")!"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

// MARK: - Preview
struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let mockMovie = Movie(
            id: "1",
            title: "Sample Movie Title That Is Very Long",
            posterPath: nil,
            overview: "This is a sample movie overview that provides detailed information about the plot, characters, and setting of the movie. It gives viewers an idea of what to expect when watching this film.",
            releaseDate: Date(),
            voteAverage: "8.5"
        )

        let container = AppContainer.shared
        let viewModel = ObservableMovieDetailsViewModel(
            movie: mockMovie,
            fetchDetailsMovieUseCase: container.fetchDetailsMovieUseCase()
        )

        return NavigationView {
            MovieDetailsView(viewModel: viewModel)
        }
        .environmentObject(DSThemeManager.shared)
    }
}

