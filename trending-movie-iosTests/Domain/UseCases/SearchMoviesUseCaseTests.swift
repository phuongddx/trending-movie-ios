//
//  SearchMoviesUseCaseTests.swift
//  trending-movie-iosTests
//
//  Created by PhuongDoan on 6/6/24.
//

import XCTest
@testable import trending_movie_ios

final class SearchMoviesUseCaseTests: XCTestCase {
    static let moviesPages: [MoviesPage] = {
        let page1 = MoviesPage(page: 1, totalPages: 2, movies: [
            Movie.stub(id: "1", title: "title1", posterPath: "/1", overview: "overview1"),
            Movie.stub(id: "2", title: "title2", posterPath: "/2", overview: "overview2")])
        let page2 = MoviesPage(page: 2, totalPages: 2, movies: [
            Movie.stub(id: "3", title: "title3", posterPath: "/3", overview: "overview3")])
        return [page1, page2]
    }()
    
    enum MoviesRepositorySuccessTestError: Error {
        case failedFetching
    }
    
    func testSearchMoviesUseCase_whenFailedFetchingMoviesForQuery_thenQueryIsNotSavedInRecentQueries() {
        // given
        var useCaseCompletionCallsCountCount = 0
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        let useCase = DefaultSearchMoviesUseCase(
            moviesRepository: MoviesRepositoryMock(result: .failure(MoviesRepositorySuccessTestError.failedFetching)))
        
        // when
        let requestValue = SearchMoviesUseCaseRequestValue(query: MovieQuery(query: "title1"),
                                                           page: 0)
        _ = useCase.execute(requestValue: requestValue, cached: { _ in }) { _ in
            useCaseCompletionCallsCountCount += 1
        }
        // then
        var recents = [MovieQuery]()
        moviesQueriesRepository.fetchRecentsQueries(maxCount: 1) { result in
            recents = (try? result.get()) ?? []
        }
        XCTAssertTrue(recents.isEmpty)
        XCTAssertEqual(useCaseCompletionCallsCountCount, 1)
        XCTAssertEqual(moviesQueriesRepository.fetchCompletionCallsCount, 1)
    }
}

// MARK: - Mocks

class MoviesQueriesRepositoryMock: MoviesQueriesRepository {
    var recentQueries: [MovieQuery] = []
    var fetchCompletionCallsCount = 0
    
    func fetchRecentsQueries(maxCount: Int,
                             completion: @escaping (Result<[MovieQuery], Error>) -> Void) {
        completion(.success(recentQueries))
        fetchCompletionCallsCount += 1
    }
    func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, Error>) -> Void) {
        recentQueries.append(query)
    }
}

class MoviesRepositoryMock: MoviesRepository {
    func fetchTrendingMoviesList(requestDto: any MoviesRequestable,
                                 cached: @escaping (MoviesPage) -> Void,
                                 completion: @escaping MoviesPageResult) -> (any Cancellable)? {
        return nil
    }
    
    func fetchDetailsMovie(of movieId: Movie.Identifier,
                           completion: @escaping DetailsMovieResult) -> (any Cancellable)? {
        return nil
    }
    
    var result: Result<MoviesPage, Error>
    var fetchCompletionCallsCount = 0

    init(result: Result<MoviesPage, Error>) {
        self.result = result
    }

    func fetchMoviesList(query: MovieQuery,
                         page: Int,
                         cached: @escaping (MoviesPage) -> Void,
                         completion: @escaping MoviesPageResult) -> Cancellable? {
        completion(result)
        fetchCompletionCallsCount += 1
        return nil
    }
}
