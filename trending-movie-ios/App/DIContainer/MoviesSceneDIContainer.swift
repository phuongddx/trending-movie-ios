//
//  MoviesSceneDIContainer.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation
import UIKit

typealias MoviesQueryListViewModelDidSelectAction = (MovieQuery) -> Void
protocol MoviesSearchFlowCoordinatorDependencies {
    func makeMovieListView(actions: MoviesListViewModelActionsProtocol) -> MoviesListViewController
    func makeMoviesDetailsViewController(movie: Movie) -> ViewController
}

final class MoviesSceneDIContainer {

    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let imageDataTransferService: DataTransferService
    }

    let dependencies: Dependencies

    // MARK: - Persistent Storage
    lazy var moviesResponseCache: MoviesResponseStorage = CoreDataMoviesResponseStorage()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}

// MARK:  - UseCases
extension MoviesSceneDIContainer {
    func makeSearchMoviesUseCase() -> SearchMoviesUseCase {
        DefaultSearchMoviesUseCase(moviesRepository: makeMoviesRepository())
    }

    func makeTrendingMoviesUseCase() -> TrendingMoviesUseCase {
        DefaultTrendingMoviesUseCase(moviesRepository: makeMoviesRepository())
    }

    func makeDetailsMovieUseCase() -> FetchDetailsMovieUseCase {
        DefaultFetchDetailsMovieUseCase(moviesRepository: makeMoviesRepository())
    }
}

// MARK:  - Repositories
extension MoviesSceneDIContainer {
    func makeMoviesRepository() -> MoviesRepository {
        DefaultMoviesRepository(dataTransferService: dependencies.apiDataTransferService,
                                cache: moviesResponseCache)
    }

    func makePosterImagesRepository() -> PosterImagesRepository {
        DefaultPosterImagesRepository(dataTransferService: dependencies.imageDataTransferService)
    }
}

// MARK: - Flow Coordinators
extension MoviesSceneDIContainer {
    func makeMoviesSearchFlowCoordinator(navigationController: UINavigationController) -> MoviesSearchFlowCoordinator {
        MoviesSearchFlowCoordinator(navigationController: navigationController,
                                    dependencies: self)
    }
}
