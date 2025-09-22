import Foundation
import SwiftUI
import Combine
import Moya

@MainActor
class ObservableMovieDetailsViewModel: ObservableObject {

    @Published var movie: Movie?
    @Published var loading: MoviesListViewModelLoading? = nil
    @Published var error: String = ""
    @Published var isShowingError: Bool = false
    @Published var isTrailerLoading: Bool = false
    @Published var isDownloading: Bool = false

    private let initialMovie: Movie
    private let detailsMovieUseCase: FetchDetailsMovieUseCaseProtocol

    private var moviesLoadTask: Cancellable?

    var screenTitle: String { movie?.title ?? initialMovie.title ?? "Movie Details" }

    init(movie: Movie,
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
            DispatchQueue.main.async {
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
        print("🔴 Movie Details Error: \(error)")
        print("🔴 Movie ID: \(initialMovie.id)")
        print("🔴 Movie Title: \(initialMovie.title ?? "Unknown")")

        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                print("🔴 HTTP Status: \(response.statusCode)")
                print("🔴 Response: \(String(data: response.data, encoding: .utf8) ?? "No data")")
            case .underlying(let underlyingError, _):
                print("🔴 Underlying error: \(underlyingError)")
            default:
                print("🔴 Other Moya error: \(moyaError.localizedDescription)")
            }
        }

        self.error = NSLocalizedString("Failed loading movie details", comment: "")
        self.isShowingError = true
    }

    // MARK: - Action Methods
    func playTrailer() {
        isTrailerLoading = true
        // Simulate trailer loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isTrailerLoading = false
            // In a real app, this would open the trailer player
            print("Playing trailer for: \(self.movie?.title ?? "Unknown")")
        }
    }

    func downloadMovie() {
        isDownloading = true
        // Simulate download
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isDownloading = false
            // In a real app, this would start the download
            print("Downloaded: \(self.movie?.title ?? "Unknown")")
        }
    }

    func shareMovie() {
        // In a real app, this would share the movie
        print("Sharing: \(movie?.title ?? "Unknown")")
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
