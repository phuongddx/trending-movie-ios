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

public protocol PopularMoviesUseCaseProtocol {
    func execute(page: Int,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

public protocol NowPlayingMoviesUseCaseProtocol {
    func execute(page: Int,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

public protocol TopRatedMoviesUseCaseProtocol {
    func execute(page: Int,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

public protocol UpcomingMoviesUseCaseProtocol {
    func execute(page: Int,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

public protocol DiscoverMoviesUseCaseProtocol {
    func execute(filters: MovieFilters,
                 page: Int,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

// MARK: - Repository Protocols

public enum ImageSize: String {
    case thumbnail = "w154"
    case small = "w185"
    case medium = "w342"
    case large = "w500"
    case extraLarge = "w780"
    case original = "original"
}

public protocol PosterImagesRepository {
    func getImageURL(for imagePath: String, size: ImageSize) -> URL?
}

