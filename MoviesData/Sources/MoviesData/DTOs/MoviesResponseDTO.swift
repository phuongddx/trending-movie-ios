import Foundation
import MoviesDomain

public struct MoviesResponseDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case movies = "results"
    }
    public let page: Int
    public let totalPages: Int
    public let movies: [MovieDTO]
}

extension MoviesResponseDTO {
    public struct MovieDTO: Decodable {
        private enum CodingKeys: String, CodingKey {
            case id
            case title
            case posterPath = "poster_path"
            case overview
            case releaseDate = "release_date"
            case voteAverage = "vote_average"
        }

        public let id: Int
        public let title: String?
        public let posterPath: String?
        public let overview: String?
        public let releaseDate: String?
        public let voteAverage: Double?
    }
}

// MARK: - Mappings to Domain

extension MoviesResponseDTO {
    public func toDomain() -> MoviesPage {
        MoviesPage(page: page,
                   totalPages: totalPages,
                   movies: movies.map { $0.toDomain() })
    }
}

extension MoviesResponseDTO.MovieDTO {
    public func toDomain() -> Movie {
        Movie(id: Movie.Identifier(id),
              title: title,
              posterPath: posterPath,
              overview: overview,
              releaseDate: dateFormatter.date(from: releaseDate ?? ""),
              voteAverage: String(describing: (voteAverage ?? 0).rounded(.up)))
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