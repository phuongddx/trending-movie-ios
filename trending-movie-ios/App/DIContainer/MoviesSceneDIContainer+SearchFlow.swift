//
//  MoviesSceneDIContainer+MoviesSearchFlowCoordinatorDependencies.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation
import UIKit

extension MoviesSceneDIContainer: MoviesSearchFlowCoordinatorDependencies {
    // MARK: - MoviesList
    func makeMovieListView(actions: MoviesListViewModelActionsProtocol) -> MoviesListViewController {
        MoviesListViewController.create(with: makeMoviesListViewModel(actions: actions),
                                        posterImagesRepository: makePosterImagesRepository())
    }

    func makeMoviesListViewModel(actions: MoviesListViewModelActionsProtocol) -> MoviesListViewModel {
        DefaultMoviesListViewModel(searchMoviesUseCase: makeSearchMoviesUseCase(),
                                   actions: actions)
    }

    // MARK: - Movie Details
    func makeMoviesDetailsViewController(movie: Movie) -> ViewController {
        MovieDetailsViewController.create(with: self.makeMoviesDetailsViewModel(movie: movie))
    }
    
    func makeMoviesQueriesSuggestionsListViewController(didSelect: @escaping MoviesQueryListViewModelDidSelectAction) -> ViewController {
        ViewController()
    }

    func makeMoviesDetailsViewModel(movie: Movie) -> MovieDetailsViewModel {
        DefaultMovieDetailsViewModel(movie: movie,
                                     posterImagesRepository: makePosterImagesRepository())
    }
}
