import Foundation
import MoviesDomain

public struct MovieDetailsResponseDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case runtime
        case genres
    }

    public let id: Int
    public let title: String
    public let overview: String?
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: String?
    public let voteAverage: Double?
    public let voteCount: Int?
    public let runtime: Int?
    public let genres: [GenreDTO]?
}

extension MovieDetailsResponseDTO {
    public struct GenreDTO: Decodable {
        public let id: Int
        public let name: String
    }
}

// MARK: - Mappings to Domain

extension MovieDetailsResponseDTO {
    public func toDomain() -> MovieDetails {
        MovieDetails(
            id: String(id),
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: dateFormatter.date(from: releaseDate ?? ""),
            voteAverage: voteAverage,
            voteCount: voteCount,
            runtime: runtime,
            genres: genres?.map { $0.toDomain() }
        )
    }
}

extension MovieDetailsResponseDTO.GenreDTO {
    public func toDomain() -> Genre {
        Genre(id: id, name: name)
    }
}

// MARK: - Private

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()