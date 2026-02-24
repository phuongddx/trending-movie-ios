import SwiftUI

// MARK: - Filter Chip
struct FilterChip: Identifiable, Hashable {
    let id: String
    let label: String
    let category: FilterCategory
}

enum FilterCategory {
    case sort, genre, rating, year
}

// MARK: - Genre Name Helper
private func genreName(for id: Int) -> String? {
    let genreMap: [Int: String] = [
        28: "Action", 12: "Adventure", 16: "Animation", 35: "Comedy",
        80: "Crime", 99: "Documentary", 18: "Drama", 10751: "Family",
        14: "Fantasy", 36: "History", 27: "Horror", 10402: "Music",
        9648: "Mystery", 10749: "Romance", 878: "Science Fiction",
        53: "Thriller", 10752: "War", 37: "Western"
    ]
    return genreMap[id]
}

// MARK: - MovieFilters Extension for Active Chips
extension MovieFilters {
    var activeChips: [FilterChip] {
        var chips: [FilterChip] = []

        // Sort chip (if not default)
        if sortBy != .popularity {
            chips.append(FilterChip(
                id: "sort",
                label: "Sort: \(sortBy.displayName)",
                category: .sort
            ))
        }

        // Genre chips
        for genreId in genres {
            if let name = genreName(for: genreId) {
                chips.append(FilterChip(
                    id: "genre_\(genreId)",
                    label: name,
                    category: .genre
                ))
            }
        }

        // Rating chip
        if minimumRating > 0 {
            chips.append(FilterChip(
                id: "rating",
                label: "Rating: \(String(format: "%.1f", minimumRating))+",
                category: .rating
            ))
        }

        // Year chip
        let currentYear = Calendar.current.component(.year, from: Date())
        let defaultRange = 1990...currentYear
        if yearRange != defaultRange {
            if yearRange.lowerBound == yearRange.upperBound {
                chips.append(FilterChip(
                    id: "year",
                    label: "Year: \(yearRange.lowerBound)",
                    category: .year
                ))
            } else {
                chips.append(FilterChip(
                    id: "year",
                    label: "\(yearRange.lowerBound)-\(yearRange.upperBound)",
                    category: .year
                ))
            }
        }

        return chips
    }
}
