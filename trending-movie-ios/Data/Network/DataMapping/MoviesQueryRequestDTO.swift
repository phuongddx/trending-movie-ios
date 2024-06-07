//
//  MoviesRequestDTO.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation

protocol MoviesRequestable: Encodable {
    var page: Int { get set }
}

struct MoviesQueryRequestDTO: MoviesRequestable {
    let query: String
    var page: Int
}

struct DefaultMoviesRequestDTO: MoviesRequestable {
    var page: Int
}
