//
//  AppUIProvider.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 7/6/24.
//

import Foundation
import UIKit

protocol AppUIProvider {
    func createLabel(text: String, font: UIFont, textColor: UIColor) -> UILabel
    func createImageView(image: UIImage?, contentMode: UIView.ContentMode) -> UIImageView
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

    func createImageView(image: UIImage? = nil,
                         contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = contentMode
        return imageView
    }
}
