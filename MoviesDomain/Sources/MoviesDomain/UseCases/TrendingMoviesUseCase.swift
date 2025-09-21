import Foundation

public protocol TrendingMoviesUseCaseProtocol {
    func execute(request: MoviesRequest,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

public final class TrendingMoviesUseCase: TrendingMoviesUseCaseProtocol {
    private let moviesRepository: MoviesRepository

    public init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }

    public func execute(request: MoviesRequest,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        moviesRepository.fetchTrendingMoviesList(request: request,
                                                 cached: cached,
                                                 completion: completion)
    }
}