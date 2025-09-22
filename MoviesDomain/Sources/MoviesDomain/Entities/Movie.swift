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
                homepage: String? = nil) {
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