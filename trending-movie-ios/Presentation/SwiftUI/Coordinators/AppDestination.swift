import Foundation

// Importing Movie from the Domain layer
// Assuming Movie is defined elsewhere in the project

enum AppDestination: Hashable {
    case moviesList
    case movieDetails(Movie)

    // MARK: - Hashable Implementation
    func hash(into hasher: inout Hasher) {
        switch self {
        case .moviesList:
            hasher.combine("moviesList")
        case .movieDetails(let movie):
            hasher.combine("movieDetails")
            hasher.combine(movie.id)
        }
    }

    static func == (lhs: AppDestination, rhs: AppDestination) -> Bool {
        switch (lhs, rhs) {
        case (.moviesList, .moviesList):
            return true
        case (.movieDetails(let lhsMovie), .movieDetails(let rhsMovie)):
            return lhsMovie.id == rhsMovie.id
        default:
            return false
        }
    }
}

// MARK: - Navigation Helpers
extension AppDestination {
    var navigationTitle: String {
        switch self {
        case .moviesList:
            return NSLocalizedString("Movies", comment: "")
        case .movieDetails(let movie):
            return movie.title ?? NSLocalizedString("Movie Details", comment: "")
        }
    }

    var analyticsScreenName: String {
        switch self {
        case .moviesList:
            return "movies_list"
        case .movieDetails:
            return "movie_details"
        }
    }
}