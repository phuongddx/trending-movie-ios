import Foundation

// MARK: - TMDB Response Models

public struct TMDBMoviesResponse: Codable {
    let page: Int
    let results: [TMDBMovie]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

public struct TMDBMovie: Codable {
    let id: Int
    let title: String
    let originalTitle: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let adult: Bool
    let video: Bool
    let genreIds: [Int]

    enum CodingKeys: String, CodingKey {
        case id, title, overview, popularity, adult, video
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIds = "genre_ids"
    }
}

// MARK: - Conversion Extensions

extension TMDBMoviesResponse {
    func toDomain() -> MoviesPage {
        let movies = results.map { $0.toDomain() }
        return MoviesPage(page: page, totalPages: totalPages, movies: movies)
    }
}

extension TMDBMovie {
    func toDomain() -> Movie {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let parsedDate = releaseDate.flatMap { dateFormatter.date(from: $0) }

        return Movie(
            id: String(id),
            title: title,
            posterPath: posterPath,
            overview: overview,
            releaseDate: parsedDate,
            voteAverage: String(format: "%.1f", voteAverage)
        )
    }
}