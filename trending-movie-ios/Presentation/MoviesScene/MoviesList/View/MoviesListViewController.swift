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
    
    private var viewModel: MoviesListViewModel!
    private var posterImagesRepository: PosterImagesRepository?

    private lazy var moviesTableViewController: MoviesListTableViewController = {
        let viewController = MoviesListTableViewController(viewModel: viewModel)
        viewController.posterImagesRepository = posterImagesRepository
        add(child: viewController, container: moviesListContainer)
        return viewController
    }()
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

    // MARK: - Private

    private func setupViews() {
        view.backgroundColor = .appBackgroundColor
        title = viewModel.screenTitle
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
        moviesTableViewController.reload()
    }

    private func updateLoading(_ loading: MoviesListViewModelLoading?) {
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
        }

        moviesTableViewController.updateLoading(loading)
    }

    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: viewModel.errorTitle, message: error)
    }
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
