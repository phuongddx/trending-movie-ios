import Foundation
import UIKit
import Factory

protocol Coordinator {
    func start()
}

final class MoviesSearchFlowCoordinator: Coordinator {
    private weak var navigationController: UINavigationController?
    private let container: AppContainer

    private weak var moviesTrendingListViewController: MoviesListViewController?
    private weak var moviesListSearchResultViewViewController: ViewController?

    init(navigationController: UINavigationController,
         container: AppContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    private var trendingMoviesListActions: MoviesListViewModelActionsProtocol {
        TrendingMoviesListViewModelActions(showMovieDetails: showMovieDetails(movie:))
    }

    func start() {
        let vc = makeMovieListView(actions: trendingMoviesListActions)
        navigationController?.pushViewController(vc, animated: true)
        moviesTrendingListViewController = vc
    }

    private func showMovieDetails(movie: Movie) {
        let vc = makeMoviesDetailsViewController(movie: movie)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Factory Methods

    private func makeMovieListView(actions: MoviesListViewModelActionsProtocol) -> MoviesListViewController {
        let viewModel = DefaultMoviesListViewModel(
            searchMoviesUseCase: container.searchMoviesUseCase(),
            trendingMoviesUseCase: container.trendingMoviesUseCase(),
            posterImagesRepository: container.posterImagesRepository(),
            actions: actions
        )
        return MoviesListViewController.create(with: viewModel,
                                              posterImagesRepository: container.posterImagesRepository())
    }

    private func makeMoviesDetailsViewController(movie: Movie) -> ViewController {
        let viewModel = container.movieDetailsViewModel(movie: movie)
        return MovieDetailsViewController.create(with: viewModel)
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