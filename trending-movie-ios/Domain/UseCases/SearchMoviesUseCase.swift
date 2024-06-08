//
//  DefaultSearchMoviesUseCase.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation

typealias MoviesPageResult = (Result<MoviesPage, any Error>) -> Void

protocol SearchMoviesUseCase {
    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {
    private let moviesRepository: MoviesRepository

    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }

    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable? {
        moviesRepository.fetchMoviesList(query: requestValue.query,
                                         page: requestValue.page,
                                         cached: cached,
                                         completion: completion)
    }
}

struct SearchMoviesUseCaseRequestValue {
    let query: MovieQuery
    let page: Int
}
