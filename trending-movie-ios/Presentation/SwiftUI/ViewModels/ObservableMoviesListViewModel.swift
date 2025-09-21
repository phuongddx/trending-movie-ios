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
}

@MainActor
class ObservableMoviesListViewModel: ObservableObject {

    @Published var movies: [MoviesListItemViewModel] = []
    @Published var loading: MoviesListViewModelLoading? = nil
    @Published var searchQuery: String = ""
    @Published var error: String = ""
    @Published var isShowingError: Bool = false

    private let searchMoviesUseCase: SearchMoviesUseCaseProtocol
    private let trendingMoviesUseCase: TrendingMoviesUseCaseProtocol
    private let posterImagesRepository: PosterImagesRepository
    private let onMovieSelected: ((Movie) -> Void)?

    private var currentPage: Int = 0
    private var totalPageCount: Int = 1
    private var hasMorePages: Bool { currentPage < totalPageCount }
    private var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }

    private var trendingPages = [MoviesPage]()
    private var searchResultPages = [MoviesPage]()
    private var moviesLoadTask: Cancellable?
    private var searchCancellable: AnyCancellable?

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
        moviesListViewType == .trending ? "Trending Result" : "Search Result"
    }
    var shouldShowEmptyView: Bool {
        moviesListViewType == .search && movies.isEmpty
    }

    nonisolated init(searchMoviesUseCase: SearchMoviesUseCaseProtocol,
         trendingMoviesUseCase: TrendingMoviesUseCaseProtocol,
         posterImagesRepository: PosterImagesRepository,
         onMovieSelected: ((Movie) -> Void)? = nil) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.trendingMoviesUseCase = trendingMoviesUseCase
        self.posterImagesRepository = posterImagesRepository
        self.onMovieSelected = onMovieSelected

        Task { @MainActor in
            setupSearchDebouncing()
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

    // MARK: - Public Methods
    func viewDidLoad() {
        loadTrendingMovies()
    }

    func loadNextPage() {
        guard hasMorePages, loading == nil else { return }

        switch moviesListViewType {
        case .trending:
            loadTrendingMovies(loading: .nextPage)
        case .search:
            performSearch(query: searchQuery, loading: .nextPage)
        }
    }

    func refreshMovies() async {
        resetPages()
        switch moviesListViewType {
        case .trending:
            loadTrendingMovies()
        case .search:
            if !searchQuery.isEmpty {
                performSearch(query: searchQuery)
            }
        }
    }

    func selectMovie(at index: Int) {
        let pages = moviesListViewType == .trending ? trendingPages : searchResultPages
        let allMovies = pages.flatMap { $0.movies }

        guard index < allMovies.count else { return }
        onMovieSelected?(allMovies[index])
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

    // MARK: - Private Methods
    private func appendPage(_ moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages

        if moviesListViewType == .trending {
            trendingPages = trendingPages.filter { $0.page != moviesPage.page } + [moviesPage]
        } else {
            searchResultPages = searchResultPages.filter { $0.page != moviesPage.page } + [moviesPage]
        }

        updateMoviesList()
    }

    private func updateMoviesList() {
        let pages = moviesListViewType == .trending ? trendingPages : searchResultPages
        movies = pages.flatMap { $0.movies }.map {
            MoviesListItemViewModel(movie: $0, posterImagesRepository: posterImagesRepository)
        }
    }

    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        trendingPages.removeAll()
        searchResultPages.removeAll()
        movies.removeAll()
    }

    private func resetSearchPages() {
        if moviesListViewType == .search {
            currentPage = 0
            totalPageCount = 1
            searchResultPages.removeAll()
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