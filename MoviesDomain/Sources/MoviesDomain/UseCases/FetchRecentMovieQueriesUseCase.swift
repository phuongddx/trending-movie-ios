import Foundation

public struct FetchRecentMovieQueriesUseCaseRequestValue {
    public let maxCount: Int

    public init(maxCount: Int) {
        self.maxCount = maxCount
    }
}

public protocol FetchRecentMovieQueriesUseCaseProtocol {
    func execute(requestValue: FetchRecentMovieQueriesUseCaseRequestValue,
                 completion: @escaping (Result<[MovieQuery], Error>) -> Void) -> Cancellable?
}

public final class FetchRecentMovieQueriesUseCase: FetchRecentMovieQueriesUseCaseProtocol {
    private let moviesQueriesRepository: MoviesQueriesRepository

    public init(moviesQueriesRepository: MoviesQueriesRepository) {
        self.moviesQueriesRepository = moviesQueriesRepository
    }

    public func execute(requestValue: FetchRecentMovieQueriesUseCaseRequestValue,
                        completion: @escaping (Result<[MovieQuery], Error>) -> Void) -> Cancellable? {
        moviesQueriesRepository.fetchRecentsQueries(maxCount: requestValue.maxCount,
                                                    completion: completion)
        return nil
    }
}