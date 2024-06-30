//
//  DataTransferService.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation
import Resolver
import SwiftThemoviedbWrap

protocol DataTransferService {
}

// MARK: - Implementation
final class DefaultDataTransferService: DataTransferService {
    @Injected private var movieProvider: MoviesDataProvider

    func getTrendingList() {
        
    }
}
