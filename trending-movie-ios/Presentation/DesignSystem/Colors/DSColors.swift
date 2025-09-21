import UIKit
import SwiftUI

enum DSTheme {
    case light
    case dark
}

struct DSColors {

    // MARK: - Background Colors
    static func primaryBackground(for theme: DSTheme = .dark) -> UIColor {
        switch theme {
        case .light:
            return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // #ffffff
        case .dark:
            return UIColor(red: 25/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0) // #191919
        }
    }

    static func secondaryBackground(for theme: DSTheme = .dark) -> UIColor {
        switch theme {
        case .light:
            return UIColor(red: 249/255.0, green: 248/255.0, blue: 247/255.0, alpha: 1.0) // #f9f8f7
        case .dark:
            return UIColor(red: 32/255.0, green: 32/255.0, blue: 32/255.0, alpha: 1.0) // #202020
        }
    }

    // MARK: - Text Colors
    static func primaryText(for theme: DSTheme = .dark) -> UIColor {
        switch theme {
        case .light:
            return UIColor(red: 17/255.0, green: 17/255.0, blue: 17/255.0, alpha: 1.0)
        case .dark:
            return UIColor.white
        }
    }

    static func secondaryText(for theme: DSTheme = .dark) -> UIColor {
        switch theme {
        case .light:
            return UIColor(red: 107/255.0, green: 114/255.0, blue: 126/255.0, alpha: 1.0)
        case .dark:
            return UIColor(red: 156/255.0, green: 163/255.0, blue: 175/255.0, alpha: 1.0)
        }
    }

    // MARK: - Accent Colors
    static func accent(for theme: DSTheme = .dark) -> UIColor {
        switch theme {
        case .light:
            return UIColor(red: 59/255.0, green: 130/255.0, blue: 246/255.0, alpha: 1.0)
        case .dark:
            return UIColor(red: 96/255.0, green: 165/255.0, blue: 250/255.0, alpha: 1.0)
        }
    }

    // MARK: - Loading & Skeleton Colors
    static func shimmerBackground(for theme: DSTheme = .dark) -> UIColor {
        switch theme {
        case .light:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        case .dark:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        }
    }

    static func shimmerHighlight(for theme: DSTheme = .dark) -> UIColor {
        switch theme {
        case .light:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        case .dark:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        }
    }

    // MARK: - Spinner Colors
    static func spinnerPrimary(for theme: DSTheme = .dark) -> UIColor {
        return primaryText(for: theme)
    }

    static func spinnerSecondary(for theme: DSTheme = .dark) -> UIColor {
        return shimmerBackground(for: theme)
    }
}

// MARK: - SwiftUI Color Extensions
@available(iOS 13.0, *)
extension DSColors {
    static func primaryBackgroundSwiftUI(for theme: DSTheme = .dark) -> Color {
        return Color(primaryBackground(for: theme))
    }

    static func secondaryBackgroundSwiftUI(for theme: DSTheme = .dark) -> Color {
        return Color(secondaryBackground(for: theme))
    }

    static func primaryTextSwiftUI(for theme: DSTheme = .dark) -> Color {
        return Color(primaryText(for: theme))
    }

    static func secondaryTextSwiftUI(for theme: DSTheme = .dark) -> Color {
        return Color(secondaryText(for: theme))
    }

    static func accentSwiftUI(for theme: DSTheme = .dark) -> Color {
        return Color(accent(for: theme))
    }
}

// MARK: - UIColor Extension for Design System
extension UIColor {
    static var dsPrimaryBackground: UIColor {
        return DSColors.primaryBackground(for: DSThemeManager.shared.currentTheme)
    }

    static var dsSecondaryBackground: UIColor {
        return DSColors.secondaryBackground(for: DSThemeManager.shared.currentTheme)
    }

    static var dsPrimaryText: UIColor {
        return DSColors.primaryText(for: DSThemeManager.shared.currentTheme)
    }

    static var dsSecondaryText: UIColor {
        return DSColors.secondaryText(for: DSThemeManager.shared.currentTheme)
    }

    static var dsAccent: UIColor {
        return DSColors.accent(for: DSThemeManager.shared.currentTheme)
    }
}