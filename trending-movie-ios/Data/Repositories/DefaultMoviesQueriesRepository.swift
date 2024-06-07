//
//  DefaultMoviesQueriesRepository.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation

final class DefaultMoviesQueriesRepository {
    
    private var moviesQueriesPersistentStorage: MoviesQueriesStorage
    
    init(moviesQueriesPersistentStorage: MoviesQueriesStorage) {
        self.moviesQueriesPersistentStorage = moviesQueriesPersistentStorage
    }
}

extension DefaultMoviesQueriesRepository: MoviesQueriesRepository {
    
    func fetchRecentsQueries(maxCount: Int,
                             completion: @escaping (Result<[MovieQuery], Error>) -> Void) {
        moviesQueriesPersistentStorage.fetchRecentsQueries(maxCount: maxCount,
                                                           completion: completion)
    }
    
    func saveRecentQuery(query: MovieQuery,
                         completion: @escaping (Result<MovieQuery, Error>) -> Void) {
        moviesQueriesPersistentStorage.saveRecentQuery(query: query,
                                                       completion: completion)
    }
}
