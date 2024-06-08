//
//  MoviesListEmptyTableViewCell.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 8/6/24.
//

import Foundation
import UIKit

final class MoviesListEmptyTableViewCell: UITableViewCell {
    private lazy var title = NSLocalizedString(
        "No movies were found matching your search criteria. Please try again with different keywords.",
        comment: "")
    private lazy var stack: UIStackView = {
        let stack = createStack(axis: .horizontal)
        stack.setPadding(UIEdgeInsets(top: 32, left: 16, bottom: 16, right: 16))
        let label = createLabel(text: NSLocalizedString(title, comment: ""),
                                font: .systemFont(ofSize: 18, weight: .semibold),
                                textColor: UIColor.white)
        label.numberOfLines = 0
        label.textAlignment = .center
        stack.addArrangedSubview(label)
        stack.backgroundColor = UIColor.clear
        return stack
    }()

    private func commonInits() {
        backgroundColor = .appBackgroundColor
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInits()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
