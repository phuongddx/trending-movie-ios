import Foundation

public protocol FetchDetailsMovieUseCaseProtocol {
    func execute(with movieId: Movie.Identifier,
                 completion: @escaping MovieDetailsResult) -> Cancellable?
}

public final class FetchDetailsMovieUseCase: FetchDetailsMovieUseCaseProtocol {
    private let moviesRepository: MoviesRepository

    public init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }

    public func execute(with movieId: Movie.Identifier,
                        completion: @escaping MovieDetailsResult) -> Cancellable? {
        moviesRepository.fetchDetailsMovie(of: movieId,
                                           completion: completion)
    }
}