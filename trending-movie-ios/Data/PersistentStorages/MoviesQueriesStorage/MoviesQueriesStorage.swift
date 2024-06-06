//
//  MoviesQueriesStorage.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation

import Foundation

protocol MoviesQueriesStorage {
    func fetchRecentsQueries(maxCount: Int,
                             completion: @escaping (Result<[MovieQuery], Error>) -> Void)
    func saveRecentQuery(query: MovieQuery,
                         completion: @escaping (Result<MovieQuery, Error>) -> Void)
}
