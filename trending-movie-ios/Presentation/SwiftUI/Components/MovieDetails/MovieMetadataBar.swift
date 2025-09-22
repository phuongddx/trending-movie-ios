import SwiftUI

struct MovieMetadataBar: View {
    let movie: Movie

    private var year: String {
        if let releaseDate = movie.releaseDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            return formatter.string(from: releaseDate)
        }
        return "2021"
    }

    private var runtime: String {
        if let runtime = movie.runtime, runtime > 0 {
            return "\(runtime) Minutes"
        }
        return "148 Minutes"
    }

    private var genre: String {
        if let genres = movie.genres, let firstGenre = genres.first {
            return firstGenre
        }
        return "Action"
    }

    private var rating: Double {
        if let voteAverage = movie.voteAverage,
           let ratingValue = Double(voteAverage) {
            return ratingValue
        }
        return 4.5
    }

    var body: some View {
        HStack(spacing: 0) {
            // Metadata items container with background
            HStack(spacing: 12) {
                MetadataItem(
                    icon: "calendar",
                    text: year,
                    iconColor: DSColors.secondaryTextSwiftUI
                )

                MetadataDivider()

                MetadataItem(
                    icon: "clock",
                    text: runtime,
                    iconColor: DSColors.secondaryTextSwiftUI
                )

                MetadataDivider()

                MetadataItem(
                    icon: "film",
                    text: genre,
                    iconColor: DSColors.secondaryTextSwiftUI
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(DSColors.surfaceSwiftUI)
            .cornerRadius(12)

            Spacer()

            // Rating badge
            RatingBadge(rating: rating)
        }
        .padding(.horizontal, 24)
    }
}

struct MovieMetadataBar_Previews: PreviewProvider {
    static var previews: some View {
        let mockMovie = Movie(
            id: "1",
            title: "Sample Movie",
            posterPath: "/sample-poster.jpg",
            overview: "Sample overview",
            releaseDate: Date(),
            voteAverage: "8.5",
            genres: ["Action", "Adventure"],
            runtime: 148
        )

        ZStack {
            DSColors.backgroundSwiftUI.ignoresSafeArea()

            MovieMetadataBar(movie: mockMovie)
        }
    }
}