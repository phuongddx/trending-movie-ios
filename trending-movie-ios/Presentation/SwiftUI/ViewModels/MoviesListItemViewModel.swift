import Foundation

struct MoviesListItemViewModel: Equatable {
    let title: String
    let overview: String
    let releaseDate: String
    let voteAverage: String
    let posterImagePath: String?
    private let posterImagesRepository: PosterImagesRepository

    init(movie: Movie, posterImagesRepository: PosterImagesRepository) {
        self.title = movie.title ?? ""
        self.posterImagePath = movie.posterPath
        self.overview = movie.overview ?? ""
        self.posterImagesRepository = posterImagesRepository

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

    func loadPosterImage(completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        guard let posterPath = posterImagePath else {
            completion(.failure(NSError(domain: "MoviesListItemViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No poster path"])))
            return nil
        }
        return posterImagesRepository.fetchImage(with: posterPath, completion: completion)
    }

    static func == (lhs: MoviesListItemViewModel, rhs: MoviesListItemViewModel) -> Bool {
        return lhs.title == rhs.title &&
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