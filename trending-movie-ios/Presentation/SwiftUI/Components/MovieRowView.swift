import SwiftUI

struct MovieRowView: View {
    let movie: MoviesListItemViewModel

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            posterImageView
            movieInfoView
            Spacer()
        }
        .padding(DSSpacing.Padding.card)
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(DSSpacing.CornerRadius.card)
    }

    private var posterImageView: some View {
        MoviePosterImage.compact(posterPath: movie.posterImagePath)
            .frame(width: 60, height: 90)
    }

    private var movieInfoView: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(movie.title)
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)
                .lineLimit(2)

            Text(movie.releaseDate)
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .lineLimit(1)

            Text(movie.voteAverage)
                .font(DSTypography.bodySmallSwiftUI())
                .foregroundColor(DSColors.accentSwiftUI)
                .lineLimit(1)

            if !movie.overview.isEmpty {
                Text(movie.overview)
                    .font(DSTypography.bodySmallSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .lineLimit(3)
                    .padding(.top, DSSpacing.xxs)
            }
        }
    }

}

@available(iOS 13.0, *)
struct EmptyMoviesView: View {
    let message: String

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            Image(systemName: "film")
                .font(.system(size: 60))
                .foregroundColor(DSColors.secondaryTextSwiftUI)

            Text(message)
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .multilineTextAlignment(.center)
        }
        .padding(DSSpacing.xxl)
    }
}

@available(iOS 13.0, *)
struct MovieRowSkeleton: View {
    var body: some View {
        DSMovieCardSkeleton()
            .background(Color.clear)
    }
}

// MARK: - Preview
struct MovieRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock data for preview
        let mockMovie = MoviesListItemViewModel(
            movie: Movie(
                id: "1",
                title: "Sample Movie",
                posterPath: nil,
                overview: "This is a sample movie overview that shows multiple lines of text.",
                releaseDate: Date(),
                voteAverage: "8.5"
            )
        )

        return VStack {
            MovieRowView(movie: mockMovie)
            MovieRowSkeleton()
            EmptyMoviesView(message: "No movies found")
        }
        .padding()
        .background(DSColors.backgroundSwiftUI)
        .previewLayout(.sizeThatFits)
    }
}