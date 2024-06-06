//
//  MoviesQueriesRepository.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation

protocol MoviesQueriesRepository {
    func fetchRecentsQueries(maxCount: Int,
                             completion: @escaping (Result<[MovieQuery], Error>) -> Void)
    func saveRecentQuery(query: MovieQuery,
                         completion: @escaping (Result<MovieQuery, Error>) -> Void)
}
