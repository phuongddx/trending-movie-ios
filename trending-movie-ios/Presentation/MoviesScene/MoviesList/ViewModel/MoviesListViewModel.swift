//
//  MoviesListItemViewModel.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation

protocol ConnectionError: Error {
    var isInternetConnectionError: Bool { get }
}

extension Error {
    var isInternetConnectionError: Bool {
        guard let error = self as? ConnectionError, error.isInternetConnectionError else {
            return false
        }
        return true
    }
}

protocol MoviesListViewModelActionsProtocol {
    var showMovieDetails: ((Movie) -> Void)? { get }
    var showMovieQueriesSuggestions: ((@escaping (_ didSelect: MovieQuery) -> Void) -> Void)? { get }
    var closeMovieQueriesSuggestions: (() -> Void)? { get }
    var showMoviesSearchResult: ((MoviesListViewModel) -> Void)? { get }
}

struct TrendingMoviesListViewModelActions: MoviesListViewModelActionsProtocol {
    var closeMovieQueriesSuggestions: (() -> Void)?
    var showMovieDetails: ((Movie) -> Void)?
    var showMovieQueriesSuggestions: ((@escaping (_ didSelect: MovieQuery) -> Void) -> Void)?
    var showMoviesSearchResult: ((any MoviesListViewModel) -> Void)?

    init(closeMovieQueriesSuggestions: (() -> Void)? = nil,
         showMovieDetails: ((Movie) -> Void)? = nil,
         showMovieQueriesSuggestions: ((@escaping (_: MovieQuery) -> Void) -> Void)? = nil,
         showMoviesSearchResult: ((any MoviesListViewModel) -> Void)? = nil) {
        self.closeMovieQueriesSuggestions = closeMovieQueriesSuggestions
        self.showMovieDetails = showMovieDetails
        self.showMovieQueriesSuggestions = showMovieQueriesSuggestions
        self.showMoviesSearchResult = showMoviesSearchResult
    }
}

enum MoviesListViewModelLoading {
    case fullScreen
    case nextPage
}

protocol MoviesListViewModelInput {
    func viewDidLoad()
    func didLoadNextPage()
    func didSearch(query: String)
    func didCancelSearch()
    func showQueriesSuggestions()
    func closeQueriesSuggestions()
    func didSelectItem(at index: Int)
}

protocol MoviesListViewModelOutput {
    var items: Observable<[MoviesListItemViewModel]> { get }
    var loading: Observable<MoviesListViewModelLoading?> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    var screenTitle: String { get }
    var errorTitle: String { get }
    var searchBarPlaceholder: String { get }
    var moviesListHeaderTitle: String { get }

    func numberOfRows() -> Int
    func viewModelItem(at indexPath: IndexPath) -> MoviesListItemViewModel?
    func shouldShowEmptyView() -> Bool
}

protocol MoviesListViewModel: MoviesListViewModelInput,
                              MoviesListViewModelOutput {}

enum MoviesListDisplayViewType {
    case trending
    case search
}

final class DefaultMoviesListViewModel: MoviesListViewModel {

    private let searchMoviesUseCase: SearchMoviesUseCase
    private let trendingMoviesUseCase: TrendingMoviesUseCase
    private let actions: MoviesListViewModelActionsProtocol?

    var currentPage: Int = 0
    var totalPageCount: Int = 1
    var hasMorePages: Bool { currentPage < totalPageCount }
    var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }

