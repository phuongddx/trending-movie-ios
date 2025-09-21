import SwiftUI

@available(iOS 15.0, *)
struct HomeView: View {
    private let container: AppContainer
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var storage = MovieStorage.shared

    init(container: AppContainer) {
        self.container = container
        self._viewModel = StateObject(wrappedValue: HomeViewModel(
            trendingMoviesUseCase: container.trendingMoviesUseCase(),
            popularMoviesUseCase: container.popularMoviesUseCase(),
            nowPlayingMoviesUseCase: container.nowPlayingMoviesUseCase(),
            topRatedMoviesUseCase: container.topRatedMoviesUseCase(),
            upcomingMoviesUseCase: container.upcomingMoviesUseCase(),
            posterImagesRepository: container.posterImagesRepository()
        ))
    }

    var body: some View {
        NavigationView {
            ZStack {
                DSColors.backgroundSwiftUI
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.heroMovies.isEmpty {
                    loadingView
                } else {
                    contentView
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadData()
        }
    }

    private var loadingView: some View {
        ScrollView {
            VStack(spacing: 24) {
                DSHeroCarouselSkeleton()

                ForEach(0..<3, id: \.self) { _ in
                    DSCarouselSkeleton()
                }
            }
        }
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Carousel
                HeroCarousel(
                    movies: viewModel.heroMovies,
                    onTap: { movie in
                        viewModel.selectMovie(movie)
                    },
                    onWatchlistTap: { movie in
                        handleWatchlistTap(movie)
                    },
                    onFavoriteTap: { movie in
                        handleFavoriteTap(movie)
                    }
                )

                // Category Carousels
                VStack(spacing: 32) {
                    CategoryCarousel(
                        title: "Popular Movies",
                        movies: viewModel.popularMovies,
                        onTap: { movie in
                            viewModel.selectMovie(movie)
                        },
                        onSeeAll: nil
                    )

                    CategoryCarousel(
                        title: "Now Playing",
                        movies: viewModel.nowPlayingMovies,
                        onTap: { movie in
                            viewModel.selectMovie(movie)
                        },
                        onSeeAll: nil
                    )

                    CategoryCarousel(
                        title: "Top Rated",
                        movies: viewModel.topRatedMovies,
                        onTap: { movie in
                            viewModel.selectMovie(movie)
                        },
                        onSeeAll: nil
                    )

                    CategoryCarousel(
                        title: "Upcoming",
                        movies: viewModel.upcomingMovies,
                        onTap: { movie in
                            viewModel.selectMovie(movie)
                        },
                        onSeeAll: nil
                    )
                }
            }
        }
        .sheet(item: $viewModel.selectedMovie) { movie in
            MovieDetailsView(
                viewModel: container.observableMovieDetailsViewModel(movie: movie.movie)
            )
        }
    }

    private func handleWatchlistTap(_ movieViewModel: MoviesListItemViewModel) {
        let movie = movieViewModel.movie
        if storage.isInWatchlist(movie) {
            storage.removeFromWatchlist(movie)
        } else {
            storage.addToWatchlist(movie)
        }
    }

    private func handleFavoriteTap(_ movieViewModel: MoviesListItemViewModel) {
        let movie = movieViewModel.movie
        if storage.isFavorite(movie) {
            storage.removeFromFavorites(movie)
        } else {
            storage.addToFavorites(movie)
        }
    }
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var heroMovies: [MoviesListItemViewModel] = []
    @Published var popularMovies: [MoviesListItemViewModel] = []
    @Published var nowPlayingMovies: [MoviesListItemViewModel] = []
    @Published var topRatedMovies: [MoviesListItemViewModel] = []
    @Published var upcomingMovies: [MoviesListItemViewModel] = []
    @Published var isLoading = false
    @Published var selectedMovie: MovieWrapper?

    private let trendingMoviesUseCase: TrendingMoviesUseCaseProtocol
    private let popularMoviesUseCase: PopularMoviesUseCaseProtocol
    private let nowPlayingMoviesUseCase: NowPlayingMoviesUseCaseProtocol
    private let topRatedMoviesUseCase: TopRatedMoviesUseCaseProtocol
    private let upcomingMoviesUseCase: UpcomingMoviesUseCaseProtocol
    private let posterImagesRepository: PosterImagesRepository
    private var loadingTasks: [String: Cancellable] = [:]

    struct MovieWrapper: Identifiable {
        let id = UUID()
        let movie: Movie
    }

    nonisolated init(trendingMoviesUseCase: TrendingMoviesUseCaseProtocol,
                    popularMoviesUseCase: PopularMoviesUseCaseProtocol,
                    nowPlayingMoviesUseCase: NowPlayingMoviesUseCaseProtocol,
                    topRatedMoviesUseCase: TopRatedMoviesUseCaseProtocol,
                    upcomingMoviesUseCase: UpcomingMoviesUseCaseProtocol,
                    posterImagesRepository: PosterImagesRepository) {
        self.trendingMoviesUseCase = trendingMoviesUseCase
        self.popularMoviesUseCase = popularMoviesUseCase
        self.nowPlayingMoviesUseCase = nowPlayingMoviesUseCase
        self.topRatedMoviesUseCase = topRatedMoviesUseCase
        self.upcomingMoviesUseCase = upcomingMoviesUseCase
        self.posterImagesRepository = posterImagesRepository
    }

