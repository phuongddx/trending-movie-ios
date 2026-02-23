import SwiftUI

struct HomeView: View {
    private let container: AppContainer
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var storage = MovieStorage.shared
    @State private var searchText = ""
    @State private var selectedCategory = "All"

    init(container: AppContainer) {
        self.container = container
        self._viewModel = StateObject(wrappedValue: HomeViewModel(
            trendingMoviesUseCase: container.trendingMoviesUseCase(),
            popularMoviesUseCase: container.popularMoviesUseCase(),
            nowPlayingMoviesUseCase: container.nowPlayingMoviesUseCase(),
            topRatedMoviesUseCase: container.topRatedMoviesUseCase(),
            upcomingMoviesUseCase: container.upcomingMoviesUseCase()
        ))
    }

    var body: some View {
        NavigationView {
            ZStack {
                DSColors.backgroundSwiftUI
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // User Profile Header
                        UserProfileHeader(
                            userName: "Smith",
                            avatarImage: nil,
                            onWishlistTap: {
                                // Handle wishlist tap
                            }
                        )
                        .padding(.top, 60)

                        // Search Bar
                        DSSearchBar(
                            text: $searchText,
                            placeholder: "Search a title..",
                            onCommit: {
                                // Handle search
                            },
                            onFilterTap: {
                                // Handle filter tap
                            }
                        )
                        .padding(.horizontal, 24)

                        // Date subtitle
                        HStack {
                            Text("On March 2, 2022")
                                .font(DSTypography.h6SwiftUI(weight: .medium))
                                .foregroundColor(DSColors.secondaryTextSwiftUI)
                            Spacer()
                        }
                        .padding(.horizontal, 56)

                        // Hero Carousel
                        if viewModel.isLoading && viewModel.heroMovies.isEmpty {
                            DSHeroCarouselSkeleton()
                        } else {
                            HeroCarousel(
                                movies: viewModel.heroMovies,
                                onTap: { movie in
                                    viewModel.selectMovie(movie)
                                },
                                onWatchlistTap: nil,
                                onFavoriteTap: nil
                            )
                        }

                        // Categories Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Categories")
                                .font(DSTypography.h4SwiftUI(weight: .semibold))
                                .foregroundColor(DSColors.primaryTextSwiftUI)
                                .padding(.horizontal, 24)

                            CategoryTabs(selectedCategory: $selectedCategory)
                                .padding(.horizontal, 24)
                        }

                        // Most Popular Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Most popular")
                                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                                    .foregroundColor(DSColors.primaryTextSwiftUI)

                                Spacer()

                                Button("See All") {
                                    // Handle see all
                                }
                                .font(DSTypography.h5SwiftUI(weight: .medium))
                                .foregroundColor(Color(hex: "#12CDD9"))
                            }
                            .padding(.horizontal, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    if viewModel.isLoading && viewModel.popularMovies.isEmpty {
                                        ForEach(0..<6, id: \.self) { _ in
                                            MovieCardSkeleton(style: .standard)
                                        }
                                    } else {
                                        ForEach(viewModel.popularMovies.prefix(6), id: \.id) { movie in
                                            MovieCard(
                                                movie: movie,
                                                style: .standard,
                                                onTap: { viewModel.selectMovie(movie) }
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }

                        // MARK: - Now Playing Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Now Playing")
                                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                                    .foregroundColor(DSColors.primaryTextSwiftUI)

                                Spacer()

                                Button("See All") { }
                                    .font(DSTypography.h5SwiftUI(weight: .medium))
                                    .foregroundColor(Color(hex: "#12CDD9"))
                            }
                            .padding(.horizontal, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    if viewModel.isLoading && viewModel.nowPlayingMovies.isEmpty {
                                        ForEach(0..<6, id: \.self) { _ in
                                            MovieCardSkeleton(style: .standard)
                                        }
                                    } else {
                                        ForEach(viewModel.nowPlayingMovies.prefix(6), id: \.id) { movie in
                                            MovieCard(
                                                movie: movie,
                                                style: .standard,
                                                onTap: { viewModel.selectMovie(movie) }
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }

                        // MARK: - Top Rated Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Top Rated")
                                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                                    .foregroundColor(DSColors.primaryTextSwiftUI)

                                Spacer()

                                Button("See All") { }
                                    .font(DSTypography.h5SwiftUI(weight: .medium))
                                    .foregroundColor(Color(hex: "#12CDD9"))
                            }
                            .padding(.horizontal, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    if viewModel.isLoading && viewModel.topRatedMovies.isEmpty {
                                        ForEach(0..<6, id: \.self) { _ in
                                            MovieCardSkeleton(style: .standard)
                                        }
                                    } else {
                                        ForEach(viewModel.topRatedMovies.prefix(6), id: \.id) { movie in
                                            MovieCard(
                                                movie: movie,
                                                style: .standard,
                                                onTap: { viewModel.selectMovie(movie) }
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }

                        // MARK: - Coming Soon Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Coming Soon")
                                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                                    .foregroundColor(DSColors.primaryTextSwiftUI)

                                Spacer()

                                Button("See All") { }
                                    .font(DSTypography.h5SwiftUI(weight: .medium))
                                    .foregroundColor(Color(hex: "#12CDD9"))
                            }
                            .padding(.horizontal, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    if viewModel.isLoading && viewModel.upcomingMovies.isEmpty {
                                        ForEach(0..<6, id: \.self) { _ in
                                            MovieCardSkeleton(style: .standard)
                                        }
                                    } else {
                                        ForEach(viewModel.upcomingMovies.prefix(6), id: \.id) { movie in
                                            MovieCard(
                                                movie: movie,
                                                style: .standard,
                                                onTap: { viewModel.selectMovie(movie) }
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }

                        // Add bottom padding for tab bar
                        Color.clear
                            .frame(height: 40)
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }

                // Hidden NavigationLink for programmatic navigation
                if let selectedMovie = viewModel.selectedMovie {
                    NavigationLink(
                        destination: MovieDetailsView(
                            viewModel: container.observableMovieDetailsViewModel(movie: selectedMovie.movie)
                        ),
                        isActive: Binding(
                            get: { viewModel.selectedMovie != nil },
                            set: { if !$0 { viewModel.selectedMovie = nil } }
                        )
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .ignoresSafeArea(.container, edges: .top)
            .onAppear {
                viewModel.loadData()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
    private var loadingTasks: [String: Cancellable] = [:]

    struct MovieWrapper: Identifiable {
        let id = UUID()
        let movie: Movie
    }

    nonisolated init(trendingMoviesUseCase: TrendingMoviesUseCaseProtocol,
                    popularMoviesUseCase: PopularMoviesUseCaseProtocol,
                    nowPlayingMoviesUseCase: NowPlayingMoviesUseCaseProtocol,
                    topRatedMoviesUseCase: TopRatedMoviesUseCaseProtocol,
                    upcomingMoviesUseCase: UpcomingMoviesUseCaseProtocol) {
        self.trendingMoviesUseCase = trendingMoviesUseCase
        self.popularMoviesUseCase = popularMoviesUseCase
        self.nowPlayingMoviesUseCase = nowPlayingMoviesUseCase
        self.topRatedMoviesUseCase = topRatedMoviesUseCase
        self.upcomingMoviesUseCase = upcomingMoviesUseCase
    }

    func loadData() {
        guard !isLoading else { return }
        isLoading = true

        // Load trending movies for hero carousel
        loadTrendingMovies()

        // Load other categories
        loadPopularMovies()
        loadNowPlayingMovies()
        loadTopRatedMovies()
        loadUpcomingMovies()
    }

    /// Refresh all data (for pull-to-refresh)
    func refresh() async {
        // Clear existing tasks
        loadingTasks.values.forEach { $0.cancel() }
        loadingTasks.removeAll()

        // Reset state
        isLoading = true

        // Small delay for UX (feels more natural)
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        } catch {
            // Task was cancelled, reset loading state and return
            isLoading = false
            return
        }

        // Reload all data
        loadTrendingMovies()
        loadPopularMovies()
        loadNowPlayingMovies()
        loadTopRatedMovies()
        loadUpcomingMovies()
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
                        break
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
            MoviesListItemViewModel(movie: movie)
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
            id: self.id, // Now using the actual TMDB movie ID
            title: self.title,
            posterPath: self.posterImagePath,
            overview: self.overview,
            releaseDate: nil, // Not available in this view model
            voteAverage: self.voteAverage
        )
    }
}
