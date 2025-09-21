import Foundation

public protocol NowPlayingMoviesUseCaseProtocol {
    func execute(page: Int,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

public final class NowPlayingMoviesUseCase: NowPlayingMoviesUseCaseProtocol {
    private let moviesRepository: MoviesRepository

    public init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }

    public func execute(page: Int,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        moviesRepository.fetchNowPlayingMoviesList(page: page,
                                                   cached: cached,
                                                   completion: completion)
    }
}