//
//  PosterImagesRepository.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation

protocol PosterImagesRepository {
    func fetchImage(with imagePath: String,
                    width: Int,
                    completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable?
}
