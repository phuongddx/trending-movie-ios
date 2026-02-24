import Foundation

public struct MovieFilters: Equatable, Codable, Hashable {
    public var genres: Set<Int>
    public var yearRange: ClosedRange<Int>
    public var minimumRating: Double
    public var sortBy: SortOption

    public init(
        genres: Set<Int> = [],
        yearRange: ClosedRange<Int>? = nil,
        minimumRating: Double = 0,
        sortBy: SortOption = .popularity
    ) {
        self.genres = genres
        let currentYear = Calendar.current.component(.year, from: Date())
        self.yearRange = yearRange ?? 1990...currentYear
        self.minimumRating = minimumRating
        self.sortBy = sortBy
    }

    public var isActive: Bool {
        let currentYear = Calendar.current.component(.year, from: Date())
        let defaultRange = 1990...currentYear
        return !genres.isEmpty ||
               minimumRating > 0 ||
               sortBy != .popularity ||
               yearRange != defaultRange
    }

    public static let `default` = MovieFilters()

    public var cacheKey: String {
        let genresKey = genres.sorted().map(String.init).joined(separator: "_")
        return "\(sortBy.rawValue)_\(genresKey)_\(minimumRating)_\(yearRange.lowerBound)-\(yearRange.upperBound)"
    }
}

public enum SortOption: String, CaseIterable, Codable, Identifiable {
    case popularity = "popularity.desc"
    case rating = "vote_average.desc"
    case newest = "release_date.desc"
    case title = "original_title.asc"
    case oldest = "release_date.asc"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .popularity: return "Most Popular"
        case .rating: return "Highest Rated"
        case .newest: return "Newest First"
        case .title: return "Title A-Z"
        case .oldest: return "Oldest First"
        }
    }
}
