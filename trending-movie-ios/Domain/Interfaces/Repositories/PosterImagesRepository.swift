//
//  PosterImagesRepository.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation

typealias ImagesResult = (Result<Data, Error>) -> Void
protocol PosterImagesRepository {
    func fetchImage(with imagePath: String,
                    completion: @escaping ImagesResult) -> Cancellable?
}
