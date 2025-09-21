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
    func fetchPopularMoviesList(page: Int,
                                cached: @escaping (MoviesPage) -> Void,
                                completion: @escaping MoviesPageResult) -> Cancellable?

    @discardableResult
    func fetchNowPlayingMoviesList(page: Int,
                                   cached: @escaping (MoviesPage) -> Void,
                                   completion: @escaping MoviesPageResult) -> Cancellable?

    @discardableResult
    func fetchTopRatedMoviesList(page: Int,
                                 cached: @escaping (MoviesPage) -> Void,
                                 completion: @escaping MoviesPageResult) -> Cancellable?

    @discardableResult
    func fetchUpcomingMoviesList(page: Int,
                                 cached: @escaping (MoviesPage) -> Void,
                                 completion: @escaping MoviesPageResult) -> Cancellable?

    @discardableResult
    func fetchDetailsMovie(of movieId: Movie.Identifier,
                           completion: @escaping MovieDetailsResult) -> Cancellable?
}