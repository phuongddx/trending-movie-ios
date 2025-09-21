import Foundation

public struct SearchMoviesUseCaseRequestValue {
    public let query: MovieQuery
    public let page: Int

    public init(query: MovieQuery, page: Int) {
        self.query = query
        self.page = page
    }
}

public protocol SearchMoviesUseCaseProtocol {
    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

public final class SearchMoviesUseCase: SearchMoviesUseCaseProtocol {
    private let moviesRepository: MoviesRepository

    public init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }

    public func execute(requestValue: SearchMoviesUseCaseRequestValue,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        moviesRepository.fetchMoviesList(query: requestValue.query,
                                         page: requestValue.page,
                                         cached: cached,
                                         completion: completion)
    }
}