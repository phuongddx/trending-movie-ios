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
                         completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
}
