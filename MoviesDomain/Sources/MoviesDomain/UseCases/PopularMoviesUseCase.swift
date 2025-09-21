import Foundation

public protocol PopularMoviesUseCaseProtocol {
    func execute(page: Int,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

public final class PopularMoviesUseCase: PopularMoviesUseCaseProtocol {
    private let moviesRepository: MoviesRepository

    public init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }

    public func execute(page: Int,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        moviesRepository.fetchPopularMoviesList(page: page,
                                                cached: cached,
                                                completion: completion)
    }
}