import Foundation
import Moya
import MoviesDomain

public final class MoviesNetworkService {
    private let provider: MoyaProvider<MoviesAPI>
    private let apiKey: String

    public init(provider: MoyaProvider<MoviesAPI>, apiKey: String) {
        self.provider = provider
        self.apiKey = apiKey
    }

    public func request<T: Decodable>(_ target: MoviesAPI,
                                      type: T.Type,
                                      completion: @escaping (Result<T, Error>) -> Void) -> MoviesDomain.Cancellable {
        let targetWithAuth = self.addAuthToTarget(target)

        let cancellableToken = provider.request(targetWithAuth) { result in
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

        return MoyaCancellable(cancellableToken)
    }

    public func requestData(_ target: MoviesAPI,
                           completion: @escaping (Result<Data, Error>) -> Void) -> MoviesDomain.Cancellable {
        let cancellableToken = provider.request(target) { result in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return MoyaCancellable(cancellableToken)
    }

    private func addAuthToTarget(_ target: MoviesAPI) -> MoviesAPI {
        // Since we need to add API key to all requests except images,
        // we'll handle this in a custom plugin instead
        return target
    }
}

// Custom plugin to add API key
public struct APIKeyPlugin: PluginType {
    let apiKey: String

    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let moyaTarget = target as? MoviesAPI else { return request }

        switch moyaTarget {
        case .posterImage:
            return request
        default:
            guard let url = request.url else { return request }
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)

            var queryItems = urlComponents?.queryItems ?? []
            queryItems.append(URLQueryItem(name: "api_key", value: apiKey))
            urlComponents?.queryItems = queryItems

            var modifiedRequest = request
            modifiedRequest.url = urlComponents?.url
            return modifiedRequest
        }
    }
}

// Wrapper to make Moya's Cancellable conform to our protocol
final class MoyaCancellable: MoviesDomain.Cancellable {
    private let moyaCancellable: Moya.Cancellable

    init(_ moyaCancellable: Moya.Cancellable) {
        self.moyaCancellable = moyaCancellable
    }

    func cancel() {
        moyaCancellable.cancel()
    }
}