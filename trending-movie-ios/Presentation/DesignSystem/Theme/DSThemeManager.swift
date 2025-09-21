import UIKit
import SwiftUI

// MARK: - Cinemax Theme Manager (Dark Only)
class DSThemeManager: ObservableObject {
    static let shared = DSThemeManager()

    // Cinemax is always dark theme
    let currentTheme: CinemaxTheme = .dark

    private init() {
        updateAppAppearance()
    }

    // MARK: - Theme Management
    // Cinemax doesn't support theme switching - always dark
    func updateAppearance() {
        updateAppAppearance()
    }

    // No theme toggle for Cinemax - always dark
    @available(*, deprecated, message: "Cinemax uses dark theme only")
    func toggleTheme() {
        // No-op - Cinemax is dark only
    }

    // MARK: - Appearance Updates
    private func updateAppAppearance() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Update navigation bar
            self.updateNavigationBarAppearance()

            // Update status bar (always light content for dark theme)
            self.updateStatusBarAppearance()
        }
    }

    private func updateNavigationBarAppearance() {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: DSColors.primaryText]
            appearance.backgroundColor = DSColors.background
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = DSColors.background
            UINavigationBar.appearance().tintColor = DSColors.primaryText
            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: DSColors.primaryText
            ]
        }
    }

    private func updateStatusBarAppearance() {
        // Always light content for Cinemax dark theme
        if #available(iOS 13.0, *) {
            UIApplication.shared.windows.first?.rootViewController?.overrideUserInterfaceStyle = .dark
        }
    }
}

// MARK: - Cinemax Theme Enum
enum CinemaxTheme {
    case dark // Cinemax only supports dark theme
}

// MARK: - Cinemax Theme Extension
extension CinemaxTheme: RawRepresentable {
    var rawValue: String {
        switch self {
        case .dark: return "dark"
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "dark": self = .dark
        default: return nil
        }
    }
}

// MARK: - SwiftUI Environment for Cinemax
@available(iOS 13.0, *)
struct CinemaxThemeKey: EnvironmentKey {
    static let defaultValue = CinemaxTheme.dark
}

@available(iOS 13.0, *)
extension EnvironmentValues {
    var cinemaxTheme: CinemaxTheme {
        get { self[CinemaxThemeKey.self] }
        set { self[CinemaxThemeKey.self] = newValue }
    }
}