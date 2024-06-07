//
//  APIEndpoints.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation

struct APIEndpoints {
    static func getTodayTrendingMovies(with requestDTO: MoviesRequestable) -> Endpoint<MoviesResponseDTO> {
        Endpoint(path: "3/trending/movie/day",
                 method: .get,
                 queryParametersEncodable: requestDTO)
    }

    static func getMovies(with moviesRequestDTO: MoviesRequestable) -> Endpoint<MoviesResponseDTO> {
        Endpoint(path: "3/search/movie",
                 method: .get,
                 queryParametersEncodable: moviesRequestDTO)
    }

    static func getMoviePoster(path: String, width: Int) -> Endpoint<Data> {
        let sizes = [92, 154, 185, 342, 500, 780]
        let closestWidth = sizes
            .enumerated()
            .min { abs($0.1 - width) < abs($1.1 - width) }?
            .element ?? sizes.first!

        return Endpoint(path: "t/p/w\(closestWidth)\(path)",
                        method: .get,
                        responseDecoder: RawDataResponseDecoder())
    }
}
