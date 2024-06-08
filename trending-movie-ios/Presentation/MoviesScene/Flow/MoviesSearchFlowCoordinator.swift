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
        TrendingMoviesListViewModelActions(showMovieDetails: showMovieDetails(movie:))
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
}

extension UIView {
    func show() {
        self.isHidden = false
    }

    func hide() {
        self.isHidden = true
    }
}
