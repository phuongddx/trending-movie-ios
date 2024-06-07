//
//  MovieDetailsViewModel.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 7/6/24.
//

import Foundation

protocol MovieDetailsViewModelInput {
    func updatePosterImage(width: Int)
}

protocol MovieDetailsViewModelOutput {
    var title: String { get }
    var posterImage: Observable<Data?> { get }
    var shouldShowPosterImage: Bool { get }
    var overview: String { get }
}

protocol MovieDetailsViewModel: MovieDetailsViewModelInput,
                                MovieDetailsViewModelOutput {}

final class DefaultMovieDetailsViewModel: MovieDetailsViewModel {
    private let posterImagePath: String?
    private let posterImagesRepository: PosterImagesRepository
    private var imageLoadTask: Cancellable? {
        willSet {
            imageLoadTask?.cancel()
        }
    }
    private let mainQueue: DispatchQueueType

    // MARK: - Output
    var title: String
    var posterImage: Observable<Data?> = Observable(nil)
    var shouldShowPosterImage: Bool
    var overview: String

    init(movie: Movie,
         posterImagesRepository: PosterImagesRepository,
         mainQueue: DispatchQueueType = DispatchQueue.main) {
        self.title = movie.title ?? ""
        self.overview = movie.overview ?? ""
        self.posterImagePath = movie.posterPath
        self.shouldShowPosterImage = movie.posterPath == nil
        self.posterImagesRepository = posterImagesRepository
        self.mainQueue = mainQueue
    }

    func updatePosterImage(width: Int) {
        guard let posterImagePath = posterImagePath else {
            return
        }

        imageLoadTask = posterImagesRepository.fetchImage(with: posterImagePath,
                                                          width: width) { [weak self] result in
            self?.mainQueue.async {
                guard self?.posterImagePath == posterImagePath else { return }
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
