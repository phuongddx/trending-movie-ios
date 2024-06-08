//
//  trending_movie_iosUITests.swift
//  trending-movie-iosUITests
//
//  Created by PhuongDoan on 5/6/24.
//

import XCTest
@testable import trending_movie_ios

final class trending_movie_iosUITests: XCTestCase {
    override func setUp() {

        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testAppLaunchesAndSearchFieldExists() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.searchFields[AccessibilityIdentifier.searchField].exists)
    }

    func testAppLaunchesAndMovieCellExists() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.cells[AccessibilityIdentifier.movieCell].exists)
    }
}
