import Foundation

protocol MoviesListViewModelActionsProtocol {
    var showMovieDetails: ((Movie) -> Void)? { get }
}

struct TrendingMoviesListViewModelActions: MoviesListViewModelActionsProtocol {
    var showMovieDetails: ((Movie) -> Void)?
}