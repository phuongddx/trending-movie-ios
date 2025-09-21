import Foundation
import MoviesDomain

public final class InMemoryMoviesCache: MoviesResponseStorage {
    private var cache: [RequestCacheKey: MoviesPage] = [:]
    private let queue = DispatchQueue(label: "com.moviesdata.cache", attributes: .concurrent)

    public init() {}

    public func getResponse(for key: RequestCacheKey) -> MoviesPage? {
        queue.sync {
            cache[key]
        }
    }

    public func save(response: MoviesPage, for key: RequestCacheKey) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache[key] = response
        }
    }
}

public final class InMemoryImageCache: ImageCache {
    private var cache: [String: Data] = [:]
    private let queue = DispatchQueue(label: "com.moviesdata.imagecache", attributes: .concurrent)
    private let maxCacheSize = 50 // Maximum number of images to cache

    public init() {}

    public func getImage(for path: String) -> Data? {
        queue.sync {
            cache[path]
        }
    }

    public func save(image: Data, for path: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            // Simple LRU: Remove oldest entries if cache is too large
            if self.cache.count >= self.maxCacheSize {
                if let firstKey = self.cache.keys.first {
                    self.cache.removeValue(forKey: firstKey)
                }
            }

            self.cache[path] = image
        }
    }
}