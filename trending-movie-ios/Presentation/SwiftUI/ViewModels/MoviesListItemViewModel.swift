import Foundation
import Combine

struct MoviesListItemViewModel: Equatable {
    let id: String
    let title: String
    let overview: String
    let releaseDate: String
    let voteAverage: String
    let posterImagePath: String?

    init(movie: Movie) {
        self.id = movie.id
        self.title = movie.title ?? ""
        self.posterImagePath = movie.posterPath
        self.overview = movie.overview ?? ""

        if let releaseDate = movie.releaseDate {
            self.releaseDate = dateFormatter.string(from: releaseDate)
        } else {
            self.releaseDate = NSLocalizedString("To be announced", comment: "")
        }

        if let voteAverage = movie.voteAverage {
            self.voteAverage = voteAverage
        } else {
            self.voteAverage = NSLocalizedString("No rating", comment: "")
        }
    }


    static func == (lhs: MoviesListItemViewModel, rhs: MoviesListItemViewModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.overview == rhs.overview &&
               lhs.releaseDate == rhs.releaseDate &&
               lhs.voteAverage == rhs.voteAverage &&
               lhs.posterImagePath == rhs.posterImagePath
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()