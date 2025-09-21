import Foundation
import Moya
import MoviesDomain

public enum MoviesAPI {
    case searchMovies(query: String, page: Int)
    case trendingMovies(timeWindow: String, page: Int)
    case popularMovies(page: Int)
    case nowPlayingMovies(page: Int)
    case topRatedMovies(page: Int)
    case upcomingMovies(page: Int)
    case movieDetails(movieId: String)
    case movieCredits(movieId: String)
    case similarMovies(movieId: String, page: Int)
    case posterImage(path: String)
}

extension MoviesAPI: TargetType {
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
        case .searchMovies:
            return "search/movie"
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
        case .movieDetails(let movieId):
            return "movie/\(movieId)"
        case .movieCredits(let movieId):
            return "movie/\(movieId)/credits"
        case .similarMovies(let movieId, _):
            return "movie/\(movieId)/similar"
        case .posterImage(let path):
            return "w500\(path)"
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var task: Moya.Task {
        switch self {
        case .searchMovies(let query, let page):
            return .requestParameters(
                parameters: [
                    "query": query,
                    "page": page
                ],
                encoding: URLEncoding.queryString
            )
        case .trendingMovies(_, let page),
             .popularMovies(let page),
             .nowPlayingMovies(let page),
             .topRatedMovies(let page),
             .upcomingMovies(let page),
             .similarMovies(_, let page):
            return .requestParameters(
                parameters: ["page": page],
                encoding: URLEncoding.queryString
            )
        case .movieDetails,
             .movieCredits,
             .posterImage:
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