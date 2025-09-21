import Foundation
import Moya

public final class TMDBNetworkService {
    private let provider: MoyaProvider<TMDBTarget>

    public init() {
        #if DEBUG
        let networkLogger = NetworkLoggerPlugin(configuration: .init(
            formatter: .init(
                requestData: { data in
                    return String(decoding: data, as: UTF8.self)
                },
                responseData: { data in
                    return String(decoding: data, as: UTF8.self)
                }
            ),
            output: { target, items in
                // Print custom TMDB request info
                print("🌐 TMDB API Request:")
                print("Method: \(target.method.rawValue)")
                print("URL: \(target.baseURL.appendingPathComponent(target.path))")

                // Print curl-like command
                var curlCommand = "curl -X \(target.method.rawValue)"

                // Add headers
                if let headers = target.headers {
                    for (key, value) in headers {
                        curlCommand += " -H '\(key): \(value)'"
                    }
                }

                // Add URL with parameters
                let fullURL = target.baseURL.appendingPathComponent(target.path)
                if case .requestParameters(let parameters, _) = target.task {
                    var urlComponents = URLComponents(url: fullURL, resolvingAgainstBaseURL: false)
                    urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                    if let finalURL = urlComponents?.url {
                        curlCommand += " '\(finalURL.absoluteString)'"
                    }
                } else {
                    curlCommand += " '\(fullURL.absoluteString)'"
                }

                print("Curl: \(curlCommand)")

                // Print response items
                for item in items {
                    print("📡 TMDB Response: \(item)")
                }
                print("---")
            },
            logOptions: [.requestBody, .requestHeaders, .requestMethod, .successResponseBody, .errorResponseBody]
        ))

        self.provider = MoyaProvider<TMDBTarget>(plugins: [networkLogger])
        #else
        self.provider = MoyaProvider<TMDBTarget>()
        #endif
    }

    public func request<T: Decodable>(_ target: TMDBTarget,
                                     type: T.Type,
                                     completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? {
        let cancellableToken = provider.request(target) { result in
            switch result {
            case .success(let response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let decoded = try JSONDecoder().decode(T.self, from: filteredResponse.data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return DefaultCancellable(cancellableToken)
    }

    public func requestData(_ target: TMDBTarget,
                           completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        let cancellableToken = provider.request(target) { result in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return DefaultCancellable(cancellableToken)
    }
}

public enum TMDBTarget {
    case trendingMovies(timeWindow: String, page: Int)
    case popularMovies(page: Int)
    case nowPlayingMovies(page: Int)
    case topRatedMovies(page: Int)
    case upcomingMovies(page: Int)
    case searchMovies(query: String, page: Int)
    case movieDetails(movieId: String)
    case posterImage(path: String)
}

extension TMDBTarget: TargetType {
    public var baseURL: URL {
        switch self {
        case .posterImage:
            return URL(string: "https://image.tmdb.org/t/p/")!
        default:
            return URL(string: "https://api.themoviedb.org/3/")!
        }
    }

    public var path: String {
        switch self {
        case .trendingMovies(let timeWindow, _):
            return "trending/movie/\(timeWindow)"
        case .popularMovies:
            return "movie/popular"
        case .nowPlayingMovies:
            return "movie/now_playing"
        case .topRatedMovies:
            return "movie/top_rated"
        case .upcomingMovies:
            return "movie/upcoming"
        case .searchMovies:
            return "search/movie"
        case .movieDetails(let movieId):
            return "movie/\(movieId)"
        case .posterImage(let path):
            return "w500\(path)"
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var task: Moya.Task {
        switch self {
        case .trendingMovies(_, let page),
             .popularMovies(let page),
             .nowPlayingMovies(let page),
             .topRatedMovies(let page),
             .upcomingMovies(let page):
            return .requestParameters(
                parameters: [
                    "api_key": "bbc142c0087fef1df2ad2e3230101822",
                    "page": page
                ],
                encoding: URLEncoding.queryString
            )
        case .searchMovies(let query, let page):
            return .requestParameters(
                parameters: [
                    "api_key": "bbc142c0087fef1df2ad2e3230101822",
                    "query": query,
                    "page": page
                ],
                encoding: URLEncoding.queryString
            )
        case .movieDetails:
            return .requestParameters(
                parameters: [
                    "api_key": "bbc142c0087fef1df2ad2e3230101822"
                ],
                encoding: URLEncoding.queryString
            )
        case .posterImage:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        switch self {
        case .posterImage:
            return nil
        default:
            return [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        }
    }

    public var sampleData: Data {
        return Data()
    }
}

final class DefaultCancellable: Cancellable {
    private let moyaCancellable: Moya.Cancellable

    init(_ moyaCancellable: Moya.Cancellable) {
        self.moyaCancellable = moyaCancellable
    }

    func cancel() {
        moyaCancellable.cancel()
    }
}