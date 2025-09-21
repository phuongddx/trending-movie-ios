import Foundation

public protocol UpcomingMoviesUseCaseProtocol {
    func execute(page: Int,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

public final class UpcomingMoviesUseCase: UpcomingMoviesUseCaseProtocol {
    private let moviesRepository: MoviesRepository

    public init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }

    public func execute(page: Int,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        moviesRepository.fetchUpcomingMoviesList(page: page,
                                                 cached: cached,
                                                 completion: completion)
    }
}