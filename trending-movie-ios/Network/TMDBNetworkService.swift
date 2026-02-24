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

//                // Print response items
//                for item in items {
//                    print("📡 TMDB Response: \(item)")
//                }
                print("---")
            },
            logOptions: [.errorResponseBody]
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
                    guard 200...299 ~= response.statusCode else {
                        let errorMessage = String(data: response.data, encoding: .utf8) ?? "Unknown API error"
                        print("🔴 TMDB API Error (\(response.statusCode)): \(errorMessage)")
                        print("🔴 Request URL: \(target.baseURL.appendingPathComponent(target.path))")
                        let error = NSError(domain: "TMDB", code: response.statusCode,
                                           userInfo: [NSLocalizedDescriptionKey: "HTTP \(response.statusCode): \(errorMessage)"])
                        completion(.failure(error))
                        return
                    }

                    let decoded = try JSONDecoder().decode(T.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    print("🔴 JSON Decoding Error: \(error)")
                    print("🔴 Raw Response: \(String(data: response.data, encoding: .utf8) ?? "No data")")
                    print("🔴 Expected Type: \(T.self)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("🔴 Network Request Failed: \(error)")
                print("🔴 Target: \(target)")
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
    case movieVideos(movieId: String)
    case movieImages(movieId: String)
    case movieCredits(movieId: String)
    case movieReleaseDates(movieId: String)
    case watchProviders(movieId: String)
    case movieReviews(movieId: String, page: Int)
    case similarMovies(movieId: String, page: Int)
    case posterImage(path: String)
    case rateMovie(movieId: String, rating: Double)
    case discoverMovies(filters: MovieFilters, page: Int)
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
        case .movieVideos(let movieId):
            return "movie/\(movieId)/videos"
        case .movieImages(let movieId):
            return "movie/\(movieId)/images"
        case .movieCredits(let movieId):
            return "movie/\(movieId)/credits"
        case .movieReleaseDates(let movieId):
            return "movie/\(movieId)/release_dates"
        case .watchProviders(let movieId):
            return "movie/\(movieId)/watch/providers"
        case .movieReviews(let movieId, _):
            return "movie/\(movieId)/reviews"
        case .similarMovies(let movieId, _):
            return "movie/\(movieId)/similar"
        case .posterImage(let path):
            return "w500\(path)"
        case .rateMovie(let movieId, _):
            return "movie/\(movieId)/rating"
        case .discoverMovies:
            return "discover/movie"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .rateMovie:
            return .post
        default:
            return .get
        }
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
        case .movieDetails, .movieVideos, .movieImages, .movieCredits, .movieReleaseDates, .watchProviders:
            return .requestParameters(
                parameters: [
                    "api_key": "bbc142c0087fef1df2ad2e3230101822"
                ],
                encoding: URLEncoding.queryString
            )
        case .movieReviews(_, let page), .similarMovies(_, let page):
            return .requestParameters(
                parameters: [
                    "api_key": "bbc142c0087fef1df2ad2e3230101822",
                    "page": page
                ],
                encoding: URLEncoding.queryString
            )
        case .rateMovie(_, let rating):
            return .requestCompositeParameters(
                bodyParameters: ["value": rating],
                bodyEncoding: JSONEncoding.default,
                urlParameters: ["api_key": "bbc142c0087fef1df2ad2e3230101822"]
            )
        case .posterImage:
            return .requestPlain
        case .discoverMovies(let filters, let page):
            var params: [String: Any] = [
                "api_key": "bbc142c0087fef1df2ad2e3230101822",
                "page": page
            ]

            // Genres (comma-separated)
            if !filters.genres.isEmpty {
                params["with_genres"] = filters.genres.sorted().map(String.init).joined(separator: ",")
            }

            // Sort
            params["sort_by"] = filters.sortBy.rawValue

            // Minimum rating
            if filters.minimumRating > 0 {
                params["vote_average.gte"] = filters.minimumRating
            }

            // Year range
            let currentYear = Calendar.current.component(.year, from: Date())
            if filters.yearRange.lowerBound > 1990 {
                params["primary_release_date.gte"] = "\(filters.yearRange.lowerBound)-01-01"
            }
            if filters.yearRange.upperBound < currentYear {
                params["primary_release_date.lte"] = "\(filters.yearRange.upperBound)-12-31"
            }

            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
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
