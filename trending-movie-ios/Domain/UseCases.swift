import Foundation

// MARK: - Cancellable Protocol
public protocol Cancellable {
    func cancel()
}

// MARK: - Use Case Protocols

public struct SearchMoviesUseCaseRequestValue {
    public let query: MovieQuery
    public let page: Int

    public init(query: MovieQuery, page: Int) {
        self.query = query
        self.page = page
    }
}

public struct MoviesRequest: Equatable {
    public let page: Int
    public let query: String?
    public let timeWindow: String?

    public init(page: Int, query: String? = nil, timeWindow: String? = nil) {
        self.page = page
        self.query = query
        self.timeWindow = timeWindow
    }
}

public typealias MoviesPageResult = (Result<MoviesPage, Error>) -> Void

public protocol SearchMoviesUseCaseProtocol {
    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

public protocol TrendingMoviesUseCaseProtocol {
    func execute(request: MoviesRequest,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

public protocol FetchDetailsMovieUseCaseProtocol {
    func execute(with movieId: Movie.Identifier,
                 completion: @escaping (Result<Movie, Error>) -> Void) -> Cancellable?
}

// MARK: - Repository Protocols

public typealias ImagesResult = (Result<Data, Error>) -> Void

public protocol PosterImagesRepository {
    func fetchImage(with imagePath: String,
                    completion: @escaping ImagesResult) -> Cancellable?
}

// MARK: - Mock Implementations

public final class MockSearchMoviesUseCase: SearchMoviesUseCaseProtocol {
    public init() {}

    public func execute(requestValue: SearchMoviesUseCaseRequestValue,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        // Mock implementation
        let mockMovies = [
            Movie(id: "1", title: "Mock Movie 1", posterPath: nil, overview: "Mock overview", releaseDate: Date(), voteAverage: "8.5"),
            Movie(id: "2", title: "Mock Movie 2", posterPath: nil, overview: "Mock overview 2", releaseDate: Date(), voteAverage: "7.5")
        ]
        let mockPage = MoviesPage(page: 1, totalPages: 1, movies: mockMovies)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(mockPage))
        }

        return nil
    }
}

public final class MockTrendingMoviesUseCase: TrendingMoviesUseCaseProtocol {
    public init() {}

    public func execute(request: MoviesRequest,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        // Mock implementation
        let mockMovies = [
            Movie(id: "1", title: "Trending Movie 1", posterPath: nil, overview: "Trending overview", releaseDate: Date(), voteAverage: "9.0"),
            Movie(id: "2", title: "Trending Movie 2", posterPath: nil, overview: "Trending overview 2", releaseDate: Date(), voteAverage: "8.8")
        ]
        let mockPage = MoviesPage(page: request.page, totalPages: 2, movies: mockMovies)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(mockPage))
        }

        return nil
    }
}

public final class MockFetchDetailsMovieUseCase: FetchDetailsMovieUseCaseProtocol {
    public init() {}

    public func execute(with movieId: Movie.Identifier,
                        completion: @escaping (Result<Movie, Error>) -> Void) -> Cancellable? {
        let mockMovie = Movie(id: movieId, title: "Movie Details", posterPath: nil, overview: "Detailed overview", releaseDate: Date(), voteAverage: "8.0")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(mockMovie))
        }

        return nil
    }
}

public final class MockPosterImagesRepository: PosterImagesRepository {
    public init() {}

    public func fetchImage(with imagePath: String,
                          completion: @escaping ImagesResult) -> Cancellable? {
        // Mock empty image data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(.success(Data()))
        }

        return nil
    }
}