import SwiftUI

@available(iOS 15.0, *)
struct MovieDetailsView: View {
    @StateObject var viewModel: ObservableMovieDetailsViewModel
    @Environment(\.dsTheme) private var theme
    @Environment(\.presentationMode) var presentationMode

    init(viewModel: ObservableMovieDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            DSColors.primaryBackgroundSwiftUI(for: theme)
                .ignoresSafeArea()

            if viewModel.loading == .fullScreen {
                loadingView
            } else {
                contentView
            }
        }
        .navigationTitle(viewModel.screenTitle)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.refreshDetails()
        }
        .alert(viewModel.error, isPresented: $viewModel.isShowingError) {
            Button("OK") {
                viewModel.isShowingError = false
            }
        }
        .onAppear {
            viewModel.viewDidLoad()
        }
    }

    private var loadingView: some View {
        VStack(spacing: DSSpacing.lg) {
            // Poster skeleton
            DSSkeletonView(
                width: UIScreen.main.bounds.width - (DSSpacing.Padding.container * 2),
                height: UIScreen.main.bounds.height * 2 / 3,
                cornerRadius: DSSpacing.CornerRadius.large
            )

            VStack(alignment: .leading, spacing: DSSpacing.md) {
                // Title skeleton
                DSSkeletonView(width: 250, height: 24)

                // Details skeletons
                DSSkeletonView(width: 180, height: 16)
                DSSkeletonView(width: 150, height: 16)

                // Overview skeletons
                DSSkeletonView(width: UIScreen.main.bounds.width - (DSSpacing.Padding.container * 2), height: 16)
                DSSkeletonView(width: UIScreen.main.bounds.width - (DSSpacing.Padding.container * 2), height: 16)
                DSSkeletonView(width: 200, height: 16)
            }

            Spacer()
        }
        .padding(DSSpacing.Padding.container)
    }

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                posterImageView
                movieDetailsContent
            }
            .padding(DSSpacing.Padding.container)
        }
    }

    private var posterImageView: some View {
        Group {
            if let posterImage = viewModel.posterImage {
                Image(uiImage: posterImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Rectangle()
                    .fill(DSColors.shimmerBackground(for: theme).swiftUIColor)
                    .aspectRatio(2/3, contentMode: .fit)
                    .overlay(
                        VStack(spacing: DSSpacing.md) {
                            DSLoadingSpinner()
                            Text("Loading poster...")
                                .font(DSTypography.caption1SwiftUI())
                                .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                        }
                    )
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 2 / 3)
        .cornerRadius(DSSpacing.CornerRadius.large)
        .clipped()
    }

    private var movieDetailsContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            movieTitleSection
            movieMetadataSection
            movieOverviewSection
            Spacer(minLength: DSSpacing.xxl)
        }
    }

    private var movieTitleSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(viewModel.movieTitle)
                .font(DSTypography.title1SwiftUI(weight: .bold))
                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                .lineLimit(nil)

            HStack {
                ratingView
                Spacer()
                favoriteButton
            }
        }
    }

    private var ratingView: some View {
        HStack(spacing: DSSpacing.xxs) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(DSTypography.caption1SwiftUI())

            Text(viewModel.voteAverage)
                .font(DSTypography.subheadlineSwiftUI(weight: .medium))
                .foregroundColor(DSColors.accentSwiftUI(for: theme))
        }
    }

    private var favoriteButton: some View {
        Button(action: {
            // TODO: Implement favorite functionality
        }) {
            Image(systemName: "heart")
                .font(.title2)
                .foregroundColor(DSColors.accentSwiftUI(for: theme))
        }
    }

    private var movieMetadataSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Details")
                .font(DSTypography.title3SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                metadataRow(title: "Release Date", value: viewModel.releaseDate)
            }
        }
        .padding(DSSpacing.Padding.card)
        .background(DSColors.secondaryBackgroundSwiftUI(for: theme))
        .cornerRadius(DSSpacing.CornerRadius.card)
    }

    private func metadataRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(DSTypography.subheadlineSwiftUI(weight: .medium))
                .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))

            Spacer()

            Text(value)
                .font(DSTypography.subheadlineSwiftUI())
                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
        }
    }

    private var movieOverviewSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("Overview")
                .font(DSTypography.title3SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

            if !viewModel.movieOverview.isEmpty {
                Text(viewModel.movieOverview)
                    .font(DSTypography.bodySwiftUI())
                    .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                    .lineSpacing(4)
            } else {
                Text("No overview available")
                    .font(DSTypography.bodySwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                    .italic()
            }
        }
    }
}

// MARK: - Preview
@available(iOS 15.0, *)
struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let mockMovie = Movie(
            id: "1",
            title: "Sample Movie Title That Is Very Long",
            posterPath: nil,
            overview: "This is a sample movie overview that provides detailed information about the plot, characters, and setting of the movie. It gives viewers an idea of what to expect when watching this film.",
            releaseDate: Date(),
            voteAverage: "8.5"
        )

        let viewModel = ObservableMovieDetailsViewModel(
            movie: mockMovie,
            fetchDetailsMovieUseCase: PreviewMockFetchDetailsMovieUseCase(),
            posterImagesRepository: PreviewMockPosterImagesRepository()
        )

        return NavigationView {
            MovieDetailsView(viewModel: viewModel)
        }
        .environment(\.dsTheme, DSTheme.dark)
        .environmentObject(DSThemeManager.shared)
    }
}

// MARK: - Preview Mock Classes
private class PreviewMockFetchDetailsMovieUseCase: FetchDetailsMovieUseCaseProtocol {
    func execute(with movieId: Movie.Identifier,
                completion: @escaping (Result<Movie, Error>) -> Void) -> Cancellable? {
        return nil
    }
}

private class PreviewMockPosterImagesRepository: PosterImagesRepository {
    func fetchImage(with imagePath: String, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        completion(.failure(NSError(domain: "Mock", code: 0)))
        return nil
    }
}
