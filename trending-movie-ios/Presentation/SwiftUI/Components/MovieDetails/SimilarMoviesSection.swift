import SwiftUI

struct SimilarMoviesSection: View {
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void

    private var displayMovies: [Movie] {
        Array(movies.prefix(10))
    }

    var body: some View {
        if !movies.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("More Like This")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                    .foregroundColor(.white)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(displayMovies) { movie in
                            SimilarMovieCard(movie: movie) {
                                onMovieTap(movie)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal, -24)
            }
        }
    }
}

struct SimilarMovieCard: View {
    let movie: Movie
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Poster
                if let posterPath = movie.posterPath {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)")) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle().fill(DSColors.surfaceSwiftUI)
                    }
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Rectangle()
                        .fill(DSColors.surfaceSwiftUI)
                        .frame(width: 120, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            Image(systemName: "film")
                                .font(.system(size: 32))
                                .foregroundColor(.gray)
                        )
                }

                // Title
                Text(movie.title ?? "Unknown")
                    .font(DSTypography.h6SwiftUI(weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .frame(width: 120, alignment: .leading)

                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text(movie.voteAverage ?? "N/A")
                        .font(DSTypography.captionSwiftUI(weight: .medium))
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                }
            }
        }
    }
}
