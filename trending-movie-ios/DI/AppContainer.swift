import Foundation
import Factory
import Moya

final class AppContainer: SharedContainer {
    static let shared = AppContainer()
    var manager = ContainerManager()
}

extension AppContainer {

    // MARK: - Configuration
    var appConfiguration: Factory<AppConfig> {
        self { AppConfig() }.singleton
    }

    // MARK: - Network
    var tmdbNetworkService: Factory<TMDBNetworkService> {
        self {
            TMDBNetworkService()
        }.singleton
    }

    // MARK: - Repositories
    var posterImagesRepository: Factory<PosterImagesRepository> {
        self {
            RealPosterImagesRepository()
        }.singleton
    }

    // MARK: - Use Cases
    var searchMoviesUseCase: Factory<SearchMoviesUseCaseProtocol> {
        self {
            RealSearchMoviesUseCase(networkService: self.tmdbNetworkService())
        }
    }

    var trendingMoviesUseCase: Factory<TrendingMoviesUseCaseProtocol> {
        self {
            RealTrendingMoviesUseCase(networkService: self.tmdbNetworkService())
        }
    }

    var popularMoviesUseCase: Factory<PopularMoviesUseCaseProtocol> {
        self {
            RealPopularMoviesUseCase(networkService: self.tmdbNetworkService())
        }
    }

    var nowPlayingMoviesUseCase: Factory<NowPlayingMoviesUseCaseProtocol> {
        self {
            RealNowPlayingMoviesUseCase(networkService: self.tmdbNetworkService())
        }
    }

    var topRatedMoviesUseCase: Factory<TopRatedMoviesUseCaseProtocol> {
        self {
            RealTopRatedMoviesUseCase(networkService: self.tmdbNetworkService())
        }
    }

    var upcomingMoviesUseCase: Factory<UpcomingMoviesUseCaseProtocol> {
        self {
            RealUpcomingMoviesUseCase(networkService: self.tmdbNetworkService())
        }
    }

    var fetchDetailsMovieUseCase: Factory<FetchDetailsMovieUseCaseProtocol> {
        self {
            RealFetchDetailsMovieUseCase(networkService: self.tmdbNetworkService())
        }
    }

    var discoverMoviesUseCase: Factory<DiscoverMoviesUseCaseProtocol> {
        self {
            RealDiscoverMoviesUseCase(networkService: self.tmdbNetworkService())
        }
    }
}

// MARK: - AppConfiguration

public struct AppConfig {
    lazy var apiKey: String = {
        return "bbc142c0087fef1df2ad2e3230101822"
    }()

    lazy var apiBaseURL: String = {
        return "https://api.themoviedb.org/3/"
    }()

    lazy var imagesBaseURL: String = {
        return "https://image.tmdb.org/t/p/"
    }()
}
