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

    // MARK: - Repositories
    var posterImagesRepository: Factory<PosterImagesRepository> {
        self { MockPosterImagesRepository() }.singleton
    }

    // MARK: - Use Cases
    var searchMoviesUseCase: Factory<SearchMoviesUseCaseProtocol> {
        self { MockSearchMoviesUseCase() }
    }

    var trendingMoviesUseCase: Factory<TrendingMoviesUseCaseProtocol> {
        self { MockTrendingMoviesUseCase() }
    }

    var fetchDetailsMovieUseCase: Factory<FetchDetailsMovieUseCaseProtocol> {
        self { MockFetchDetailsMovieUseCase() }
    }
}

// MARK: - AppConfiguration

public struct AppConfig {
    lazy var apiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else {
            return "mock_api_key" // fallback for compilation
        }
        return apiKey
    }()

    lazy var apiBaseURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as? String else {
            return "https://api.themoviedb.org/3/" // fallback
        }
        return apiBaseURL
    }()

    lazy var imagesBaseURL: String = {
        guard let imageBaseURL = Bundle.main.object(forInfoDictionaryKey: "ImageBaseURL") as? String else {
            return "https://image.tmdb.org/t/p/" // fallback
        }
        return imageBaseURL
    }()
}
