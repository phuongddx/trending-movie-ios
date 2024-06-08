//
//  MoviesSceneDIContainer+Flow.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation
import UIKit

// MARK: - MoviesSearchFlowCoordinatorDependencies

extension MoviesSceneDIContainer: MoviesSearchFlowCoordinatorDependencies {
    // MARK: - MoviesList

    func makeMovieListView(actions: MoviesListViewModelActionsProtocol) -> MoviesListViewController {
        MoviesListViewController.create(with: makeMoviesListViewModel(actions: actions),
                                        posterImagesRepository: makePosterImagesRepository())
    }

    func makeMoviesListViewModel(actions: MoviesListViewModelActionsProtocol) -> MoviesListViewModel {
        DefaultMoviesListViewModel(searchMoviesUseCase: makeSearchMoviesUseCase(),
                                   trendingMoviesUseCase: makeTrendingMoviesUseCase(),
                                   actions: actions)
    }

    // MARK: - Movie Details
    func makeMoviesDetailsViewController(movie: Movie) -> ViewController {
        MovieDetailsViewController.create(with: makeMoviesDetailsViewModel(movieId: movie.id))
    }

    func makeMoviesDetailsViewModel(movieId: Movie.Identifier) -> MovieDetailsViewModel {
        DefaultMovieDetailsViewModel(movieId: movieId,
                                     detailsMovieUseCase: makeDetailsMovieUseCase(),
                                     posterImagesRepository: makePosterImagesRepository())
    }
}
