//
//  PosterImagesRepositoryMock.swift
//  trending-movie-iosTests
//
//  Created by PhuongDoan on 7/6/24.
//

import Foundation
@testable import trending_movie_ios

class PosterImagesRepositoryMock: PosterImagesRepository {
    var completionCalls = 0
    var error: Error?
    var image = Data()
    var validateInput: ((String, Int) -> Void)?
    
    func fetchImage(with imagePath: String, width: Int, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        validateInput?(imagePath, width)
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(image))
        }
        completionCalls += 1
        return nil
    }
}
