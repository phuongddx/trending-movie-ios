import SwiftUI

struct MovieMetadata: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            // Duration and Director
            HStack(spacing: DSSpacing.md) {
                if let runtime = movie.runtime {
                    Label(formatDuration(runtime), systemImage: "clock")
                        .font(DSTypography.bodySmallSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                }

                if let director = movie.director {
                    Label(director, systemImage: "person.circle")
                        .font(DSTypography.bodySmallSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                        .lineLimit(1)
                }
            }

            // Age rating and genres
            HStack(spacing: DSSpacing.sm) {
                if let certification = movie.certification, !certification.isEmpty {
                    AgeRatingBadge(rating: certification)
                }

                if let genres = movie.genres, !genres.isEmpty {
                    Text(genres.prefix(3).joined(separator: " • "))
                        .font(DSTypography.bodySmallSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                        .lineLimit(1)
                }
            }

            // Rating and vote count
            if let voteAverage = movie.voteAverage, let voteCount = movie.voteCount {
                HStack(spacing: DSSpacing.sm) {
                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)

                        Text(voteAverage)
                            .font(DSTypography.bodySmallSwiftUI(weight: .medium))
                            .foregroundColor(DSColors.primaryTextSwiftUI)
                    }
                    .padding(.horizontal, DSSpacing.xs)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(4)

                    Text("(\(formatVoteCount(voteCount)) reviews)")
                        .font(DSTypography.captionSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                }
            }

            // Release date
            if let releaseDate = movie.releaseDate {
                Label(dateFormatter.string(from: releaseDate), systemImage: "calendar")
                    .font(DSTypography.captionSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
            }
        }
    }

    // MARK: - Helper Methods

    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }

    private func formatVoteCount(_ count: Int) -> String {
        if count >= 1000 {
            let thousands = Double(count) / 1000.0
            return String(format: "%.1fk", thousands)
        } else {
            return "\(count)"
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: - Compact Variant

struct MovieMetadataCompact: View {
    let movie: Movie

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            // Rating
            if let voteAverage = movie.voteAverage {
                HStack(spacing: DSSpacing.xxs) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)

                    Text(voteAverage)
                        .font(DSTypography.captionSwiftUI(weight: .medium))
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                }
            }

            // Duration
            if let runtime = movie.runtime {
                Text("•")
                    .foregroundColor(DSColors.secondaryTextSwiftUI)

                Text(formatDuration(runtime))
                    .font(DSTypography.captionSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
            }

            // Age rating
            if let certification = movie.certification, !certification.isEmpty {
                Text("•")
                    .foregroundColor(DSColors.secondaryTextSwiftUI)

                Text(certification)
                    .font(DSTypography.captionSwiftUI(weight: .medium))
                    .foregroundColor(DSColors.accentSwiftUI)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(DSColors.accentSwiftUI.opacity(0.2))
                    .cornerRadius(2)
            }

            Spacer()
        }
    }

    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }
}

// MARK: - Detailed Variant

struct MovieMetadataDetailed: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Primary metadata
            MovieMetadata(movie: movie)

            // Additional details
            if hasAdditionalDetails {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    if let status = movie.status {
                        metadataRow(title: "Status", value: status)
                    }

                    if let productionCountries = movie.productionCountries, !productionCountries.isEmpty {
                        metadataRow(title: "Countries", value: productionCountries.joined(separator: ", "))
                    }

                    if let spokenLanguages = movie.spokenLanguages, !spokenLanguages.isEmpty {
                        metadataRow(title: "Languages", value: spokenLanguages.joined(separator: ", "))
                    }

                    if let budget = movie.budget, budget > 0 {
                        if let budgetString = currencyFormatter.string(from: NSNumber(value: budget)) {
                            metadataRow(title: "Budget", value: budgetString)
                        }
                    }

                    if let revenue = movie.revenue, revenue > 0 {
                        if let revenueString = currencyFormatter.string(from: NSNumber(value: revenue)) {
                            metadataRow(title: "Box Office", value: revenueString)
                        }
                    }
                }
            }
        }
    }

    private var hasAdditionalDetails: Bool {
        movie.status != nil ||
        (movie.productionCountries?.isEmpty == false) ||
        (movie.spokenLanguages?.isEmpty == false) ||
        (movie.budget ?? 0) > 0 ||
        (movie.revenue ?? 0) > 0
    }

    private func metadataRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(DSTypography.captionSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .frame(width: 80, alignment: .leading)

            Text(value)
                .font(DSTypography.captionSwiftUI())
                .foregroundColor(DSColors.primaryTextSwiftUI)
                .lineLimit(1)

            Spacer()
        }
    }

    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

// MARK: - Previews

struct MovieMetadata_Previews: PreviewProvider {
    static var previews: some View {
        let mockMovie = Movie(
            id: "1",
            title: "Sample Movie",
            posterPath: nil,
            overview: "A great movie",
            releaseDate: Date(),
            voteAverage: "8.5",
            genres: ["Action", "Adventure", "Sci-Fi"],
            runtime: 148,
            productionCountries: ["United States"],
            spokenLanguages: ["English"],
            budget: 100000000,
            revenue: 500000000,
            status: "Released",
            tagline: nil,
            homepage: nil,
            certification: "PG-13",
            director: "Christopher Nolan",
            voteCount: 15420,
            videos: nil,
            images: nil,
            credits: nil
        )

        VStack(spacing: DSSpacing.lg) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Standard Metadata")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                MovieMetadata(movie: mockMovie)
            }

            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Compact Metadata")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                MovieMetadataCompact(movie: mockMovie)
            }

            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Detailed Metadata")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                MovieMetadataDetailed(movie: mockMovie)
            }
        }
        .padding()
        .background(DSColors.backgroundSwiftUI)
    }
}