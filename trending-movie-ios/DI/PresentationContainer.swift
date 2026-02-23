import Foundation
import Factory
import UIKit

extension AppContainer {


    // MARK: - SwiftUI ViewModels

    var observableMoviesListViewModel: Factory<ObservableMoviesListViewModel> {
        self {
            ObservableMoviesListViewModel(
                searchMoviesUseCase: self.searchMoviesUseCase(),
                trendingMoviesUseCase: self.trendingMoviesUseCase()
            )
        }
    }

    @MainActor
    func observableMovieDetailsViewModel(movie: Movie) -> ObservableMovieDetailsViewModel {
        ObservableMovieDetailsViewModel(
            movie: movie,
            fetchDetailsMovieUseCase: self.fetchDetailsMovieUseCase(),
            networkService: self.tmdbNetworkService()
        )
    }
}
