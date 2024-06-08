//
//  MoviesListViewModelActions.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 8/6/24.
//

import Foundation

protocol MoviesListViewModelActionsProtocol {
    var showMovieDetails: ((Movie) -> Void)? { get }
}

struct TrendingMoviesListViewModelActions: MoviesListViewModelActionsProtocol {
    var showMovieDetails: ((Movie) -> Void)?
}

