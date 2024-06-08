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
//    func makeMoviesQueriesSuggestionsListViewController(didSelect: @escaping MoviesQueryListViewModelDidSelectAction) -> ViewController
    func makeMoviesSearchResultViewController(actions: MoviesListViewModelActionsProtocol) -> ViewController?
}

final class MoviesSceneDIContainer {

    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let imageDataTransferService: DataTransferService
    }

    let dependencies: Dependencies

    // MARK: - Persistent Storage
    lazy var moviesQueriesStorage: MoviesQueriesStorage = CoreDataMoviesQueriesStorage(maxStorageLimit: 10)
    lazy var moviesResponseCache: MoviesResponseStorage = CoreDataMoviesResponseStorage()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}

// MARK:  - UseCases
extension MoviesSceneDIContainer {
    func makeSearchMoviesUseCase() -> SearchMoviesUseCase {
        DefaultSearchMoviesUseCase(moviesRepository: makeMoviesRepository(),
                                   moviesQueriesRepository: makeMoviesQueriesRepository())
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

    func makeMoviesQueriesRepository() -> MoviesQueriesRepository {
        DefaultMoviesQueriesRepository(moviesQueriesPersistentStorage: self.moviesQueriesStorage)
    }
}

// MARK: - Flow Coordinators
extension MoviesSceneDIContainer {
    func makeMoviesSearchFlowCoordinator(navigationController: UINavigationController) -> MoviesSearchFlowCoordinator {
        MoviesSearchFlowCoordinator(navigationController: navigationController,
                                    dependencies: self)
    }
}
