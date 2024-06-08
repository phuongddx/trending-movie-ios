//
//  PosterImagesRepositoryMock.swift
//  trending-movie-iosTests
//
//  Created by PhuongDoan on 7/6/24.
//

import Foundation
@testable import trending_movie_ios

class PosterImagesRepositoryMock: PosterImagesRepository {
    var shouldReturnError = false

    func fetchImage(with imagePath: String, completion: @escaping ImagesResult) -> Cancellable? {
        if shouldReturnError {
            completion(.failure(ConnectionErrorMock()))
        } else {
            let mockData = Data()
            completion(.success(mockData))
        }
        return nil
    }
}

class ConnectionErrorMock: ConnectionError {
    var isInternetConnectionError: Bool = true
}
