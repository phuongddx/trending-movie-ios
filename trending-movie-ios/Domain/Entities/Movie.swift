//
//  Movie.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation

struct Movie: Equatable, Identifiable {
    typealias Identifier = String

    let id: Identifier
    let title: String?
    let posterPath: String?
    let overview: String?
    let releaseDate: Date?
    let voteAverage: String?
}

struct MoviesPage: Equatable {
    let page: Int
    let totalPages: Int
    let movies: [Movie]
}
