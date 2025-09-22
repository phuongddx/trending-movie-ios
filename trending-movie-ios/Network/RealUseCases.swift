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

        print("🌐 Fetching movie details for ID: \(movieId)")

        // Validate movie ID
        guard !movieId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("🔴 Empty movie ID provided")
            let error = NSError(domain: "MovieDetails", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "Invalid movie ID: empty"])
            completion(.failure(error))
            return nil
        }

        var movieDetail: TMDBMovieDetail?
        var videos: [Video]?
        var images: MovieImages?
        var credits: MovieCredits?
        var certification: String?
        var director: String?

        let dispatchGroup = DispatchGroup()
        var cancellables: [Cancellable?] = []
        var errors: [Error] = []

        // Fetch movie details
        dispatchGroup.enter()
        let detailsCancellable = networkService.request(
            .movieDetails(movieId: movieId),
            type: TMDBMovieDetail.self
        ) { result in
            switch result {
            case .success(let details):
                movieDetail = details
            case .failure(let error):
                errors.append(error)
            }
            dispatchGroup.leave()
        }
        cancellables.append(detailsCancellable)

        // Fetch videos
        dispatchGroup.enter()
        let videosCancellable = networkService.request(
            .movieVideos(movieId: movieId),
            type: TMDBVideosResponse.self
        ) { result in
            switch result {
            case .success(let response):
                videos = response.results.map { $0.toDomain() }
            case .failure:
                // Ignore video fetch errors
                break
            }
            dispatchGroup.leave()
        }
        cancellables.append(videosCancellable)

        // Fetch images
        dispatchGroup.enter()
        let imagesCancellable = networkService.request(
            .movieImages(movieId: movieId),
            type: TMDBImagesResponse.self
        ) { result in
            switch result {
            case .success(let response):
                let backdrops = response.backdrops.map { $0.toDomain() }
                let posters = response.posters.map { $0.toDomain() }
                images = MovieImages(backdrops: backdrops, posters: posters)
            case .failure:
                // Ignore image fetch errors
                break
            }
            dispatchGroup.leave()
        }
        cancellables.append(imagesCancellable)

        // Fetch credits
        dispatchGroup.enter()
        let creditsCancellable = networkService.request(
            .movieCredits(movieId: movieId),
            type: TMDBCreditsResponse.self
        ) { result in
            switch result {
            case .success(let response):
                let cast = response.cast.map { $0.toDomain() }
                let crew = response.crew.map { $0.toDomain() }
                credits = MovieCredits(cast: cast, crew: crew)
                // Extract director from crew
                director = response.crew.first(where: { $0.job == "Director" })?.name
            case .failure:
                // Ignore credits fetch errors
                break
            }
            dispatchGroup.leave()
        }
        cancellables.append(creditsCancellable)

        // Fetch release dates for certification
        dispatchGroup.enter()
        let releaseDatesCancellable = networkService.request(
            .movieReleaseDates(movieId: movieId),
            type: TMDBReleaseDatesResponse.self
        ) { result in
            switch result {
            case .success(let response):
                // Try to find US certification first, then any available certification
                let usRelease = response.results.first(where: { $0.iso31661 == "US" })
                certification = usRelease?.releaseDates.first?.certification
                    ?? response.results.first?.releaseDates.first?.certification
            case .failure:
                // Ignore certification fetch errors
                break
            }
            dispatchGroup.leave()
        }
        cancellables.append(releaseDatesCancellable)

        dispatchGroup.notify(queue: .main) {
            if let movieDetail = movieDetail {
                let movie = movieDetail.toDomain(
                    certification: certification,
                    director: director,
                    videos: videos,
                    images: images,
                    credits: credits
                )
                completion(.success(movie))
            } else if let error = errors.first {
                completion(.failure(error))
            } else {
                completion(.failure(NSError(domain: "MovieDetails", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch movie details"])))
            }
        }

        // Return a cancellable that cancels all requests
        return CombinedCancellable(cancellables: cancellables)
    }
}

// Helper class to combine multiple cancellables
final class CombinedCancellable: Cancellable {
    private let cancellables: [Cancellable?]

    init(cancellables: [Cancellable?]) {
        self.cancellables = cancellables
    }

    func cancel() {
        cancellables.forEach { $0?.cancel() }
    }
}

public final class RealPosterImagesRepository: PosterImagesRepository {
    private let baseImageURL = "https://image.tmdb.org/t/p/"

    public init() {}

    public func getImageURL(for imagePath: String, size: ImageSize = .large) -> URL? {
        guard !imagePath.isEmpty else { return nil }
        let fullPath = imagePath.hasPrefix("/") ? imagePath : "/\(imagePath)"
        return URL(string: "\(baseImageURL)\(size.rawValue)\(fullPath)")
    }
}
