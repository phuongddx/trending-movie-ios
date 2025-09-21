import Foundation

protocol MovieDetailsViewModelInput {
    func viewDidLoad()
    func updatePosterImage(posterImagePath: String)
}

protocol MovieDetailsViewModelOutput {
    var movie: Observable<Movie?> { get }
    var posterImage: Observable<Data?> { get }
    var error: Observable<String> { get }
    var loading: Observable<MoviesListViewModelLoading?> { get }

    func detailsDisplayText(movie: Movie) -> NSAttributedString
}

protocol MovieDetailsViewModel: MovieDetailsViewModelInput,
                                MovieDetailsViewModelOutput {}

final class DefaultMovieDetailsViewModel: MovieDetailsViewModel {
    private let initialMovie: Movie
    private let posterImagesRepository: PosterImagesRepository
    private let mainQueue: DispatchQueueType
    private let detailsMovieUseCase: FetchDetailsMovieUseCaseProtocol
    private var moviesLoadTask: Cancellable? {
        willSet {
            moviesLoadTask?.cancel()
        }
    }
    private var imageLoadTask: Cancellable? {
        willSet {
            imageLoadTask?.cancel()
        }
    }

    // MARK: - Output
    var movie: Observable<Movie?> = Observable(nil)
    var posterImage: Observable<Data?> = Observable(nil)
    var loading: Observable<MoviesListViewModelLoading?> = Observable(.none)
    var error: Observable<String> = Observable("")

    init(movie: Movie,
         fetchDetailsMovieUseCase: FetchDetailsMovieUseCaseProtocol,
         posterImagesRepository: PosterImagesRepository,
         mainQueue: DispatchQueueType = DispatchQueue.main) {
        self.initialMovie = movie
        self.detailsMovieUseCase = fetchDetailsMovieUseCase
        self.posterImagesRepository = posterImagesRepository
        self.mainQueue = mainQueue
        self.movie.value = movie
    }

    func detailsDisplayText(movie: Movie) -> NSAttributedString {
        let viewModelItem = MoviesListItemViewModel(movie: movie, posterImagesRepository: posterImagesRepository)
        return viewModelItem.displayOverviewText()
    }

    func viewDidLoad() {
        loadDetails()
        if let posterPath = initialMovie.posterPath {
            updatePosterImage(posterImagePath: posterPath)
        }
    }

    func loadDetails() {
        loading.value = .fullScreen
        moviesLoadTask = detailsMovieUseCase.execute(with: initialMovie.id) { [weak self] result in
            self?.mainQueue.async {
                switch result {
                case .success(let movie):
                    self?.movie.value = movie
                case .failure(let error):
                    self?.handle(error: error)
                }
                self?.loading.value = .none
            }
        }
    }

    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading movie details", comment: "")
    }

    func updatePosterImage(posterImagePath: String) {
        imageLoadTask = posterImagesRepository.fetchImage(with: posterImagePath) { [weak self] result in
            self?.mainQueue.async {
                switch result {
                case .success(let data):
                    self?.posterImage.value = data
                case .failure: break
                }
                self?.imageLoadTask = nil
            }
        }
    }
}