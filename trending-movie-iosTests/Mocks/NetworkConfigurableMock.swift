//
//  NetworkConfigurableMock.swift
//  trending-movie-iosTests
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation
@testable import trending_movie_ios

class NetworkConfigurableMock: NetworkConfigurable {
    var baseURL: URL = URL(string: "https://mock.test.com")!
    var headers: [String: String] = [:]
    var queryParameters: [String: String] = [:]
}
