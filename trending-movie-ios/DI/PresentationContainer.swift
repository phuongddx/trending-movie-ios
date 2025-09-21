import Foundation
import Factory
import UIKit

extension AppContainer {

    // MARK: - ViewModels

    var moviesListViewModel: Factory<DefaultMoviesListViewModel> {
        self {
            DefaultMoviesListViewModel(
                searchMoviesUseCase: self.searchMoviesUseCase(),
                trendingMoviesUseCase: self.trendingMoviesUseCase(),
                posterImagesRepository: self.posterImagesRepository()
            )
        }
    }

    func movieDetailsViewModel(movie: Movie) -> DefaultMovieDetailsViewModel {
        DefaultMovieDetailsViewModel(
            movie: movie,
            fetchDetailsMovieUseCase: self.fetchDetailsMovieUseCase(),
            posterImagesRepository: self.posterImagesRepository()
        )
    }

    func moviesSearchFlowCoordinator(navigationController: UINavigationController) -> MoviesSearchFlowCoordinator {
        MoviesSearchFlowCoordinator(
            navigationController: navigationController,
            container: self
        )
    }
}