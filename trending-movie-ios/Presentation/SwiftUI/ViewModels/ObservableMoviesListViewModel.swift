import Foundation
import SwiftUI
import Combine

enum MoviesListViewModelLoading {
    case fullScreen
    case nextPage
}

enum MoviesListDisplayViewType {
    case trending
    case search
    case discover
}

@MainActor
class ObservableMoviesListViewModel: ObservableObject {

    @Published var movies: [MoviesListItemViewModel] = []
    @Published var loading: MoviesListViewModelLoading? = nil
    @Published var searchQuery: String = ""
    @Published var error: String = ""
    @Published var isShowingError: Bool = false

    // MARK: - Filter & View Mode Properties
    @Published var activeFilters: MovieFilters = .default
    @AppStorage("moviesViewMode") var viewMode: ViewMode = .list

    private let searchMoviesUseCase: SearchMoviesUseCaseProtocol
    private let trendingMoviesUseCase: TrendingMoviesUseCaseProtocol
    private let discoverMoviesUseCase: DiscoverMoviesUseCaseProtocol
    private let onMovieSelected: ((Movie) -> Void)?

    private var currentPage: Int = 0
    private var totalPageCount: Int = 1
    private var hasMorePages: Bool { currentPage < totalPageCount }
    private var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }

    private var trendingPages = [MoviesPage]()
    private var searchResultPages = [MoviesPage]()
    private var discoverResultPages = [MoviesPage]()
    private var moviesLoadTask: Cancellable?
    private var searchCancellable: AnyCancellable?
    private var filterCancellable: AnyCancellable?

    private var moviesListViewType: MoviesListDisplayViewType = .trending {
        didSet {
            updateMoviesList()
        }
    }

    // MARK: - Computed Properties
    var screenTitle: String { NSLocalizedString("Movies", comment: "") }
    var errorTitle: String { NSLocalizedString("Error", comment: "") }
    var searchBarPlaceholder: String { NSLocalizedString("Search Movies", comment: "") }
    var moviesListHeaderTitle: String {
        switch moviesListViewType {
        case .trending: return "Trending Result"
        case .search: return "Search Result"
        case .discover: return "Filtered Result"
        }
    }
    var shouldShowEmptyView: Bool {
        (moviesListViewType == .search || moviesListViewType == .discover) && movies.isEmpty && loading == nil
    }

    nonisolated init(
        searchMoviesUseCase: SearchMoviesUseCaseProtocol,
        trendingMoviesUseCase: TrendingMoviesUseCaseProtocol,
        discoverMoviesUseCase: DiscoverMoviesUseCaseProtocol,
        onMovieSelected: ((Movie) -> Void)? = nil
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.trendingMoviesUseCase = trendingMoviesUseCase
        self.discoverMoviesUseCase = discoverMoviesUseCase
        self.onMovieSelected = onMovieSelected

        Task { @MainActor in
            setupSearchDebouncing()
            setupFilterObservation()
        }
    }

    private func setupSearchDebouncing() {
        searchCancellable = $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if query.isEmpty {
                    self?.cancelSearch()
                } else {
                    self?.performSearch(query: query)
                }
            }
    }

    private func setupFilterObservation() {
        filterCancellable = $activeFilters
            .removeDuplicates()
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.resetPages()
                    self?.loadMovies()
                }
            }
    }

    // MARK: - Public Methods
    func viewDidLoad() {
        loadMovies()
    }

    func loadNextPage() {
        guard hasMorePages, loading == nil else { return }

        switch moviesListViewType {
        case .trending:
            loadTrendingMovies(loading: .nextPage)
        case .search:
            performSearch(query: searchQuery, loading: .nextPage)
        case .discover:
            loadDiscoverMovies(loading: .nextPage)
        }
    }

    func refreshMovies() async {
        resetPages()
        loadMovies()
    }

    func selectMovie(at index: Int) {
        let pages: [MoviesPage]
        switch moviesListViewType {
        case .trending: pages = trendingPages
        case .search: pages = searchResultPages
        case .discover: pages = discoverResultPages
        }
        let allMovies = pages.flatMap { $0.movies }

        guard index < allMovies.count else { return }
        onMovieSelected?(allMovies[index])
    }

    func removeFilter(_ chip: FilterChip) {
        let currentYear = Calendar.current.component(.year, from: Date())
        switch chip.category {
        case .sort:
            activeFilters.sortBy = .popularity
        case .genre:
            if let genreId = Int(chip.id.replacingOccurrences(of: "genre_", with: "")) {
                activeFilters.genres.remove(genreId)
            }
        case .rating:
            activeFilters.minimumRating = 0
        case .year:
            activeFilters.yearRange = 1990...currentYear
        }
    }

    // MARK: - Load Movies
    private func loadMovies(loading: MoviesListViewModelLoading = .fullScreen) {
        self.loading = loading

        // Cancel pending request
        moviesLoadTask?.cancel()

        if !searchQuery.isEmpty {
            // Search mode
            performSearch(query: searchQuery, loading: loading)
        } else if activeFilters.isActive {
            // Filtered mode - use discover
            moviesListViewType = .discover
            loadDiscoverMovies(loading: loading)
        } else {
            // Default - trending
            moviesListViewType = .trending
            loadTrendingMovies(loading: loading)
        }
    }

    private func performSearch(query: String, loading: MoviesListViewModelLoading = .fullScreen) {
        guard !query.isEmpty else { return }

        if loading == .fullScreen {
            resetSearchPages()
        }

        self.loading = loading
        moviesListViewType = .search

        let movieQuery = MovieQuery(query: query)

        moviesLoadTask?.cancel()
        moviesLoadTask = searchMoviesUseCase.execute(
            requestValue: SearchMoviesUseCaseRequestValue(query: movieQuery, page: nextPage),
            cached: { [weak self] page in
                Task { @MainActor in
                    self?.appendPage(page)
                }
            },
            completion: { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success(let page):
                        self?.appendPage(page)
                    case .failure(let error):
                        self?.handleError(error)
                    }
                    self?.loading = nil
                }
            }
        )
    }

    private func cancelSearch() {
        moviesLoadTask?.cancel()
        moviesListViewType = .trending
        loadTrendingMovies()
    }

    private func loadTrendingMovies(loading: MoviesListViewModelLoading = .fullScreen) {
        self.loading = loading

        let request = MoviesRequest(page: nextPage, timeWindow: "day")

        moviesLoadTask?.cancel()
        moviesLoadTask = trendingMoviesUseCase.execute(
            request: request,
            cached: { [weak self] page in
                Task { @MainActor in
                    self?.appendPage(page)
                }
            },
            completion: { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success(let page):
                        self?.appendPage(page)
                    case .failure(let error):
                        self?.handleError(error)
                    }
                    self?.loading = nil
                }
            }
        )
    }

    private func loadDiscoverMovies(loading: MoviesListViewModelLoading = .fullScreen) {
        self.loading = loading
        moviesListViewType = .discover

        moviesLoadTask?.cancel()
        moviesLoadTask = discoverMoviesUseCase.execute(
            filters: activeFilters,
            page: nextPage,
            cached: { [weak self] page in
                Task { @MainActor in
                    self?.appendPage(page)
                }
            },
            completion: { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success(let page):
                        self?.appendPage(page)
                    case .failure(let error):
                        self?.handleError(error)
                    }
                    self?.loading = nil
                }
            }
        )
    }

    // MARK: - Private Methods
    private func appendPage(_ moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages

        switch moviesListViewType {
        case .trending:
            trendingPages = trendingPages.filter { $0.page != moviesPage.page } + [moviesPage]
        case .search:
            searchResultPages = searchResultPages.filter { $0.page != moviesPage.page } + [moviesPage]
        case .discover:
            discoverResultPages = discoverResultPages.filter { $0.page != moviesPage.page } + [moviesPage]
        }

        updateMoviesList()
    }

    private func updateMoviesList() {
        let pages: [MoviesPage]
        switch moviesListViewType {
        case .trending: pages = trendingPages
        case .search: pages = searchResultPages
        case .discover: pages = discoverResultPages
        }
        movies = pages.flatMap { $0.movies }.map {
            MoviesListItemViewModel(movie: $0)
        }
    }

    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        trendingPages.removeAll()
        searchResultPages.removeAll()
        discoverResultPages.removeAll()
        movies.removeAll()
    }

    private func resetSearchPages() {
        if moviesListViewType == .search {
            currentPage = 0
            totalPageCount = 1
            searchResultPages.removeAll()
        }
    }

    private func resetDiscoverPages() {
        if moviesListViewType == .discover {
            currentPage = 0
            totalPageCount = 1
            discoverResultPages.removeAll()
        }
    }

    private func handleError(_ error: Error) {
        self.error = NSLocalizedString("Failed loading movies", comment: "")
        self.isShowingError = true
    }
}

// MARK: - Array Extension
private extension Array where Element == MoviesPage {
    var movies: [Movie] { flatMap { $0.movies } }
}