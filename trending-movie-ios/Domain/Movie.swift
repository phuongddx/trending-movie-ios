import Foundation

public struct Movie: Equatable, Identifiable {
    public typealias Identifier = String

    public let id: Identifier
    public let title: String?
    public let posterPath: String?
    public let overview: String?
    public let releaseDate: Date?
    public let voteAverage: String?
    public let genres: [String]?
    public let runtime: Int?
    public let productionCountries: [String]?
    public let spokenLanguages: [String]?
    public let budget: Int?
    public let revenue: Int?
    public let status: String?
    public let tagline: String?
    public let homepage: String?
    public let certification: String?
    public let director: String?
    public let voteCount: Int?
    public let videos: [Video]?
    public let images: MovieImages?
    public let credits: MovieCredits?

    public init(id: Identifier,
                title: String?,
                posterPath: String?,
                overview: String?,
                releaseDate: Date?,
                voteAverage: String?,
                genres: [String]? = nil,
                runtime: Int? = nil,
                productionCountries: [String]? = nil,
                spokenLanguages: [String]? = nil,
                budget: Int? = nil,
                revenue: Int? = nil,
                status: String? = nil,
                tagline: String? = nil,
                homepage: String? = nil,
                certification: String? = nil,
                director: String? = nil,
                voteCount: Int? = nil,
                videos: [Video]? = nil,
                images: MovieImages? = nil,
                credits: MovieCredits? = nil) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.overview = overview
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.genres = genres
        self.runtime = runtime
        self.productionCountries = productionCountries
        self.spokenLanguages = spokenLanguages
        self.budget = budget
        self.revenue = revenue
        self.status = status
        self.tagline = tagline
        self.homepage = homepage
        self.certification = certification
        self.director = director
        self.voteCount = voteCount
        self.videos = videos
        self.images = images
        self.credits = credits
    }
}

public struct MoviesPage: Equatable {
    public let page: Int
    public let totalPages: Int
    public let movies: [Movie]

    public init(page: Int, totalPages: Int, movies: [Movie]) {
        self.page = page
        self.totalPages = totalPages
        self.movies = movies
    }
}

public struct Video: Equatable, Identifiable {
    public let id: String
    public let key: String
    public let name: String
    public let site: String
    public let type: String
    public let size: Int?

    public init(id: String, key: String, name: String, site: String, type: String, size: Int?) {
        self.id = id
        self.key = key
        self.name = name
        self.site = site
        self.type = type
        self.size = size
    }
}

public struct MovieImages: Equatable {
    public let backdrops: [MovieImage]
    public let posters: [MovieImage]

    public init(backdrops: [MovieImage], posters: [MovieImage]) {
        self.backdrops = backdrops
        self.posters = posters
    }
}

public struct MovieImage: Equatable {
    public let filePath: String
    public let width: Int
    public let height: Int

    public init(filePath: String, width: Int, height: Int) {
        self.filePath = filePath
        self.width = width
        self.height = height
    }
}

public struct MovieCredits: Equatable {
    public let cast: [CastMember]
    public let crew: [CrewMember]

    public init(cast: [CastMember], crew: [CrewMember]) {
        self.cast = cast
        self.crew = crew
    }
}

public struct CastMember: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let character: String?
    public let profilePath: String?
    public let order: Int?

    public init(id: String, name: String, character: String?, profilePath: String?, order: Int? = nil) {
        self.id = id
        self.name = name
        self.character = character
        self.profilePath = profilePath
        self.order = order
    }
}

public struct CrewMember: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let job: String
    public let department: String
    public let profilePath: String?

    public init(id: String, name: String, job: String, department: String, profilePath: String?) {
        self.id = id
        self.name = name
        self.job = job
        self.department = department
        self.profilePath = profilePath
    }
}

// MARK: - Movie Extensions for UI
extension Movie {
    public var formattedYear: String {
        if let releaseDate = releaseDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            return formatter.string(from: releaseDate)
        }
        return "2021"
    }

    public var formattedRuntime: String {
        if let runtime = runtime, runtime > 0 {
            return "\(runtime) Minutes"
        }
        return "148 Minutes"
    }

    public var primaryGenre: String {
        if let genres = genres, let firstGenre = genres.first {
            return firstGenre
        }
        return "Action"
    }

    public var numericRating: Double {
        if let voteAverage = voteAverage,
           let ratingValue = Double(voteAverage) {
            return ratingValue
        }
        return 4.5
    }

    public var backdropImageURL: String? {
        if let posterPath = posterPath, !posterPath.isEmpty {
            return "https://image.tmdb.org/t/p/w780\(posterPath)"
        }
        return nil
    }

    public var posterImageURL: String? {
        if let posterPath = posterPath, !posterPath.isEmpty {
            return "https://image.tmdb.org/t/p/w342\(posterPath)"
        }
        return nil
    }

    public var youTubeTrailerID: String? {
        guard let videos = videos else { return nil }

        // Find YouTube trailer - prioritize official trailers
        let youTubeTrailers = videos.filter { video in
            video.site.lowercased() == "youtube" &&
            video.type.lowercased() == "trailer"
        }

        // Sort by name to prioritize "Official Trailer" or similar
        let sortedTrailers = youTubeTrailers.sorted { first, second in
            let firstIsOfficial = first.name.lowercased().contains("official")
            let secondIsOfficial = second.name.lowercased().contains("official")
            return firstIsOfficial && !secondIsOfficial
        }

        return sortedTrailers.first?.key
    }

    public var hasTrailer: Bool {
        return youTubeTrailerID != nil
    }
}
