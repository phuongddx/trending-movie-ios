//
//  FetchDetailsMovieUseCase.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 7/6/24.
//

import Foundation

typealias MovieDetailsResponseDTO = MoviesResponseDTO.MovieDTO
typealias DetailsMovieResult = (Result<MovieDetailsResponseDTO?, any Error>) -> Void

protocol FetchDetailsMovieUseCase {
    func execute(with movieId: Movie.Identifier,
                 completion: @escaping DetailsMovieResult) -> Cancellable?
}

final class DefaultFetchDetailsMovieUseCase: FetchDetailsMovieUseCase {
    private let moviesRepository: MoviesRepository

    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }

    func execute(with movieId: Movie.Identifier,
                 completion: @escaping DetailsMovieResult) -> (any Cancellable)? {
        moviesRepository.fetchDetailsMovie(of: Movie.Identifier(movieId),
                                           completion: completion)
    }
}
