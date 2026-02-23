import Foundation
import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [MoviesListItemViewModel] = []
    @Published var suggestions: [String] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var selectedMovie: HomeViewModel.MovieWrapper?
    @Published var searchHistory: [String] = []
    @Published var trendingMovies: [MoviesListItemViewModel] = []

    private let searchMoviesUseCase: SearchMoviesUseCaseProtocol
    private let historyStore: SearchHistoryStore
    private let trendingUseCase: TrendingMoviesUseCaseProtocol?
    @StateObject private var storage = MovieStorage.shared

    private var searchCancellable: AnyCancellable?
    private var currentSearchTask: Cancellable?
    private(set) var currentPage = 1
    private var totalPages = 1
    private var hasMorePages: Bool { currentPage < totalPages }

    // MARK: - Configuration
    private enum Configuration {
        static let debounceInterval: Int = 300 // milliseconds (optimized from 500ms)
    }

    // MARK: - Performance Tracking (Debug Only)
    #if DEBUG
    private var searchStartTime: Date?
    #endif

    let popularSearches = [
        "Avengers", "Spider-Man", "Batman", "Star Wars",
        "Marvel", "Disney", "Horror", "Comedy",
        "Action", "Drama", "Thriller", "Romance"
    ]

    nonisolated init(
        searchMoviesUseCase: SearchMoviesUseCaseProtocol,
        historyStore: SearchHistoryStore = SearchHistoryStore(),
        trendingUseCase: TrendingMoviesUseCaseProtocol? = nil
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.historyStore = historyStore
        self.trendingUseCase = trendingUseCase

        Task { @MainActor in
            self.searchHistory = historyStore.recentSearches
            setupSearchDebouncing()
            loadTrendingMovies()
        }
    }

    nonisolated deinit {
        Task { @MainActor in
            cancelAllOperations()
        }
    }

    // MARK: - Cleanup
    func cancelAllOperations() {
        currentSearchTask?.cancel()
        searchCancellable?.cancel()
    }

    // MARK: - Memory Management
    func handleMemoryWarning() {
        // Clear cached data if needed
        searchResults.removeAll()
        trendingMovies.removeAll()
        clearSuggestions()
    }

    private func setupSearchDebouncing() {
        searchCancellable = $searchQuery
            .debounce(for: .milliseconds(Configuration.debounceInterval), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if query.isEmpty {
                    self?.clearSearch()
                } else {
                    self?.updateSuggestions(for: query)
                }
            }
    }

    // MARK: - Accessibility
    func announceSearchResults(count: Int) {
        let message = count == 0
            ? "No movies found"
            : "\(count) movies found"
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    func performSearch() {
        guard !searchQuery.isEmpty else { return }

        #if DEBUG
        searchStartTime = Date()
        #endif

        // Add to history
        historyStore.add(searchQuery)
        searchHistory = historyStore.recentSearches

        clearSuggestions()
        isLoading = true
        currentPage = 1
        searchResults.removeAll()

        executeSearch(page: currentPage)
    }

    // MARK: - Search History Management
    func removeFromHistory(_ query: String) {
        historyStore.remove(query)
        searchHistory = historyStore.recentSearches
    }

    func clearSearchHistory() {
        historyStore.clear()
        searchHistory = []
    }

    // MARK: - Trending Movies
    func loadTrendingMovies() {
        guard let trendingUseCase = trendingUseCase else { return }

        trendingUseCase.execute(
            request: MoviesRequest(page: 1),
            cached: { [weak self] moviesPage in
                Task { @MainActor in
                    self?.trendingMovies = moviesPage.movies.map {
                        MoviesListItemViewModel(movie: $0)
                    }
                }
            },
            completion: { _ in }
        )
    }

    // MARK: - Alternative Suggestions
    func getAlternativeSuggestions(for query: String) -> [String] {
        let lowercase = query.lowercased()

        // Find similar popular searches
        let similar = popularSearches.filter { search in
            search.lowercased().contains(lowercase) ||
            lowercase.contains(search.lowercased())
        }

        // Add some default suggestions if not enough
        let defaults = ["Marvel", "Comedy", "Action", "2024"]
        let combined = similar + defaults.filter { !similar.contains($0) }

        return Array(combined.prefix(5))
    }

    func loadNextPage() {
        guard hasMorePages && !isLoadingMore else { return }

        isLoadingMore = true
        currentPage += 1
        executeSearch(page: currentPage)
    }

    func selectMovie(_ movieViewModel: MoviesListItemViewModel) {
        selectedMovie = HomeViewModel.MovieWrapper(movie: movieViewModel.movie)
    }

    func toggleWatchlist(_ movieViewModel: MoviesListItemViewModel) {
        let movie = movieViewModel.movie
        if storage.isInWatchlist(movie) {
            storage.removeFromWatchlist(movie)
        } else {
            storage.addToWatchlist(movie)
        }
    }

    func toggleFavorite(_ movieViewModel: MoviesListItemViewModel) {
        let movie = movieViewModel.movie
        if storage.isFavorite(movie) {
            storage.removeFromFavorites(movie)
        } else {
            storage.addToFavorites(movie)
        }
    }

    private func executeSearch(page: Int) {
        let movieQuery = MovieQuery(query: searchQuery)
        let requestValue = SearchMoviesUseCaseRequestValue(query: movieQuery, page: page)

        currentSearchTask?.cancel()
        currentSearchTask = searchMoviesUseCase.execute(
            requestValue: requestValue,
            cached: { [weak self] moviesPage in
                Task { @MainActor in
                    self?.handleSearchResult(moviesPage, isLoadingMore: page > 1)
                }
            },
            completion: { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success(let moviesPage):
                        self?.handleSearchResult(moviesPage, isLoadingMore: page > 1)
                    case .failure:
                        self?.handleSearchError()
                    }
                }
            }
        )
    }

    private func handleSearchResult(_ moviesPage: MoviesPage, isLoadingMore: Bool) {
        totalPages = moviesPage.totalPages

        let newMovieViewModels = moviesPage.movies.map { movie in
            MoviesListItemViewModel(movie: movie)
        }

        if isLoadingMore {
            searchResults.append(contentsOf: newMovieViewModels)
            self.isLoadingMore = false
        } else {
            searchResults = newMovieViewModels
            isLoading = false
            // Announce results for accessibility
            announceSearchResults(count: searchResults.count)

            #if DEBUG
            logSearchPerformance()
            #endif
        }
    }

    #if DEBUG
    private func logSearchPerformance() {
        if let start = searchStartTime {
            let duration = Date().timeIntervalSince(start)
            print("[Performance] Search completed in \(String(format: "%.2f", duration * 1000))ms")
        }
    }
    #endif

    private func handleSearchError() {
        isLoading = false
        isLoadingMore = false
        // Could show error message here
    }

    private func clearSearch() {
        searchResults.removeAll()
        clearSuggestions()
        currentSearchTask?.cancel()
    }

    private func updateSuggestions(for query: String) {
        // In a real app, this would call an API for search suggestions
        // For now, we'll filter from popular searches
        let filtered = popularSearches.filter { search in
            search.localizedCaseInsensitiveContains(query)
        }

        suggestions = Array(filtered.prefix(5))
    }

    private func clearSuggestions() {
        suggestions.removeAll()
    }
}