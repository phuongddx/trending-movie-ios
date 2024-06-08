//
//  MoviesListItemViewModel.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation

struct MoviesListItemViewModel: Equatable {
    let title: String
    let overview: String
    let releaseDate: String
    let voteAverage: String
    let posterImagePath: String?

    init(movie: Movie) {
        self.title = movie.title ?? ""
        self.posterImagePath = movie.posterPath
        self.overview = movie.overview ?? ""
        if let releaseDate = movie.releaseDate {
            self.releaseDate = "\(NSLocalizedString("Release Date", comment: "")): \(dateFormatter.string(from: releaseDate))"
        } else {
            self.releaseDate = NSLocalizedString("To be announced", comment: "")
        }
        if let voteAverage = movie.voteAverage {
            self.voteAverage = "\(NSLocalizedString("Vote Average: \(voteAverage)", comment: ""))"
        } else {
            self.voteAverage = "\(NSLocalizedString("Have no rating now", comment: ""))"
        }
    }

    func displayText() -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(title.attributedText(textColor: .white, textFont: .systemFont(ofSize: 16, weight: .semibold)))
        result.appendNewline()
        result.appendNewline()
        result.append(releaseDate.attributedText(textColor: .white, textFont: .systemFont(ofSize: 14, weight: .regular)))
        result.appendNewline()
        result.append(voteAverage.attributedText(textColor: .white, textFont: .systemFont(ofSize: 14, weight: .regular)))
        return result
    }

    func displayOverviewText() -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(overview.attributedText(textColor: .white, textFont: .systemFont(ofSize: 14, weight: .regular)))
        result.appendNewline()
        result.appendNewline()
        result.append(releaseDate.attributedText(textColor: .white, textFont: .systemFont(ofSize: 14, weight: .regular)))
        result.appendNewline()
        result.append(voteAverage.attributedText(textColor: .white, textFont: .systemFont(ofSize: 14, weight: .regular)))
        return result
    }
}

extension NSMutableAttributedString {
    func appendNewline() {
        append(NSAttributedString(string: "\n"))
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
