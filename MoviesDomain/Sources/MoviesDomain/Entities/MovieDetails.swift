import Foundation

public struct MovieDetails: Equatable {
    public let id: Movie.Identifier
    public let title: String
    public let overview: String?
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: Date?
    public let voteAverage: Double?
    public let voteCount: Int?
    public let runtime: Int?
    public let genres: [Genre]?

    public init(id: Movie.Identifier,
                title: String,
                overview: String?,
                posterPath: String?,
                backdropPath: String?,
                releaseDate: Date?,
                voteAverage: Double?,
                voteCount: Int?,
                runtime: Int?,
                genres: [Genre]?) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.runtime = runtime
        self.genres = genres
    }
}

public struct Genre: Equatable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}