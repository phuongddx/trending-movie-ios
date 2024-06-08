//
//  MoviesSearchFlowCoordinator.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation
import UIKit

protocol Coordinator {
    func start()
}

final class MoviesSearchFlowCoordinator: Coordinator {
    private weak var navigationController: UINavigationController?
    private let dependencies: MoviesSearchFlowCoordinatorDependencies

    private weak var moviesTrendingListViewController: MoviesListViewController?
    private weak var moviesListSearchResultViewViewController: ViewController?

    init(navigationController: UINavigationController,
         dependencies: MoviesSearchFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    private var trendingMoviesListActions: MoviesListViewModelActionsProtocol {
        TrendingMoviesListViewModelActions(closeMovieQueriesSuggestions: closeMovieQueriesSuggestions,
                                          showMovieDetails: showMovieDetails(movie:),
                                          showMovieQueriesSuggestions: showMovieQueriesSuggestions(didSelect:))
    }

    private var moviesSearchResultActions: MoviesListViewModelActionsProtocol {
        TrendingMoviesListViewModelActions(closeMovieQueriesSuggestions: closeMovieQueriesSuggestions,
                                          showMovieDetails: showMovieDetails(movie:))
    }

    func start() {
        let vc = dependencies.makeMovieListView(actions: trendingMoviesListActions)
        navigationController?.pushViewController(vc, animated: true)
        moviesTrendingListViewController = vc
    }

    private func showMovieDetails(movie: Movie) {
        let vc = dependencies.makeMoviesDetailsViewController(movie: movie)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showMovieQueriesSuggestions(didSelect: @escaping (MovieQuery) -> Void) {
//        guard let moviesTrendingListViewController,
//              moviesListSearchResultViewViewController == nil,
//            let moviesSearchResultContainer = moviesTrendingListViewController.moviesSearchResultContainer else { return }
//
////        let vc = dependencies.makeMoviesQueriesSuggestionsListViewController(didSelect: didSelect)
//        let vc = ViewController() // MovisesSearch
//        vc.view.backgroundColor = .blue
//
//        moviesTrendingListViewController.add(child: vc,
//                                             container: moviesSearchResultContainer)
//        moviesListSearchResultViewViewController = vc
//        moviesSearchResultContainer.isHidden = false
    }

//    private func showMoviesSearchResult() {
//        guard let moviesTrendingListViewController,
//              moviesListSearchResultViewViewController == nil,
//            let moviesSearchResultContainer = moviesTrendingListViewController.moviesSearchResultContainer else { return }
//
//        let vc = dependencies.makeMoviesSearchResultViewController(actions: moviesSearchResultActions)
//        moviesTrendingListViewController.add(child: vc, container: moviesSearchResultContainer)
//        moviesListSearchResultViewViewController = vc
//        moviesSearchResultContainer.show()
//    }

    private func closeMovieQueriesSuggestions() {
        moviesListSearchResultViewViewController?.remove()
        moviesListSearchResultViewViewController = nil
        moviesTrendingListViewController?.moviesSearchResultContainer.hide()
    }
}

extension UIView {
    func show() {
        self.isHidden = false
    }

    func hide() {
        self.isHidden = true
    }
}
