//
//  MoviesRepository.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation

protocol MoviesRepository {
    @discardableResult
    func fetchMoviesList(query: MovieQuery,
                         page: Int,
                         cached: @escaping (MoviesPage) -> Void,
                         completion: @escaping MoviesPageResult) -> Cancellable?

    @discardableResult
    func fetchTrendingMoviesList(requestDto: MoviesRequestable,
                                 cached: @escaping (MoviesPage) -> Void,
                                 completion: @escaping MoviesPageResult) -> Cancellable?
    @discardableResult
    func fetchDetailsMovie(of movieId: Movie.Identifier,
                           completion: @escaping DetailsMovieResult) -> Cancellable?
}
