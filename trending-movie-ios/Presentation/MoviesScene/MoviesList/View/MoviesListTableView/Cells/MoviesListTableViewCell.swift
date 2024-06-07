//
//  MoviesListTableViewCell.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 7/6/24.
//

import UIKit

class MoviesListTableViewCell: UITableViewCell {
    private lazy var posterImageViewWidth: CGFloat = Device.screenSize.width / 3
    private lazy var posterImageViewHeight: CGFloat = Device.screenSize.width * 2 / 5

    private var viewModel: MoviesListItemViewModel!
    private var posterImagesRepository: PosterImagesRepository?
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    private let mainQueue: DispatchQueueType = DispatchQueue.main
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInits()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIs
    private lazy var mainStack: UIStackView = createStack(axis: .horizontal, padding: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
    private lazy var subStack: UIStackView = createStack(axis: .vertical)
    private lazy var posterImageView: UIImageView = createImageView(contentMode: .scaleToFill)
    private lazy var titleLbl: UILabel = createLabel(text: "")

    func bind(with viewModel: MoviesListItemViewModel,
              posterImagesRepository: PosterImagesRepository?) {
        self.viewModel = viewModel
        self.posterImagesRepository = posterImagesRepository
        updateView()
    }

    private func updateView() {
        titleLbl.attributedText = viewModel.displayText()
        updatePosterImage()
    }

    private func commonInits() {
        setupLayouts()
        setupMainStack()
    }

    private func setupLayouts() {
        addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        posterImageView.heightAnchor.constraint(equalToConstant: posterImageViewHeight).isActive = true
        posterImageView.widthAnchor.constraint(equalToConstant: posterImageViewWidth).isActive = true
        posterImageView.backgroundColor = UIColor.lightGray
    }

    private func setupMainStack() {
        mainStack.addArrangedSubview(posterImageView)
        mainStack.addArrangedSubview(subStack)
        subStack.addArrangedSubview(titleLbl)
        subStack.addArrangedSubview(UIView())
    }

    private func updatePosterImage() {
        posterImageView.image = nil
        guard let posterImagePath = viewModel.posterImagePath else { return }

        imageLoadTask = posterImagesRepository?.fetchImage(with: posterImagePath) { [weak self] result in
            self?.mainQueue.async {
                guard self?.viewModel.posterImagePath == posterImagePath else { return }
                if case let .success(data) = result {
                    self?.posterImageView.image = UIImage(data: data)
                }
                self?.imageLoadTask = nil
            }
        }
    }
}

extension MoviesListTableViewCell: AppUIProvider {}
