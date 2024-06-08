//
//  Debouncer.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 8/6/24.
//

import Foundation

/// An object to help with debouncing rapidly changing inputs, eg. user entering search terms
/// only the latest command wiill be fired on the userInteractive thread once cooldown has passed
final class Debouncer {
    private let queue: DispatchQueue = DispatchQueue.global(qos: .userInteractive)
    private let delay: TimeInterval
    private var task: DispatchWorkItem?

    init(delay: TimeInterval) {
        self.delay = delay
    }

    /// Fire a call after a set interval only if no subsequent call is made before interval is over
    /// eg. if delay is 1 seconds. app will wait for 1 second before executing closure
    /// - Parameter action: block that will be invoked after delay has passed without any other invocation of `fire`
    func fire(action: @escaping () -> Void) {
        task?.cancel()
        task = DispatchWorkItem(block: action)
        queue.asyncAfter(deadline: .now() + delay, execute: task!)
    }

    /// Cancel any pending task
    func reset() {
        task?.cancel()
        task = nil
    }

}
