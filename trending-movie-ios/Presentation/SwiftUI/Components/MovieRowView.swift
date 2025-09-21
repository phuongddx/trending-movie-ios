import SwiftUI

@available(iOS 15.0, *)
struct MovieRowView: View {
    let movie: MoviesListItemViewModel
    @Environment(\.dsTheme) private var theme
    @State private var posterImage: UIImage?
    @State private var imageLoadTask: Cancellable?

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            posterImageView
            movieInfoView
            Spacer()
        }
        .padding(DSSpacing.Padding.card)
        .background(DSColors.secondaryBackgroundSwiftUI(for: theme))
        .cornerRadius(DSSpacing.CornerRadius.card)
        .onAppear {
            loadPosterImage()
        }
        .onDisappear {
            imageLoadTask?.cancel()
        }
    }

    private var posterImageView: some View {
        Group {
            if let posterImage = posterImage {
                Image(uiImage: posterImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(DSColors.shimmerBackground(for: theme).swiftUIColor)
                    .overlay(
                        DSLoadingSpinner()
                            .scaleEffect(0.5)
                    )
            }
        }
        .frame(width: 60, height: 90)
        .cornerRadius(DSSpacing.CornerRadius.medium)
        .clipped()
    }

    private var movieInfoView: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(movie.title)
                .font(DSTypography.headlineSwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                .lineLimit(2)

            Text(movie.releaseDate)
                .font(DSTypography.subheadlineSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                .lineLimit(1)

            Text(movie.voteAverage)
                .font(DSTypography.caption1SwiftUI())
                .foregroundColor(DSColors.accentSwiftUI(for: theme))
                .lineLimit(1)

            if !movie.overview.isEmpty {
                Text(movie.overview)
                    .font(DSTypography.caption1SwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                    .lineLimit(3)
                    .padding(.top, DSSpacing.xxs)
            }
        }
    }

    private func loadPosterImage() {
        imageLoadTask = movie.loadPosterImage { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    posterImage = UIImage(data: data)
                case .failure:
                    posterImage = UIImage(named: "placeholder-bg")
                }
            }
        }
    }
}

@available(iOS 13.0, *)
struct EmptyMoviesView: View {
    @Environment(\.dsTheme) private var theme
    let message: String

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            Image(systemName: "film")
                .font(.system(size: 60))
                .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))

            Text(message)
                .font(DSTypography.bodySwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
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
@available(iOS 15.0, *)
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
            ),
            posterImagesRepository: AppContainer.shared.posterImagesRepository()
        )

        return VStack {
            MovieRowView(movie: mockMovie)
            MovieRowSkeleton()
            EmptyMoviesView(message: "No movies found")
        }
        .padding()
        .background(DSColors.primaryBackgroundSwiftUI(for: .dark))
        .environment(\.dsTheme, .dark)
        .previewLayout(.sizeThatFits)
    }
}