//
//  UseCase.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation

protocol UseCase {
    @discardableResult
    func start() -> Cancellable?
}
