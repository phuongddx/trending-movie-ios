//
//  DispatchQueueTypeMock.swift
//  trending-movie-iosTests
//
//  Created by PhuongDoan on 6/6/24.
//

@testable import trending_movie_ios

final class DispatchQueueTypeMock: DispatchQueueType {
    func async(execute work: @escaping () -> Void) {
        work()
    }
}
