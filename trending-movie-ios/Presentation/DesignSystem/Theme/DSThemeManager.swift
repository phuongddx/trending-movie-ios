import UIKit
import SwiftUI

class DSThemeManager: ObservableObject {
    static let shared = DSThemeManager()

    @Published var currentTheme: DSTheme = .dark {
        didSet {
            updateAppAppearance()
            saveThemePreference()
        }
    }

    private let themeKey = "DSThemePreference"

    private init() {
        loadThemePreference()
        observeSystemTheme()
    }

    // MARK: - Theme Management
    func setTheme(_ theme: DSTheme) {
        currentTheme = theme
    }

    func toggleTheme() {
        currentTheme = currentTheme == .light ? .dark : .light
    }

    // MARK: - System Theme Observation
    private func observeSystemTheme() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAppAppearance()
        }
    }

    // MARK: - Appearance Updates
    private func updateAppAppearance() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Update navigation bar
            self.updateNavigationBarAppearance()

            // Update status bar
            self.updateStatusBarAppearance()

            // Notify views of theme change
            NotificationCenter.default.post(name: .themeDidChange, object: self.currentTheme)
        }
    }

    private func updateNavigationBarAppearance() {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: DSColors.primaryText(for: currentTheme)]
            appearance.backgroundColor = DSColors.primaryBackground(for: currentTheme)
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = DSColors.primaryBackground(for: currentTheme)
            UINavigationBar.appearance().tintColor = DSColors.primaryText(for: currentTheme)
            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: DSColors.primaryText(for: currentTheme)
            ]
        }
    }

    private func updateStatusBarAppearance() {
        let style: UIStatusBarStyle = currentTheme == .dark ? .lightContent : .darkContent
        if #available(iOS 13.0, *) {
            UIApplication.shared.windows.first?.rootViewController?.overrideUserInterfaceStyle =
                currentTheme == .dark ? .dark : .light
        }
    }

    // MARK: - Persistence
    private func saveThemePreference() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
    }

    private func loadThemePreference() {
        if let savedTheme = UserDefaults.standard.object(forKey: themeKey) as? String,
           let theme = DSTheme(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
}

// MARK: - DSTheme Extension
extension DSTheme: RawRepresentable {
    var rawValue: String {
        switch self {
        case .light: return "light"
        case .dark: return "dark"
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "light": self = .light
        case "dark": self = .dark
        default: return nil
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}

// MARK: - SwiftUI Environment
@available(iOS 13.0, *)
struct ThemeKey: EnvironmentKey {
    static let defaultValue = DSTheme.dark
}

@available(iOS 13.0, *)
extension EnvironmentValues {
    var dsTheme: DSTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}