//    private var pages: [MoviesPage] = []
    private var trendingPages = [MoviesPage]()
    private var searchResultPages = [MoviesPage]()

    private var moviesLoadTask: Cancellable? {
        willSet {
            moviesLoadTask?.cancel()
        }
    }
    private let mainQueue: DispatchQueueType

    // MARK: - OUTPUT

    let items: Observable<[MoviesListItemViewModel]> = Observable([])
    let loading: Observable<MoviesListViewModelLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    let screenTitle = NSLocalizedString("Movies", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    let searchBarPlaceholder = NSLocalizedString("Search Movies", comment: "")

    // MARK: - Init
    
    init(searchMoviesUseCase: SearchMoviesUseCase,
         trendingMoviesUseCase: TrendingMoviesUseCase,
         actions: MoviesListViewModelActionsProtocol? = nil,
         mainQueue: DispatchQueueType = DispatchQueue.main) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.trendingMoviesUseCase = trendingMoviesUseCase
        self.actions = actions
        self.mainQueue = mainQueue
    }

    // MARK: - Private

    private var moviesListViewType: MoviesListDisplayViewType = .trending {
        didSet {
            switch moviesListViewType {
            case .trending:
                items.value = trendingPages.movies.map(MoviesListItemViewModel.init)
            case .search:
                items.value = searchResultPages.movies.map(MoviesListItemViewModel.init)
            }
        }
    }

    private func appendPage(_ moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages

        let isTrending = moviesListViewType == .trending

        if isTrending {
            trendingPages = trendingPages.filter { $0.page != moviesPage.page } + [moviesPage]
        } else {
            searchResultPages = searchResultPages.filter { $0.page != moviesPage.page } + [moviesPage]
        }
        items.value = (isTrending ? trendingPages : searchResultPages).movies.map(MoviesListItemViewModel.init)
    }

    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        searchResultPages.removeAll() // Only reset searchResult
        items.value.removeAll()
    }

    private func load(movieQuery: MovieQuery, loading: MoviesListViewModelLoading) {
        self.loading.value = loading
        query.value = movieQuery.query

        moviesLoadTask = searchMoviesUseCase.execute(
            requestValue: SearchMoviesUseCaseRequestValue(query: movieQuery, page: nextPage),
            cached: { [weak self] page in
                self?.mainQueue.async {
                    self?.appendPage(page)
                }
            }, completion: { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let page):
                        self?.appendPage(page)
                    case .failure(let error):
                        self?.handle(error: error)
                    }
                    self?.loading.value = .none
                }
        })
    }

    func loadTrendingList(loading: MoviesListViewModelLoading = .fullScreen) {
        self.loading.value = loading
        let requestDto = DefaultMoviesRequestDTO(page: nextPage)
        moviesLoadTask = trendingMoviesUseCase.execute(
            requestable: requestDto,
            cached: { [weak self] page in
                self?.mainQueue.async {
                    self?.appendPage(page)
                }
            }, completion: { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let page):
                        self?.appendPage(page)
                    case .failure(let error):
                        self?.handle(error: error)
                    }
                    self?.loading.value = .none
                }
            })
    }

    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading movies", comment: "")
    }

    private func update(movieQuery: MovieQuery) {
        resetPages()
        load(movieQuery: movieQuery, loading: .fullScreen)
    }

    var moviesListHeaderTitle: String {
        moviesListViewType == .trending ? "Trending Result" : "Search Result"
    }

    func numberOfRows() -> Int {
        shouldShowEmptyView() ? 1 :
        items.value.count
    }

    func viewModelItem(at indexPath: IndexPath) -> MoviesListItemViewModel? {
        items.value[safe: indexPath.row]
    }

    func shouldShowEmptyView() -> Bool {
        if moviesListViewType == .trending {
            return false
        }
        return items.value.isEmpty
    }
}

// MARK: - INPUT. View event methods

extension DefaultMoviesListViewModel {

    func viewDidLoad() {
        loadTrendingList()
    }

    func didLoadNextPage() {
        guard hasMorePages,
              loading.value == .none else { return }
        switch moviesListViewType {
        case .trending:
            loadTrendingList(loading: .nextPage)
        case .search:
            load(movieQuery: MovieQuery(query: query.value),
                 loading: .nextPage)
        }
    }

    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(movieQuery: MovieQuery(query: query))
        moviesListViewType = .search
    }

    func didCancelSearch() {
        moviesLoadTask?.cancel()
        moviesListViewType = .trending
        loadTrendingList()
    }

    func showQueriesSuggestions() {
        actions?.showMovieQueriesSuggestions?(update(movieQuery:))
    }

    func closeQueriesSuggestions() {
        actions?.closeMovieQueriesSuggestions?()
    }

    func didSelectItem(at index: Int) {
        var pages: [MoviesPage]
        switch moviesListViewType {
        case .trending:
            pages = trendingPages
        case .search:
            pages = searchResultPages
        }
        actions?.showMovieDetails?(pages.movies[index])
    }
}

// MARK: - Private

private extension Array where Element == MoviesPage {
    var movies: [Movie] { flatMap { $0.movies } }
}
