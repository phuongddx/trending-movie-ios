//
//  MoviesResponseDTO.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation

struct MoviesResponseDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case movies = "results"
    }
    let page: Int
    let totalPages: Int
    let movies: [MovieDTO]
}

extension MoviesResponseDTO {
    struct MovieDTO: Decodable {
        private enum CodingKeys: String, CodingKey {
            case id
            case title
            case posterPath = "poster_path"
            case overview
            case releaseDate = "release_date"
        }

        let id: Int
        let title: String?
        let posterPath: String?
        let overview: String?
        let releaseDate: String?
    }
}

// MARK: - Mappings to Domain

extension MoviesResponseDTO {
    func toDomain() -> MoviesPage {
        MoviesPage(page: page,
                   totalPages: totalPages,
                   movies: movies.map { $0.toDomain() })
    }
}

extension MoviesResponseDTO.MovieDTO {
    func toDomain() -> Movie {
        Movie(id: Movie.Identifier(id),
              title: title,
              posterPath: posterPath,
              overview: overview,
              releaseDate: dateFormatter.date(from: releaseDate ?? ""))
    }
}

// MARK: - Private

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()
