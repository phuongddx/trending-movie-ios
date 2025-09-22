import Foundation
import SwiftUI
import Combine

@MainActor
class ObservableMovieDetailsViewModel: ObservableObject {

    @Published var movie: Movie?
    @Published var loading: MoviesListViewModelLoading? = nil
    @Published var error: String = ""
    @Published var isShowingError: Bool = false

    private let initialMovie: Movie
    private let detailsMovieUseCase: FetchDetailsMovieUseCaseProtocol

    private var moviesLoadTask: Cancellable?

    var screenTitle: String { movie?.title ?? initialMovie.title ?? "Movie Details" }

    nonisolated init(movie: Movie,
         fetchDetailsMovieUseCase: FetchDetailsMovieUseCaseProtocol) {
        self.initialMovie = movie
        self.detailsMovieUseCase = fetchDetailsMovieUseCase
    }

    func viewDidLoad() {
        movie = initialMovie
        loadDetails()
    }

    func refreshDetails() async {
        loadDetails()
    }

    // MARK: - Private Methods
    private func loadDetails() {
        loading = .fullScreen

        moviesLoadTask?.cancel()
        moviesLoadTask = detailsMovieUseCase.execute(with: initialMovie.id) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let movie):
                    self?.movie = movie
                case .failure(let error):
                    self?.handleError(error)
                }
                self?.loading = nil
            }
        }
    }


    private func handleError(_ error: Error) {
        self.error = NSLocalizedString("Failed loading movie details", comment: "")
        self.isShowingError = true
    }
}

// MARK: - Movie Display Properties
extension ObservableMovieDetailsViewModel {
    var movieTitle: String {
        movie?.title ?? ""
    }

    var movieOverview: String {
        movie?.overview ?? ""
    }

    var releaseDate: String {
        guard let movie = movie, let releaseDate = movie.releaseDate else {
            return NSLocalizedString("To be announced", comment: "")
        }
        return dateFormatter.string(from: releaseDate)
    }

    var voteAverage: String {
        guard let movie = movie, let voteAverage = movie.voteAverage else {
            return NSLocalizedString("No rating", comment: "")
        }
        return voteAverage
    }

}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()