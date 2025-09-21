import Foundation

public typealias ImagesResult = (Result<Data, Error>) -> Void

public protocol PosterImagesRepository {
    func fetchImage(with imagePath: String,
                    completion: @escaping ImagesResult) -> Cancellable?
}