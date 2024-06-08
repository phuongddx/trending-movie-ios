//
//  MoviesListViewController.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import UIKit

final class MoviesListViewController: UIViewController {
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var moviesListContainer: UIView!
    @IBOutlet private(set) var moviesSearchResultContainer: UIView!
    @IBOutlet private var searchBarContainer: UIView!
    @IBOutlet private var emptyDataLabel: UILabel!
    
    private var viewModel: MoviesListViewModel!
    private var posterImagesRepository: PosterImagesRepository?

    private var moviesTableViewController: MoviesListTableViewController?
    private lazy var searchBar: UISearchBar = {
        createSearchBar(frame: self.searchBarContainer.bounds,
                        searchBarPlaceholder: self.viewModel.searchBarPlaceholder,
                        delegate: self)
    }()

    // MARK: - Lifecycle

    static func create(with viewModel: MoviesListViewModel,
                       posterImagesRepository: PosterImagesRepository?) -> MoviesListViewController {
        let view = MoviesListViewController.instantiateViewController()
        view.viewModel = viewModel
        view.posterImagesRepository = posterImagesRepository
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBehaviours()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }

    private func bind(to viewModel: MoviesListViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in self?.updateItems() }
        viewModel.loading.observe(on: self) { [weak self] in self?.updateLoading($0) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: MoviesListTableViewController.self),
            let destinationVC = segue.destination as? MoviesListTableViewController {
            moviesTableViewController = destinationVC
            moviesTableViewController?.viewModel = viewModel
            moviesTableViewController?.posterImagesRepository = posterImagesRepository
        }
    }

    // MARK: - Private

    private func setupViews() {
        view.backgroundColor = .appBackgroundColor
        title = viewModel.screenTitle
//        emptyDataLabel.text = viewModel.emptyDataTitle
        searchBarContainer.addSubview(self.searchBar)
    }

    private func setupBehaviours() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil)
    }

    private func updateItems() {
        moviesTableViewController?.reload()
    }

    private func updateLoading(_ loading: MoviesListViewModelLoading?) {
        emptyDataLabel.isHidden = true
        moviesListContainer.isHidden = true
        moviesSearchResultContainer.isHidden = true
        LoadingView.hide()

        switch loading {
        case .fullScreen: 
            LoadingView.show()
        case .nextPage:
            moviesListContainer.isHidden = false
        case .none:
            moviesListContainer.isHidden = false
            emptyDataLabel.isHidden = true
        }

        moviesTableViewController?.updateLoading(loading)
    }

    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: viewModel.errorTitle, message: error)
    }
}

struct AccessibilityIdentifier {
    static let movieDetailsView = "AccessibilityIdentifierMovieDetailsView"
    static let searchField = "AccessibilityIdentifierSearchMovies"
}

extension MoviesListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text,
              !searchText.isEmpty else { return }
        viewModel.didSearch(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.didCancelSearch()
    }

    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.didCancelSearch()
        }
    }
}
