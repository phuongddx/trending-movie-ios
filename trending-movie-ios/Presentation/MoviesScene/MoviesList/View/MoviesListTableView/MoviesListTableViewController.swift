//
//  MoviesListTableViewController.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import UIKit

final class MoviesListTableViewController: UITableViewController,
                                           AppUIProvider {

    var viewModel: MoviesListViewModel!

    var posterImagesRepository: PosterImagesRepository?
    var nextPageLoadingSpinner: UIActivityIndicatorView?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func reload() {
        UIView.performWithoutAnimation { [weak self] in
            self?.tableView.reloadData()
        }
    }

    func updateLoading(_ loading: MoviesListViewModelLoading?) {
        switch loading {
        case .nextPage:
            nextPageLoadingSpinner?.removeFromSuperview()
            nextPageLoadingSpinner = makeActivityIndicator(size: .init(width: tableView.frame.width, height: 44))
            tableView.tableFooterView = nextPageLoadingSpinner
        case .fullScreen, .none:
            tableView.tableFooterView = nil
        }
    }

    // MARK: - Private

    private func setupViews() {
        tableView.register(MoviesListTableViewCell.self,
                           forCellReuseIdentifier: MoviesListTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MoviesListTableViewController {
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        let stack = createStack(axis: .horizontal)
        stack.setPadding(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        stack.addArrangedSubview(createLabel(text: "Trending", font: .systemFont(ofSize: 18, weight: .semibold)))
        stack.backgroundColor = .white
        return stack
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.value.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoviesListTableViewCell.reuseIdentifier,
                                                 for: indexPath) as? MoviesListTableViewCell
        cell?.bind(with: viewModel.items.value[indexPath.row],
                   posterImagesRepository: posterImagesRepository)
        if indexPath.row == viewModel.items.value.count - 1 {
            viewModel.didLoadNextPage()
        }
        return cell ?? UITableViewCell()
    }

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.isEmpty ?
        tableView.frame.height :
        super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
}

extension UITableViewController {
    func makeActivityIndicator(size: CGSize) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        activityIndicator.frame = .init(origin: .zero, size: size)
        return activityIndicator
    }
}
