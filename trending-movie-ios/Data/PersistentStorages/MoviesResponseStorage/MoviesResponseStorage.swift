//
//  MoviesResponseStorage.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation

protocol MoviesResponseStorage {
    func getDetailsMovie(for movieId: Int,
                         completion: @escaping DetailsMovieResult)
    func getResponse(for request: MoviesRequestable,
                     completion: @escaping (Result<MoviesResponseDTO?, Error>) -> Void)
    func save(response: MoviesResponseDTO, for requestDto: MoviesQueryRequestDTO)
    func save(response: MoviesResponseDTO)
    func save(response: MovieDetailsResponseDTO)
}
