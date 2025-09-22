import SwiftUI

struct MoviesListView: View {
    @StateObject var viewModel: ObservableMoviesListViewModel
    @State private var isRefreshing = false

    init(viewModel: ObservableMoviesListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ZStack {
                DSColors.backgroundSwiftUI
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
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)

            Spacer()

            themeToggleButton
        }
        .padding(.bottom, DSSpacing.sm)
    }

    private var themeToggleButton: some View {
        Button(action: {
            DSThemeManager.shared.toggleTheme()
        }) {
            Image(systemName: "moon.fill")
                .font(.title2)
                .foregroundColor(DSColors.accentSwiftUI)
        }
    }

    private var loadingNextPageView: some View {
        HStack {
            DSLoadingSpinner()
            Text("Loading more movies...")
                .font(DSTypography.bodySmallSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)
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
struct MoviesListView_Previews: PreviewProvider {
    static var previews: some View {
        let container = AppContainer.shared

        let viewModel = ObservableMoviesListViewModel(
            searchMoviesUseCase: container.searchMoviesUseCase(),
            trendingMoviesUseCase: container.trendingMoviesUseCase()
        )

        return MoviesListView(viewModel: viewModel)
    }
}