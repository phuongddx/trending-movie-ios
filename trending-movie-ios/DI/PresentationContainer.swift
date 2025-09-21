import Foundation
import Factory
import UIKit

extension AppContainer {


    // MARK: - SwiftUI ViewModels

    var observableMoviesListViewModel: Factory<ObservableMoviesListViewModel> {
        self {
            ObservableMoviesListViewModel(
                searchMoviesUseCase: self.searchMoviesUseCase(),
                trendingMoviesUseCase: self.trendingMoviesUseCase(),
                posterImagesRepository: self.posterImagesRepository()
            )
        }
    }

    func observableMovieDetailsViewModel(movie: Movie) -> ObservableMovieDetailsViewModel {
        ObservableMovieDetailsViewModel(
            movie: movie,
            fetchDetailsMovieUseCase: self.fetchDetailsMovieUseCase(),
            posterImagesRepository: self.posterImagesRepository()
        )
    }
}