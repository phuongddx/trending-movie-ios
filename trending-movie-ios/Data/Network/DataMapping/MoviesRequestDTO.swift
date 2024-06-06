//
//  MoviesRequestDTO.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation

struct MoviesRequestDTO: Encodable {
    let query: String
    let page: Int
}
