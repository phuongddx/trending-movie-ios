//
//  MovieDetailsViewController.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 7/6/24.
//

import Foundation
import UIKit

final class MovieDetailsViewController: ViewController,
                                        AppUIProvider {
    static func create(with viewModel: MovieDetailsViewModel) -> MovieDetailsViewController {
        let view = MovieDetailsViewController()
        view.viewModel = viewModel
        return view
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIs
    private lazy var containerView: ScrollableStackViewContainer = ScrollableStackViewContainer()
    private lazy var overviewLbl = createLabel(text: "")
    private lazy var posterImageView = createImageView(contentMode: .scaleToFill)

    var viewModel: MovieDetailsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }

    private func bind(to viewModel: MovieDetailsViewModel) {
        viewModel.posterImage.observe(on: self) { [weak self] in
            self?.posterImageView.image = $0.flatMap(UIImage.init)
        }
        viewModel.loading.observe(on: self) { loading in
            if loading == .fullScreen {
                LoadingView.show()
            } else {
                LoadingView.hide()
            }
        }
        viewModel.movie.observe(on: self) { [weak self] movie in
            guard let movie else { return }
            self?.title = movie.title
            self?.viewModel.updatePosterImage(posterImagePath: movie.posterPath ?? "")
            self?.overviewLbl.attributedText = self?.viewModel.detailsDisplayText(movie: movie)
        }
    }

    private func setupViews() {
        view.backgroundColor = .appBackgroundColor
        view.addSubview(containerView)
        view.accessibilityIdentifier = AccessibilityIdentifier.movieDetailsView
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.heightAnchor.constraint(equalToConstant: Device.screenSize.height * 2 / 3).isActive = true
        posterImageView.image = UIImage(named: "placeholder-bg")

        overviewLbl.numberOfLines = 0

        containerView.add(arrangedSubviews: [
            posterImageView,
            wrapperOverviewLbl,
            UIView()
        ])
    }

    private var wrapperOverviewLbl: UIView {
        let view = UIView()
        overviewLbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overviewLbl)
        NSLayoutConstraint.activate([
            overviewLbl.topAnchor.constraint(equalTo: view.topAnchor),
            overviewLbl.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overviewLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            overviewLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        return view
    }
}
