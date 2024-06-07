//
//  APIEndpoints.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation

struct APIEndpoints {
    static var version: String { "3" }

    static func getDetailsMovie(movieId: Movie.Identifier) -> Endpoint<MovieDetailsResponseDTO> {
        Endpoint(path: "\(Self.version)/movie/\(movieId)", method: .get)
    }

    static func getTodayTrendingMovies(with requestDTO: MoviesRequestable) -> Endpoint<MoviesResponseDTO> {
        Endpoint(path: "\(Self.version)/trending/movie/day",
                 method: .get,
                 queryParametersEncodable: requestDTO)
    }

    static func getMovies(with moviesRequestDTO: MoviesRequestable) -> Endpoint<MoviesResponseDTO> {
        Endpoint(path: "\(Self.version)/search/movie",
                 method: .get,
                 queryParametersEncodable: moviesRequestDTO)
    }

    static func getMoviePoster(path: String) -> Endpoint<Data> {
        Endpoint(path: "t/p/w500\(path)",
                 method: .get,
                 responseDecoder: RawDataResponseDecoder())
    }
}
