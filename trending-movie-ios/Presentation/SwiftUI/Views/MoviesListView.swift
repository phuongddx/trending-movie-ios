import SwiftUI

struct MoviesListView: View {
    @StateObject var viewModel: ObservableMoviesListViewModel
    @State private var isRefreshing = false
    @State private var showFilterSheet = false

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
            .sheet(isPresented: $showFilterSheet) {
                MoviesFilterView(filters: $viewModel.activeFilters)
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
            moviesContent
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

    // MARK: - Movies Content with View Mode Toggle
    @ViewBuilder
    private var moviesContent: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.md) {
                headerView

                // Active filters bar
                if viewModel.searchQuery.isEmpty {
                    ActiveFiltersBar(
                        filters: $viewModel.activeFilters,
                        showFilterSheet: $showFilterSheet
                    )
                    .padding(.bottom, DSSpacing.sm)
                }

                // Conditional content based on view mode
                switch viewModel.viewMode {
                case .list:
                    moviesListView
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity
                        ))
                case .grid:
                    moviesGridView
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity
                        ))
                }

                if viewModel.loading == .nextPage {
                    loadingNextPageView
                }
            }
            .padding(DSSpacing.Padding.container)
        }
        .animation(
            UIAccessibility.isReduceMotionEnabled ? .none : .easeInOut(duration: 0.25),
            value: viewModel.viewMode
        )
    }

    // MARK: - List View
    private var moviesListView: some View {
        ForEach(Array(viewModel.movies.enumerated()), id: \.element.id) { index, movie in
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
    }

    // MARK: - Grid View
    private var moviesGridView: some View {
        let columns = [
            GridItem(.adaptive(minimum: 135, maximum: 180), spacing: DSSpacing.md)
        ]

        return LazyVGrid(columns: columns, spacing: DSSpacing.md) {
            ForEach(Array(viewModel.movies.enumerated()), id: \.element.id) { index, movie in
                MovieCard(movie: movie, style: .standard) {
                    viewModel.selectMovie(at: index)
                }
                .onAppear {
                    if index == viewModel.movies.count - 3 {
                        viewModel.loadNextPage()
                    }
                }
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text(viewModel.moviesListHeaderTitle)
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)

            Spacer()

            // View mode toggle
            ViewModeToggle(mode: $viewModel.viewMode)

            // Filter button (only when not searching)
            if viewModel.searchQuery.isEmpty {
                Button(action: { showFilterSheet = true }) {
                    Image(systemName: viewModel.activeFilters.isActive
                        ? "line.3.horizontal.decrease.circle.fill"
                        : "line.3.horizontal.decrease.circle")
                        .font(.title2)
                        .foregroundColor(viewModel.activeFilters.isActive
                            ? DSColors.accentSwiftUI
                            : DSColors.secondaryTextSwiftUI)
                }
                .accessibilityLabel(viewModel.activeFilters.isActive
                    ? "Open filters, \(viewModel.activeFilters.activeChips.count) filters active"
                    : "Open filters")
            }

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
        .accessibilityLabel("Toggle theme")
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
            trendingMoviesUseCase: container.trendingMoviesUseCase(),
            discoverMoviesUseCase: container.discoverMoviesUseCase()
        )

        return MoviesListView(viewModel: viewModel)
    }
}