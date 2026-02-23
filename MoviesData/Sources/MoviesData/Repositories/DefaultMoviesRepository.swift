import Foundation
import MoviesDomain
import Moya

public final class DefaultMoviesRepository: MoviesRepository {
    private let networkService: MoviesNetworkService
    private let cache: MoviesResponseStorage?

    public init(networkService: MoviesNetworkService, cache: MoviesResponseStorage? = nil) {
        self.networkService = networkService
        self.cache = cache
    }

    public func fetchMoviesList(query: MovieQuery,
                                page: Int,
                                cached: @escaping (MoviesPage) -> Void,
                                completion: @escaping MoviesPageResult) -> MoviesDomain.Cancellable? {
        // Check cache first
        if let cachedResponse = cache?.getResponse(for: RequestCacheKey(query: query.query, page: page)) {
            cached(cachedResponse)
        }

        // Fetch from network
        let cancellable = networkService.request(
            .searchMovies(query: query.query, page: page),
            type: MoviesResponseDTO.self
        ) { [weak self] result in
            switch result {
            case .success(let responseDTO):
                let moviesPage = responseDTO.toDomain()
                self?.cache?.save(response: moviesPage, for: RequestCacheKey(query: query.query, page: page))
                completion(.success(moviesPage))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return cancellable
    }

    public func fetchTrendingMoviesList(request: MoviesRequest,
                                        cached: @escaping (MoviesPage) -> Void,
                                        completion: @escaping MoviesPageResult) -> MoviesDomain.Cancellable? {
        let timeWindow = request.timeWindow ?? "day"

        // Check cache first
        if let cachedResponse = cache?.getResponse(for: RequestCacheKey(query: "trending_\(timeWindow)", page: request.page)) {
            cached(cachedResponse)
        }

        // Fetch from network
        let cancellable = networkService.request(
            .trendingMovies(timeWindow: timeWindow, page: request.page),
            type: MoviesResponseDTO.self
        ) { [weak self] result in
            switch result {
            case .success(let responseDTO):
                let moviesPage = responseDTO.toDomain()
                self?.cache?.save(response: moviesPage, for: RequestCacheKey(query: "trending_\(timeWindow)", page: request.page))
                completion(.success(moviesPage))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return cancellable
    }

    public func fetchPopularMoviesList(page: Int,
                                       cached: @escaping (MoviesPage) -> Void,
                                       completion: @escaping MoviesPageResult) -> MoviesDomain.Cancellable? {
        // Check cache first
        if let cachedResponse = cache?.getResponse(for: RequestCacheKey(query: "popular", page: page)) {
            cached(cachedResponse)
        }

        // Fetch from network
        let cancellable = networkService.request(
            .popularMovies(page: page),
            type: MoviesResponseDTO.self
        ) { [weak self] result in
            switch result {
            case .success(let responseDTO):
                let moviesPage = responseDTO.toDomain()
                self?.cache?.save(response: moviesPage, for: RequestCacheKey(query: "popular", page: page))
                completion(.success(moviesPage))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return cancellable
    }

    public func fetchNowPlayingMoviesList(page: Int,
                                          cached: @escaping (MoviesPage) -> Void,
                                          completion: @escaping MoviesPageResult) -> MoviesDomain.Cancellable? {
        // Check cache first
        if let cachedResponse = cache?.getResponse(for: RequestCacheKey(query: "now_playing", page: page)) {
            cached(cachedResponse)
        }

        // Fetch from network
        let cancellable = networkService.request(
            .nowPlayingMovies(page: page),
            type: MoviesResponseDTO.self
        ) { [weak self] result in
            switch result {
            case .success(let responseDTO):
                let moviesPage = responseDTO.toDomain()
                self?.cache?.save(response: moviesPage, for: RequestCacheKey(query: "now_playing", page: page))
                completion(.success(moviesPage))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return cancellable
    }

    public func fetchTopRatedMoviesList(page: Int,
                                        cached: @escaping (MoviesPage) -> Void,
                                        completion: @escaping MoviesPageResult) -> MoviesDomain.Cancellable? {
        // Check cache first
        if let cachedResponse = cache?.getResponse(for: RequestCacheKey(query: "top_rated", page: page)) {
            cached(cachedResponse)
        }

        // Fetch from network
        let cancellable = networkService.request(
            .topRatedMovies(page: page),
            type: MoviesResponseDTO.self
        ) { [weak self] result in
            switch result {
            case .success(let responseDTO):
                let moviesPage = responseDTO.toDomain()
                self?.cache?.save(response: moviesPage, for: RequestCacheKey(query: "top_rated", page: page))
                completion(.success(moviesPage))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return cancellable
    }

    public func fetchUpcomingMoviesList(page: Int,
                                        cached: @escaping (MoviesPage) -> Void,
                                        completion: @escaping MoviesPageResult) -> MoviesDomain.Cancellable? {
        // Check cache first
        if let cachedResponse = cache?.getResponse(for: RequestCacheKey(query: "upcoming", page: page)) {
            cached(cachedResponse)
        }

        // Fetch from network
        let cancellable = networkService.request(
            .upcomingMovies(page: page),
            type: MoviesResponseDTO.self
        ) { [weak self] result in
            switch result {
            case .success(let responseDTO):
                let moviesPage = responseDTO.toDomain()
                self?.cache?.save(response: moviesPage, for: RequestCacheKey(query: "upcoming", page: page))
                completion(.success(moviesPage))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return cancellable
    }

    public func fetchDetailsMovie(of movieId: Movie.Identifier,
                                 completion: @escaping MovieDetailsResult) -> MoviesDomain.Cancellable? {
        let cancellable = networkService.request(
            .movieDetails(movieId: movieId),
            type: MovieDetailsResponseDTO.self
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return cancellable
    }

    public func fetchWatchProviders(movieId: Movie.Identifier,
                                    completion: @escaping WatchProvidersResult) -> MoviesDomain.Cancellable? {
        let cancellable = networkService.request(
            .watchProviders(movieId: movieId),
            type: TMDBWatchProvidersResponse.self
        ) { result in
            switch result {
            case .success(let response):
                // Default to US region
                let usProviders = response.results["US"]?.toDomain()
                completion(.success(usProviders))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return cancellable
    }

    public func fetchReviews(movieId: Movie.Identifier,
                             page: Int,
                             completion: @escaping ReviewsResult) -> MoviesDomain.Cancellable? {
        let cancellable = networkService.request(
            .movieReviews(movieId: movieId, page: page),
            type: TMDBReviewsResponse.self
        ) { result in
            switch result {
            case .success(let response):
                let reviews = response.results.map { $0.toDomain() }
                completion(.success(reviews))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return cancellable
    }

    public func fetchSimilarMovies(movieId: Movie.Identifier,
                                   page: Int,
                                   completion: @escaping MoviesPageResult) -> MoviesDomain.Cancellable? {
        let cancellable = networkService.request(
            .similarMovies(movieId: movieId, page: page),
            type: TMDBMoviesResponse.self
        ) { result in
            switch result {
            case .success(let responseDTO):
                let moviesPage = responseDTO.toDomain()
                completion(.success(moviesPage))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return cancellable
    }
}

// MARK: - Cache Protocol

public protocol MoviesResponseStorage {
    func getResponse(for key: RequestCacheKey) -> MoviesPage?
    func save(response: MoviesPage, for key: RequestCacheKey)
}

public struct RequestCacheKey: Hashable {
    let query: String
    let page: Int

    public init(query: String, page: Int) {
        self.query = query
        self.page = page
    }
}