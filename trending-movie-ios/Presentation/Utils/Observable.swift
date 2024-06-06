//
//  Observable.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation

final class Observable<Value> {
    
    private struct Observer {
        weak var observer: AnyObject?
        let block: (Value) -> Void
    }
    
    private var observers = [Observer]()
    private let queue = DispatchQueue(label: "observable.queue", attributes: .concurrent)
    
    var value: Value {
        didSet {
            notifyObservers()
        }
    }
    
    init(_ value: Value) {
        self.value = value
    }
    
    func observe(on observer: AnyObject, observerBlock: @escaping (Value) -> Void) {
        queue.async(flags: .barrier) { [weak self] in
            self?.observers.append(Observer(observer: observer, block: observerBlock))
        }
        observerBlock(self.value)
    }
    
    func remove(observer: AnyObject) {
        queue.async(flags: .barrier) { [weak self] in
            self?.observers = self?.observers.filter { $0.observer !== observer } ?? []
        }
    }
    
    private func notifyObservers() {
        queue.sync {
            observers = observers.filter { $0.observer != nil }
            for observer in observers {
                observer.block(value)
            }
        }
    }
}
