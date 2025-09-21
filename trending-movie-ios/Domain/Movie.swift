import Foundation

public struct Movie: Equatable, Identifiable {
    public typealias Identifier = String

    public let id: Identifier
    public let title: String?
    public let posterPath: String?
    public let overview: String?
    public let releaseDate: Date?
    public let voteAverage: String?

    public init(id: Identifier,
                title: String?,
                posterPath: String?,
                overview: String?,
                releaseDate: Date?,
                voteAverage: String?) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.overview = overview
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
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