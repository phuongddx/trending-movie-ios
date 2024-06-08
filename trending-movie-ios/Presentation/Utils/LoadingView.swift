//
//  LoadingView.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 6/6/24.
//

import Foundation
import UIKit

class LoadingView {

    internal static var spinner: UIActivityIndicatorView?

    static func show() {
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(update),
                                                   name: UIDevice.orientationDidChangeNotification, object: nil)
            if spinner == nil,
               let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                let frame = UIScreen.main.bounds
                let spinner = UIActivityIndicatorView(frame: frame)
                spinner.backgroundColor = .appBackgroundColor
                spinner.style = .large
                spinner.color = .white
                window.addSubview(spinner)

                spinner.startAnimating()
                self.spinner = spinner
            }
        }
    }

    static func hide() {
        DispatchQueue.main.async {
            guard let spinner = spinner else { return }
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            self.spinner = nil
        }
    }

    @objc static func update() {
        DispatchQueue.main.async {
            if spinner != nil {
                hide()
                show()
            }
        }
    }
}
