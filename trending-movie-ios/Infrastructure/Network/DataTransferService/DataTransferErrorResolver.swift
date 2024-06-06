//
//  DataTransferErrorResolver.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation

protocol DataTransferErrorResolver {
    func resolve(error: NetworkError) -> Error
}

// MARK: - Error Resolver
class DefaultDataTransferErrorResolver: DataTransferErrorResolver {
    func resolve(error: NetworkError) -> Error {
        return error
    }
}
