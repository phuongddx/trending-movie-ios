//
//  String+Ext.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 8/6/24.
//

import Foundation
import UIKit

extension String {
    func attributedText(spacing: CGFloat = 5.0,
                        textColor: UIColor? = nil,
                        textFont: UIFont? = nil) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let range = NSRange(location: 0, length: attributedString.length)
        var attributes = [NSAttributedString.Key : Any]()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle

        if let color = textColor {
            attributes[NSAttributedString.Key.foregroundColor] = color
        }
        if let font = textFont {
            attributes[NSAttributedString.Key.font] = font
        }
        attributedString.addAttributes(attributes,
                                       range: range)

        return attributedString
    }
}
