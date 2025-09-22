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

// MARK: - Movie Detail Response Model

public struct TMDBMovieDetail: Codable {
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
    let budget: Int?
    let revenue: Int?
    let runtime: Int?
    let status: String?
    let tagline: String?
    let homepage: String?
    let imdbId: String?
    let originalLanguage: String?
    let genres: [Genre]?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let spokenLanguages: [SpokenLanguage]?
    let belongsToCollection: TMDBCollection?

    enum CodingKeys: String, CodingKey {
        case id, title, overview, popularity, adult, video
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case budget, revenue, runtime, status, tagline, homepage
        case imdbId = "imdb_id"
        case originalLanguage = "original_language"
        case genres
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case spokenLanguages = "spoken_languages"
        case belongsToCollection = "belongs_to_collection"
    }
}

public struct Genre: Codable {
    let id: Int
    let name: String
}

public struct ProductionCompany: Codable {
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}

public struct ProductionCountry: Codable {
    let iso31661: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case name
    }
}

public struct SpokenLanguage: Codable {
    let englishName: String?
    let iso6391: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case iso6391 = "iso_639_1"
        case name
    }
}

public struct TMDBCollection: Codable {
    let id: Int
    let name: String?
    let posterPath: String?
    let backdropPath: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }
}

// MARK: - Videos Response

public struct TMDBVideosResponse: Codable {
    let id: Int
    let results: [TMDBVideo]
}

public struct TMDBVideo: Codable {
    let id: String
    let key: String
    let name: String
    let site: String
    let size: Int?
    let type: String
    let official: Bool?
    let publishedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, key, name, site, size, type, official
        case publishedAt = "published_at"
    }
}

// MARK: - Images Response

public struct TMDBImagesResponse: Codable {
    let id: Int
    let backdrops: [TMDBImage]
    let posters: [TMDBImage]
}

public struct TMDBImage: Codable {
    let aspectRatio: Double
    let filePath: String
    let height: Int
    let width: Int
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case filePath = "file_path"
        case height, width
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

// MARK: - Credits Response

public struct TMDBCreditsResponse: Codable {
    let id: Int
    let cast: [TMDBCastMember]
    let crew: [TMDBCrewMember]
}

public struct TMDBCastMember: Codable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
    let order: Int
    let castId: Int?
    let creditId: String

    enum CodingKeys: String, CodingKey {
        case id, name, character, order
        case profilePath = "profile_path"
        case castId = "cast_id"
        case creditId = "credit_id"
    }
}

public struct TMDBCrewMember: Codable {
    let id: Int
    let name: String
    let job: String
    let department: String
    let profilePath: String?
    let creditId: String

    enum CodingKeys: String, CodingKey {
        case id, name, job, department
        case profilePath = "profile_path"
        case creditId = "credit_id"
    }
}

// MARK: - Release Dates Response (for certifications)

public struct TMDBReleaseDatesResponse: Codable {
    let id: Int
    let results: [TMDBReleaseDate]
}

public struct TMDBReleaseDate: Codable {
    let iso31661: String
    let releaseDates: [TMDBRelease]

    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case releaseDates = "release_dates"
    }
}

public struct TMDBRelease: Codable {
    let certification: String
    let releaseDate: String?
    let type: Int?
    let note: String?

    enum CodingKeys: String, CodingKey {
        case certification
        case releaseDate = "release_date"
        case type, note
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
            voteAverage: String(format: "%.1f", voteAverage),
            genres: nil,
            runtime: nil,
            productionCountries: nil,
            spokenLanguages: nil,
            budget: nil,
            revenue: nil,
            status: nil,
            tagline: nil,
            homepage: nil,
            certification: nil,
            director: nil,
            voteCount: voteCount,
            videos: nil,
            images: nil,
            credits: nil
        )
    }
}

extension TMDBMovieDetail {
    func toDomain(certification: String? = nil, director: String? = nil, videos: [Video]? = nil, images: MovieImages? = nil, credits: MovieCredits? = nil) -> Movie {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let parsedDate = releaseDate.flatMap { dateFormatter.date(from: $0) }

        return Movie(
            id: String(id),
            title: title,
            posterPath: posterPath,
            overview: overview,
            releaseDate: parsedDate,
            voteAverage: String(format: "%.1f", voteAverage),
            genres: genres?.map { $0.name },
            runtime: runtime,
            productionCountries: productionCountries?.map { $0.name },
            spokenLanguages: spokenLanguages?.compactMap { $0.englishName ?? $0.name },
            budget: budget,
            revenue: revenue,
            status: status,
            tagline: tagline,
            homepage: homepage,
            certification: certification,
            director: director,
            voteCount: voteCount,
            videos: videos,
            images: images,
            credits: credits
        )
    }
}

// MARK: - Video Conversion

extension TMDBVideo {
    func toDomain() -> Video {
        return Video(
            id: id,
            key: key,
            name: name,
            site: site,
            type: type,
            size: size
        )
    }
}

// MARK: - Image Conversion

extension TMDBImage {
    func toDomain() -> MovieImage {
        return MovieImage(
            filePath: filePath,
            width: width,
            height: height
        )
    }
}

// MARK: - Credits Conversion

extension TMDBCastMember {
    func toDomain() -> CastMember {
        return CastMember(
            id: String(id),
            name: name,
            character: character,
            profilePath: profilePath,
            order: order
        )
    }
}

extension TMDBCrewMember {
    func toDomain() -> CrewMember {
        return CrewMember(
            id: String(id),
            name: name,
            job: job,
            department: department,
            profilePath: profilePath
        )
    }
}