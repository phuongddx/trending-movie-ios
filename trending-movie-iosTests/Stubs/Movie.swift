//
//  Movie.swift
//  trending-movie-iosTests
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation
@testable import trending_movie_ios

extension Movie {
    static func stub(id: Movie.Identifier = "id1",
                    title: String = "title1" ,
                    posterPath: String? = "/1",
                    overview: String = "stub overview",
                    releaseDate: Date? = nil) -> Self {
        Movie(id: id,
              title: title,
              posterPath: posterPath,
              overview: overview,
              releaseDate: releaseDate,
              voteAverage: "")
    }
}
