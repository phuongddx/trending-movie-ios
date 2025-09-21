import Foundation

// MARK: - Real API Use Cases

public final class RealTrendingMoviesUseCase: TrendingMoviesUseCaseProtocol {
    private let networkService: TMDBNetworkService

    public init(networkService: TMDBNetworkService) {
        self.networkService = networkService
    }

    public func execute(request: MoviesRequest,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        let timeWindow = request.timeWindow ?? "day"

        return networkService.request(
            .trendingMovies(timeWindow: timeWindow, page: request.page),
            type: TMDBMoviesResponse.self
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

public final class RealPopularMoviesUseCase: PopularMoviesUseCaseProtocol {
    private let networkService: TMDBNetworkService

    public init(networkService: TMDBNetworkService) {
        self.networkService = networkService
    }

    public func execute(page: Int,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        return networkService.request(
            .popularMovies(page: page),
            type: TMDBMoviesResponse.self
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

public final class RealNowPlayingMoviesUseCase: NowPlayingMoviesUseCaseProtocol {
    private let networkService: TMDBNetworkService

    public init(networkService: TMDBNetworkService) {
        self.networkService = networkService
    }

    public func execute(page: Int,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        return networkService.request(
            .nowPlayingMovies(page: page),
            type: TMDBMoviesResponse.self
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

public final class RealTopRatedMoviesUseCase: TopRatedMoviesUseCaseProtocol {
    private let networkService: TMDBNetworkService

    public init(networkService: TMDBNetworkService) {
        self.networkService = networkService
    }

    public func execute(page: Int,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        return networkService.request(
            .topRatedMovies(page: page),
            type: TMDBMoviesResponse.self
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

public final class RealUpcomingMoviesUseCase: UpcomingMoviesUseCaseProtocol {
    private let networkService: TMDBNetworkService

    public init(networkService: TMDBNetworkService) {
        self.networkService = networkService
    }

    public func execute(page: Int,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        return networkService.request(
            .upcomingMovies(page: page),
            type: TMDBMoviesResponse.self
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

public final class RealSearchMoviesUseCase: SearchMoviesUseCaseProtocol {
    private let networkService: TMDBNetworkService

    public init(networkService: TMDBNetworkService) {
        self.networkService = networkService
    }

    public func execute(requestValue: SearchMoviesUseCaseRequestValue,
                        cached: @escaping (MoviesPage) -> Void,
                        completion: @escaping MoviesPageResult) -> Cancellable? {
        return networkService.request(
            .searchMovies(query: requestValue.query.query, page: requestValue.page),
            type: TMDBMoviesResponse.self
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

public final class RealFetchDetailsMovieUseCase: FetchDetailsMovieUseCaseProtocol {
    private let networkService: TMDBNetworkService

    public init(networkService: TMDBNetworkService) {
        self.networkService = networkService
    }

    public func execute(with movieId: Movie.Identifier,
                        completion: @escaping (Result<Movie, Error>) -> Void) -> Cancellable? {
        return networkService.request(
            .movieDetails(movieId: movieId),
            type: TMDBMovie.self
        ) { result in
            switch result {
            case .success(let tmdbMovie):
                completion(.success(tmdbMovie.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

public final class RealPosterImagesRepository: PosterImagesRepository {
    private let networkService: TMDBNetworkService

    public init(networkService: TMDBNetworkService) {
        self.networkService = networkService
    }

    public func fetchImage(with imagePath: String,
                          completion: @escaping ImagesResult) -> Cancellable? {
        return networkService.requestData(.posterImage(path: imagePath)) { result in
            completion(result)
        }
    }
}