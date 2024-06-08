//
//  DefaultPosterImagesRepository.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation
import UIKit

final class DefaultPosterImagesRepository: PosterImagesRepository {
    private let dataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue
    private let inMemoryCache: InMemoryImageCache
    private let placeholderImage: UIImage
    
    init(dataTransferService: DataTransferService,
         backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated),
         inMemoryCache: InMemoryImageCache = InMemoryImageCache(),
         placeholderImage: UIImage = UIImage(named: "placeholder-bg")!) {
        self.dataTransferService = dataTransferService
        self.backgroundQueue = backgroundQueue
        self.inMemoryCache = inMemoryCache
        self.placeholderImage = placeholderImage
    }
    
    func fetchImage(with imagePath: String,
                    completion: @escaping ImagesResult) -> Cancellable? {
//        if let cachedImage = inMemoryCache.retrieve(forKey: imagePath) {
//            completion(.success(cachedImage as Data))
//            return nil
//        } else {
//            completion(.success(placeholderImage.pngData() ?? Data()))
//        }

        let endpoint = APIEndpoints.getMoviePoster(path: imagePath)
        let task = RepositoryTask()
        task.networkTask = dataTransferService.request(with: endpoint,
                                                       on: backgroundQueue) { [weak self] (result: Result<Data, DataTransferError>) in
            let result = result.map { data in
                self?.inMemoryCache.store(data as NSData, forKey: imagePath)
                return data
            }.mapError { $0 as Error}
            completion(result)
        }
        return task
    }
}