    func loadData() {
        guard !isLoading else { return }
        isLoading = true

        // Load trending movies for hero carousel
        loadTrendingMovies()

        // Load other categories (these would be separate endpoints in a real app)
        loadPopularMovies()
        loadNowPlayingMovies()
        loadTopRatedMovies()
        loadUpcomingMovies()
    }

    func refresh() async {
        heroMovies.removeAll()
        popularMovies.removeAll()
        nowPlayingMovies.removeAll()
        topRatedMovies.removeAll()
        upcomingMovies.removeAll()

        loadData()
    }

    func selectMovie(_ movieViewModel: MoviesListItemViewModel) {
        selectedMovie = MovieWrapper(movie: movieViewModel.movie)
    }

    private func loadTrendingMovies() {
        let request = MoviesRequest(page: 1, timeWindow: "day")

        loadingTasks["trending"] = trendingMoviesUseCase.execute(
            request: request,
            cached: { [weak self] page in
                Task { @MainActor in
                    self?.processMoviesPage(page, for: \.heroMovies)
                }
            },
            completion: { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success(let page):
                        self?.processMoviesPage(page, for: \.heroMovies)
                    case .failure:
                        break // Handle error if needed
                    }
                    self?.checkLoadingComplete()
                }
            }
        )
    }

    private func loadPopularMovies() {
        loadingTasks["popular"] = popularMoviesUseCase.execute(
            page: 1,
            cached: { [weak self] page in
                Task { @MainActor in
                    self?.processMoviesPage(page, for: \.popularMovies)
                }
            },
            completion: { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success(let page):
                        self?.processMoviesPage(page, for: \.popularMovies)
                    case .failure:
                        break
                    }
                    self?.checkLoadingComplete()
                }
            }
        )
    }

    private func loadNowPlayingMovies() {
        loadingTasks["nowPlaying"] = nowPlayingMoviesUseCase.execute(
            page: 1,
            cached: { [weak self] page in
                Task { @MainActor in
                    self?.processMoviesPage(page, for: \.nowPlayingMovies)
                }
            },
            completion: { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success(let page):
                        self?.processMoviesPage(page, for: \.nowPlayingMovies)
                    case .failure:
                        break
                    }
                    self?.checkLoadingComplete()
                }
            }
        )
    }

    private func loadTopRatedMovies() {
        loadingTasks["topRated"] = topRatedMoviesUseCase.execute(
            page: 1,
            cached: { [weak self] page in
                Task { @MainActor in
                    self?.processMoviesPage(page, for: \.topRatedMovies)
                }
            },
            completion: { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success(let page):
                        self?.processMoviesPage(page, for: \.topRatedMovies)
                    case .failure:
                        break
                    }
                    self?.checkLoadingComplete()
                }
            }
        )
    }

    private func loadUpcomingMovies() {
        loadingTasks["upcoming"] = upcomingMoviesUseCase.execute(
            page: 1,
            cached: { [weak self] page in
                Task { @MainActor in
                    self?.processMoviesPage(page, for: \.upcomingMovies)
                }
            },
            completion: { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success(let page):
                        self?.processMoviesPage(page, for: \.upcomingMovies)
                    case .failure:
                        break
                    }
                    self?.checkLoadingComplete()
                }
            }
        )
    }

    private func processMoviesPage(_ page: MoviesPage, for keyPath: WritableKeyPath<HomeViewModel, [MoviesListItemViewModel]>) {
        let movieViewModels = page.movies.map { movie in
            MoviesListItemViewModel(movie: movie, posterImagesRepository: posterImagesRepository)
        }

        switch keyPath {
        case \HomeViewModel.heroMovies:
            heroMovies = movieViewModels
        case \HomeViewModel.popularMovies:
            popularMovies = movieViewModels
        case \HomeViewModel.nowPlayingMovies:
            nowPlayingMovies = movieViewModels
        case \HomeViewModel.topRatedMovies:
            topRatedMovies = movieViewModels
        case \HomeViewModel.upcomingMovies:
            upcomingMovies = movieViewModels
        default:
            break
        }
    }

    private func checkLoadingComplete() {
        if loadingTasks.isEmpty {
            isLoading = false
        }
    }
}

// Extension to help with Movie conversion from MoviesListItemViewModel
extension MoviesListItemViewModel {
    var movie: Movie {
        return Movie(
            id: self.title, // Using title as ID for now
            title: self.title,
            posterPath: self.posterImagePath,
            overview: self.overview,
            releaseDate: nil, // Not available in this view model
            voteAverage: self.voteAverage
        )
    }
}