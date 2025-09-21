import Foundation
import MoviesDomain

public final class DefaultPosterImagesRepository: PosterImagesRepository {
    private let networkService: MoviesNetworkService
    private let imageCache: ImageCache?

    public init(networkService: MoviesNetworkService, imageCache: ImageCache? = nil) {
        self.networkService = networkService
        self.imageCache = imageCache
    }

    public func fetchImage(with imagePath: String,
                          completion: @escaping ImagesResult) -> MoviesDomain.Cancellable? {
        // Check cache first
        if let cachedImage = imageCache?.getImage(for: imagePath) {
            completion(.success(cachedImage))
            return nil
        }

        // Fetch from network
        let cancellable = networkService.requestData(.posterImage(path: imagePath)) { [weak self] result in
            switch result {
            case .success(let data):
                self?.imageCache?.save(image: data, for: imagePath)
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return cancellable
    }
}

// MARK: - Image Cache Protocol

public protocol ImageCache {
    func getImage(for path: String) -> Data?
    func save(image: Data, for path: String)
}