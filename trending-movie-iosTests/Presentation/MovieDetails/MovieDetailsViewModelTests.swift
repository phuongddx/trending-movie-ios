//
//  MovieDetailsViewModelTests.swift
//  trending-movie-iosTests
//
//  Created by PhuongDoan on 7/6/24.
//

import Foundation
import XCTest
@testable import trending_movie_ios

final class MovieDetailsViewModelTests: XCTestCase {
    var sut: DefaultMovieDetailsViewModel!
    var detailsUseCaseMock: FetchDetailsMovieUseCasemock!
    var posterImagesRepositoryMock: PosterImagesRepositoryMock!
    var mainQueue: DispatchQueueType!

    override func setUp() {
        super.setUp()
        detailsUseCaseMock = FetchDetailsMovieUseCasemock()
        posterImagesRepositoryMock = PosterImagesRepositoryMock()
        mainQueue = DispatchQueueTypeMock()
        sut = DefaultMovieDetailsViewModel(
            movieId: "movieId",
            detailsMovieUseCase: detailsUseCaseMock,
            posterImagesRepository: posterImagesRepositoryMock,
            mainQueue: mainQueue
        )
    }

    override func tearDown() {
        sut = nil
        detailsUseCaseMock = nil
        posterImagesRepositoryMock = nil
        mainQueue = nil
        super.tearDown()
    }

    func test_viewDidLoadInvokesLoadDetails() {
        // Given
        let expectation = self.expectation(description: "Load details invoked")
        detailsUseCaseMock.result = .success(mockMoviesResponseDTO.movies.first!)
        // When
        sut.viewDidLoad()

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.movie.value?.title, "Movie Title 1")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
    }

    func test_loadDetailsWithSuccess() {
        // Given
        let expectation = self.expectation(description: "Details loaded")
        detailsUseCaseMock.result = .success(mockMoviesResponseDTO.movies.first!)

        // When
        sut.loadDetails()

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testLoadDetailsWithFailure() {
        // Given
        let expectation = self.expectation(description: "Details loading failed")
        detailsUseCaseMock.result = .failure(NSError(domain: "TestError", code: -1, userInfo: nil))

        // When
        sut.loadDetails()

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.error.value, NSLocalizedString("Failed loading movies", comment: ""))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUpdatePosterImageWithSuccess() {
        // Given
        let expectation = self.expectation(description: "Poster image loaded")

        // When
        sut.updatePosterImage(posterImagePath: "testPath")

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.sut.posterImage.value)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
    }

    func testUpdatePosterImageWithFailure() {
        // Given
        let expectation = self.expectation(description: "Poster image loading failed")
        posterImagesRepositoryMock.shouldReturnError = true

        // When
        sut.updatePosterImage(posterImagePath: "testPath")

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(self.sut.posterImage.value)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
    }
}

let mockMoviesResponseDTO = MoviesResponseDTO(
    page: 1,
    totalPages: 10,
    movies: [
        MoviesResponseDTO.MovieDTO(
            id: 1,
            title: "Movie Title 1",
            posterPath: "/path/to/poster1.jpg",
            overview: "Overview of the first movie.",
            releaseDate: "2023-01-01",
            voteAverage: 7.5
        ),
        MoviesResponseDTO.MovieDTO(
            id: 2,
            title: "Movie Title 2",
            posterPath: "/path/to/poster2.jpg",
            overview: "Overview of the second movie.",
            releaseDate: "2023-02-01",
            voteAverage: 8.0
        ),
        MoviesResponseDTO.MovieDTO(
            id: 3,
            title: "Movie Title 3",
            posterPath: "/path/to/poster3.jpg",
            overview: "Overview of the third movie.",
            releaseDate: "2023-03-01",
            voteAverage: 6.5
        )
    ]
)

class FetchDetailsMovieUseCasemock: FetchDetailsMovieUseCase {
    var result: Result<MovieDetailsResponseDTO?, any Error>?

    func execute(with movieId: Movie.Identifier,
                 completion: @escaping DetailsMovieResult) -> (any Cancellable)? {
        if let result = result {
                    completion(result)
        } else {
            completion(.failure(NSError(domain: "FetchDetailsMovieUseCasemock",
                                        code: -1, userInfo: [NSLocalizedDescriptionKey: "No result set"])))
        }
        return nil
    }
}

