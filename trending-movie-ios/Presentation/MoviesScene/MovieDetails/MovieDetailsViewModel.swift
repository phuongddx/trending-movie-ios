//
//  MovieDetailsViewModel.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 7/6/24.
//

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
    private let movieId: Movie.Identifier
    private let posterImagesRepository: PosterImagesRepository
    private let mainQueue: DispatchQueueType
    private let detailsMovieUseCase: FetchDetailsMovieUseCase
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

    init(movieId: Movie.Identifier,
         detailsMovieUseCase: FetchDetailsMovieUseCase,
         posterImagesRepository: PosterImagesRepository,
         mainQueue: DispatchQueueType = DispatchQueue.main) {
        self.movieId = movieId
        self.detailsMovieUseCase = detailsMovieUseCase
        self.posterImagesRepository = posterImagesRepository
        self.mainQueue = mainQueue
    }

    func detailsDisplayText(movie: Movie) -> NSAttributedString {
        let viewModelItem = MoviesListItemViewModel(movie: movie)
        return viewModelItem.displayOverviewText()
    }

    func viewDidLoad() {
        loadDetails()
    }

    func loadDetails() {
        loading.value = .fullScreen
        moviesLoadTask = detailsMovieUseCase.execute(with: movieId) { [weak self] result in
            self?.mainQueue.async {
                switch result {
                case .success(let responseDto):
                    self?.movie.value = responseDto?.toDomain()
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
            NSLocalizedString("Failed loading movies", comment: "")
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
