//
//  TrendingMoviesUseCase.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 7/6/24.
//

import Foundation

protocol TrendingMoviesUseCase {
    func execute(requestable: MoviesRequestable,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable?
}

final class DefaultTrendingMoviesUseCase: TrendingMoviesUseCase {
    private let moviesRepository: MoviesRepository

    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }

    func execute(requestable: MoviesRequestable,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping MoviesPageResult) -> Cancellable? {
        moviesRepository.fetchTrendingMoviesList(requestDto: requestable,
                                                 cached: cached,
                                                 completion: completion)
    }
}
