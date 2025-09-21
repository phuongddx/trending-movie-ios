import SwiftUI

@available(iOS 15.0, *)
struct MovieDetailsView: View {
    @StateObject var viewModel: ObservableMovieDetailsViewModel
    @Environment(\.presentationMode) var presentationMode
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
        VStack(spacing: 0) {
            // Hero section
            if let movie = viewModel.movie {
                MovieDetailHero(
                    movie: movie,
                    posterImage: viewModel.posterImage,
                    onWatchlistTap: {
                        handleWatchlistTap(movie)
                    },
                    onFavoriteTap: {
                        handleFavoriteTap(movie)
                    },
                    onShareTap: {
                        handleShareTap(movie)
                    }
                )
            }

            // Tabs section
            if let movie = viewModel.movie {
                MovieDetailTabs(movie: movie)
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
@available(iOS 15.0, *)
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
            fetchDetailsMovieUseCase: container.fetchDetailsMovieUseCase(),
            posterImagesRepository: container.posterImagesRepository()
        )

        return NavigationView {
            MovieDetailsView(viewModel: viewModel)
        }
        .environmentObject(DSThemeManager.shared)
    }
}

