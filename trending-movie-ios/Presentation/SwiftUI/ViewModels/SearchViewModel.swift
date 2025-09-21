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

    private let searchMoviesUseCase: SearchMoviesUseCaseProtocol
    private let posterImagesRepository: PosterImagesRepository
    @StateObject private var storage = MovieStorage.shared

    private var searchCancellable: AnyCancellable?
    private var currentSearchTask: Cancellable?
    private var currentPage = 1
    private var totalPages = 1
    private var hasMorePages: Bool { currentPage < totalPages }

    let popularSearches = [
        "Avengers", "Spider-Man", "Batman", "Star Wars",
        "Marvel", "Disney", "Horror", "Comedy",
        "Action", "Drama", "Thriller", "Romance"
    ]

    nonisolated init(searchMoviesUseCase: SearchMoviesUseCaseProtocol,
                    posterImagesRepository: PosterImagesRepository) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.posterImagesRepository = posterImagesRepository

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
                    self?.clearSearch()
                } else {
                    self?.updateSuggestions(for: query)
                }
            }
    }

    func performSearch() {
        guard !searchQuery.isEmpty else { return }

        clearSuggestions()
        isLoading = true
        currentPage = 1
        searchResults.removeAll()

        executeSearch(page: currentPage)
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
            MoviesListItemViewModel(movie: movie, posterImagesRepository: posterImagesRepository)
        }

        if isLoadingMore {
            searchResults.append(contentsOf: newMovieViewModels)
            self.isLoadingMore = false
        } else {
            searchResults = newMovieViewModels
            isLoading = false
        }
    }

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