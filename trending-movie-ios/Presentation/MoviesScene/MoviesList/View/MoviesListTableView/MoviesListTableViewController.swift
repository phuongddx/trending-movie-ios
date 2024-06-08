//
//  MoviesListTableViewController.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import UIKit

final class MoviesListTableViewController: UITableViewController {
    private let viewModel: MoviesListViewModel

    init(viewModel: MoviesListViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        view.backgroundColor = .appBackgroundColor
        tableView.backgroundView?.backgroundColor = .appBackgroundColor
        tableView.backgroundColor = .appBackgroundColor
        tableView.register(MoviesListEmptyTableViewCell.self, forCellReuseIdentifier: MoviesListEmptyTableViewCell.reuseIdentifier)
        tableView.register(MoviesListTableViewCell.self,
                           forCellReuseIdentifier: MoviesListTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        tableView.separatorColor = .lightText
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MoviesListTableViewController {
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        let stack = createStack(axis: .horizontal)
        stack.setPadding(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        stack.addArrangedSubview(createLabel(text: NSLocalizedString(viewModel.moviesListHeaderTitle, comment: ""),
                                             font: .systemFont(ofSize: 20, weight: .semibold),
                                             textColor: UIColor.white))
        stack.backgroundColor = UIColor.clear
        return stack
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !viewModel.shouldShowEmptyView() else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MoviesListEmptyTableViewCell.reuseIdentifier) as? MoviesListEmptyTableViewCell
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: MoviesListTableViewCell.reuseIdentifier,
                                                 for: indexPath) as? MoviesListTableViewCell
        cell?.selectionStyle = .none
        if let viewModelItem = viewModel.viewModelItem(at: indexPath) {
            cell?.bind(with: viewModelItem,
                       posterImagesRepository: self.posterImagesRepository)
        }
        if indexPath.row == viewModel.items.value.count - 1 {
            viewModel.didLoadNextPage()
        }
        return cell ?? UITableViewCell()
    }

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        guard !viewModel.shouldShowEmptyView() else { return }
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
