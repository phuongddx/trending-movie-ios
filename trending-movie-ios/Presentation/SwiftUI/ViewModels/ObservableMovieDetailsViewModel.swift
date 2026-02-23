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
    @Published var isShowingTrailer: Bool = false
    @Published var trailerVideoID: String?
    @Published var trailerTitle: String = ""

    // Supplementary data for new sections
    @Published var watchProviders: WatchProviders?
    @Published var reviews: [Review] = []
    @Published var similarMovies: [Movie] = []
    @Published var selectedSimilarMovie: Movie?

    private let initialMovie: Movie
    private let detailsMovieUseCase: FetchDetailsMovieUseCaseProtocol
    private let networkService: TMDBNetworkService

    private var moviesLoadTask: Cancellable?
    private var supplementaryLoadTask: Cancellable?

    var screenTitle: String { movie?.title ?? initialMovie.title ?? "Movie Details" }

    init(movie: Movie,
         fetchDetailsMovieUseCase: FetchDetailsMovieUseCaseProtocol,
         networkService: TMDBNetworkService) {
        self.initialMovie = movie
        self.detailsMovieUseCase = fetchDetailsMovieUseCase
        self.networkService = networkService
    }

    func viewDidLoad() {
        movie = initialMovie
        loadDetails()
        loadSupplementaryData()
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

    private func loadSupplementaryData() {
        // Load watch providers
        _ = networkService.request(
            .watchProviders(movieId: initialMovie.id),
            type: TMDBWatchProvidersResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // Default to US region
                    self?.watchProviders = response.results["US"]?.toDomain()
                case .failure(let error):
                    // Silent fail - section will be hidden, but log for debugging
                    print("⚠️ Watch providers load failed: \(error.localizedDescription)")
                }
            }
        }

        // Load reviews (first page only)
        _ = networkService.request(
            .movieReviews(movieId: initialMovie.id, page: 1),
            type: TMDBReviewsResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.reviews = response.results.map { $0.toDomain() }
                case .failure(let error):
                    print("⚠️ Reviews load failed: \(error.localizedDescription)")
                }
            }
        }

        // Load similar movies
        _ = networkService.request(
            .similarMovies(movieId: initialMovie.id, page: 1),
            type: TMDBMoviesResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.similarMovies = response.results.map { $0.toDomain() }
                case .failure(let error):
                    print("⚠️ Similar movies load failed: \(error.localizedDescription)")
                }
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
        guard let movie = movie else { return }

        if let videoID = movie.youTubeTrailerID {
            trailerVideoID = videoID
            trailerTitle = "\(movie.title ?? "Unknown") - Trailer"
            isShowingTrailer = true
        } else {
            // No trailer available
            error = NSLocalizedString("No trailer available for this movie", comment: "")
            isShowingError = true
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

    func selectSimilarMovie(_ movie: Movie) {
        selectedSimilarMovie = movie
    }

    func clearSelection() {
        selectedSimilarMovie = nil
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
