//
//  NetworkSessionManagerMock.swift
//  trending-movie-iosTests
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation
@testable import trending_movie_ios

struct NetworkSessionManagerMock: NetworkSessionManager {
    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?
    
    func request(_ request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable {
        // Call completion handler with provided data, response, and error
        completion(data, response, error)
        
        // Return a dummy URLSessionDataTask using URLSession.shared
        return URLSession.shared.dataTask(with: request) { _, _, _ in }
    }
}
