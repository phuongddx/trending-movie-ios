import SwiftUI

@available(iOS 15.0, *)
struct MoviesListView: View {
    @StateObject var viewModel: ObservableMoviesListViewModel
    @Environment(\.dsTheme) private var theme
    @State private var isRefreshing = false

    init(viewModel: ObservableMoviesListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ZStack {
                DSColors.primaryBackgroundSwiftUI(for: theme)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle(viewModel.screenTitle)
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchQuery, prompt: viewModel.searchBarPlaceholder)
            .refreshable {
                await refreshMovies()
            }
            .alert(viewModel.errorTitle, isPresented: $viewModel.isShowingError) {
                Button("OK") {
                    viewModel.isShowingError = false
                }
            } message: {
                Text(viewModel.error)
            }
            .onAppear {
                viewModel.viewDidLoad()
            }
        }
        .environmentObject(DSThemeManager.shared)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.loading == .fullScreen {
            loadingView
        } else if viewModel.shouldShowEmptyView {
            emptyView
        } else {
            moviesList
        }
    }

    private var loadingView: some View {
        VStack(spacing: DSSpacing.lg) {
            ForEach(0..<6, id: \.self) { _ in
                MovieRowSkeleton()
            }
        }
        .padding(DSSpacing.Padding.container)
    }

    private var emptyView: some View {
        EmptyMoviesView(
            message: NSLocalizedString("No movies found for your search", comment: "")
        )
    }

    private var moviesList: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.md) {
                headerView

                ForEach(Array(viewModel.movies.enumerated()), id: \.element.title) { index, movie in
                    MovieRowView(movie: movie)
                        .onTapGesture {
                            viewModel.selectMovie(at: index)
                        }
                        .onAppear {
                            if index == viewModel.movies.count - 3 {
                                viewModel.loadNextPage()
                            }
                        }
                }

                if viewModel.loading == .nextPage {
                    loadingNextPageView
                }
            }
            .padding(DSSpacing.Padding.container)
        }
    }

    private var headerView: some View {
        HStack {
            Text(viewModel.moviesListHeaderTitle)
                .font(DSTypography.title3SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

            Spacer()

            themeToggleButton
        }
        .padding(.bottom, DSSpacing.sm)
    }

    private var themeToggleButton: some View {
        Button(action: {
            DSThemeManager.shared.toggleTheme()
        }) {
            Image(systemName: theme == .dark ? "sun.max.fill" : "moon.fill")
                .font(.title2)
                .foregroundColor(DSColors.accentSwiftUI(for: theme))
        }
    }

    private var loadingNextPageView: some View {
        HStack {
            DSLoadingSpinner()
            Text("Loading more movies...")
                .font(DSTypography.caption1SwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
        }
        .padding(DSSpacing.lg)
    }

    private func refreshMovies() async {
        isRefreshing = true
        await viewModel.refreshMovies()
        isRefreshing = false
    }
}

// MARK: - Preview
@available(iOS 15.0, *)
struct MoviesListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockContainer = PreviewMockContainer()

        let viewModel = ObservableMoviesListViewModel(
            searchMoviesUseCase: mockContainer.searchMoviesUseCase(),
            trendingMoviesUseCase: mockContainer.trendingMoviesUseCase(),
            posterImagesRepository: mockContainer.posterImagesRepository()
        )

        return MoviesListView(viewModel: viewModel)
            .environment(\.dsTheme, DSTheme.dark)
    }
}

// MARK: - Mock Objects for Preview
private class PreviewMockContainer {
    func searchMoviesUseCase() -> SearchMoviesUseCaseProtocol { PreviewMockSearchMoviesUseCase() }
    func trendingMoviesUseCase() -> TrendingMoviesUseCaseProtocol { PreviewMockTrendingMoviesUseCase() }
    func posterImagesRepository() -> PosterImagesRepository { PreviewMockPosterImagesRepository() }
    func fetchDetailsMovieUseCase() -> FetchDetailsMovieUseCaseProtocol { PreviewMockFetchDetailsMovieUseCase() }
}

private class PreviewMockPosterImagesRepository: PosterImagesRepository {
    func fetchImage(with imagePath: String, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        completion(.failure(NSError(domain: "Mock", code: 0)))
        return nil
    }
}

private class PreviewMockSearchMoviesUseCase: SearchMoviesUseCaseProtocol {
    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                cached: @escaping (MoviesPage) -> Void,
                completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
        return nil
    }
}

private class PreviewMockTrendingMoviesUseCase: TrendingMoviesUseCaseProtocol {
    func execute(request: MoviesRequest,
                cached: @escaping (MoviesPage) -> Void,
                completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
        return nil
    }
}

private class PreviewMockFetchDetailsMovieUseCase: FetchDetailsMovieUseCaseProtocol {
    func execute(with movieId: Movie.Identifier,
                completion: @escaping (Result<Movie, Error>) -> Void) -> Cancellable? {
        return nil
    }
}