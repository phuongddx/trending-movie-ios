//
//  AppAppearance.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation
import UIKit

final class AppAppearance {

    static func setupAppearance() {
        // This is now handled by DSThemeManager for SwiftUI
        // Keeping this for any legacy UIKit components that might still exist
        // Cinemax is dark-only theme, no need to set theme manually
        DSThemeManager.shared.updateAppearance()
    }
}

extension UINavigationController {
    @objc override open var preferredStatusBarStyle: UIStatusBarStyle {
        return DSThemeManager.shared.currentTheme == .dark ? .lightContent : .darkContent
    }
}

