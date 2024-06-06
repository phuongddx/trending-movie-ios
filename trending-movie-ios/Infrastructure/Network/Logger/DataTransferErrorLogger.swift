//
//  DataTransferErrorLogger.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation
protocol DataTransferErrorLogger {
    func log(error: Error)
}

final class DefaultDataTransferErrorLogger: DataTransferErrorLogger {
    func log(error: Error) {
        printIfDebug("-------------")
        printIfDebug("\(error)")
    }
}
