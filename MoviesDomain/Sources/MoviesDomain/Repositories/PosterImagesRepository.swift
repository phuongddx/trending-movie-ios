import Foundation

public enum ImageSize: String {
    case thumbnail = "w154"
    case small = "w185"
    case medium = "w342"
    case large = "w500"
    case extraLarge = "w780"
    case original = "original"
}

public protocol PosterImagesRepository {
    func getImageURL(for imagePath: String, size: ImageSize) -> URL?
}