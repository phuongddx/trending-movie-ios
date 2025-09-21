import Foundation

public typealias MoviesPageResult = (Result<MoviesPage, Error>) -> Void
public typealias MovieDetailsResult = (Result<MovieDetails, Error>) -> Void

public protocol MoviesRepository {
    @discardableResult
    func fetchMoviesList(query: MovieQuery,
                         page: Int,
                         cached: @escaping (MoviesPage) -> Void,
                         completion: @escaping MoviesPageResult) -> Cancellable?

    @discardableResult
    func fetchTrendingMoviesList(request: MoviesRequest,
                                 cached: @escaping (MoviesPage) -> Void,
                                 completion: @escaping MoviesPageResult) -> Cancellable?

    @discardableResult
    func fetchDetailsMovie(of movieId: Movie.Identifier,
                           completion: @escaping MovieDetailsResult) -> Cancellable?
}