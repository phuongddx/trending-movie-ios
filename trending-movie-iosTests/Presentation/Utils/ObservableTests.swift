//
//  ObservableTests.swift
//  trending-movie-iosTests
//
//  Created by PhuongDoan on 5/6/24.
//

import XCTest
@testable import trending_movie_ios

class ObservableTests: XCTestCase {
    
    class TestObserver {
        var observedValue: Int?
    }
    
    func testObserverReceivesInitialValue() {
        let observable = Observable(10)
        let observer = TestObserver()
        
        let expectation = self.expectation(description: "Observer should receive initial value")
        
        observable.observe(on: observer) { value in
            observer.observedValue = value
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(observer.observedValue, 10)
        }
    }
    
    func testObserverReceivesUpdatedValue() {
        let observable = Observable(10)
        let observer = TestObserver()
        
        let expectation = self.expectation(description: "Observer should receive updated value")
        
        observable.observe(on: observer) { value in
            observer.observedValue = value
            if value == 20 {
                expectation.fulfill()
            }
        }
        
        observable.value = 20
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(observer.observedValue, 20)
        }
    }
    
    func testObserverDoesNotReceiveValueAfterRemoval() {
        let observable = Observable(10)
        let observer = TestObserver()
        
        observable.observe(on: observer) { value in
            observer.observedValue = value
        }
        
        observable.remove(observer: observer)
        
        observable.value = 30

        let expectation = self.expectation(description: "Wait for async code to execute")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(observer.observedValue, 10)
        }
    }
    
    func testObserverIsNotifiedOnMainThread() {
        let observable = Observable(10)
        let observer = TestObserver()
        
        let expectation = self.expectation(description: "Observer should be notified on main thread")
        var isFulfilled = false
        
        observable.observe(on: observer) { value in
            observer.observedValue = value
            if !isFulfilled && Thread.isMainThread {
                expectation.fulfill()
                isFulfilled = true
            }
        }
        
        observable.value = 20
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(observer.observedValue, 20)
        }
    }
}
