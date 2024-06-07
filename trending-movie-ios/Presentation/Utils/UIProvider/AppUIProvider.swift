//
//  AppUIProvider.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 7/6/24.
//

import Foundation
import UIKit

protocol AppUIProvider {
    func createStack(axis: NSLayoutConstraint.Axis,
                     spacing: CGFloat,
                     padding inset: UIEdgeInsets) -> UIStackView
    func createLabel(text: String,
                     font: UIFont,
                     textColor: UIColor) -> UILabel
    func createImageView(image: UIImage?,
                         contentMode: UIView.ContentMode,
                         translatesAutoresizingMaskIntoConstraints: Bool) -> UIImageView
}

extension AppUIProvider {
    func createLabel(text: String,
                     font: UIFont = .systemFont(ofSize: 14),
                     textColor: UIColor = .black) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        return label
    }

    func createStack(axis: NSLayoutConstraint.Axis,
                     spacing: CGFloat = 0,
                     padding inset: UIEdgeInsets = .zero) -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = axis
        stack.spacing = spacing
        stack.setPadding(inset)
        return stack
    }

    func createImageView(image: UIImage? = nil,
                         contentMode: UIView.ContentMode = .scaleAspectFit,
                         translatesAutoresizingMaskIntoConstraints: Bool = false) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        imageView.image = image
        imageView.contentMode = contentMode
        return imageView
    }
}

extension UIStackView {
    func setPadding(_ inset: UIEdgeInsets) {
        layoutMargins = inset
        isLayoutMarginsRelativeArrangement = true
    }
}
