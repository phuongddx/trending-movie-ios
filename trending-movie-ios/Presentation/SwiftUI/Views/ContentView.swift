import SwiftUI

@available(iOS 16.0, *)
struct ContentView: View {
    private let container: AppContainer
    @StateObject private var themeManager = DSThemeManager.shared

    init(container: AppContainer) {
        self.container = container
    }

    var body: some View {
        TabNavigationView(container: container)
            .environment(\.dsTheme, themeManager.currentTheme)
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.currentTheme == .dark ? .dark : .light)
    }
}

// MARK: - iOS 15 Compatibility
@available(iOS 15.0, *)
struct ContentViewLegacy: View {
    private let container: AppContainer
    @StateObject private var themeManager = DSThemeManager.shared

    init(container: AppContainer) {
        self.container = container
    }

    var body: some View {
        TabNavigationView(container: container)
            .environment(\.dsTheme, themeManager.currentTheme)
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.currentTheme == .dark ? .dark : .light)
    }
}

// MARK: - AppDestination Sheet Identifiable
extension AppDestination: Identifiable {
    var id: String {
        switch self {
        case .moviesList:
            return "moviesList"
        case .movieDetails(let movie):
            return "movieDetails_\(movie.id)"
        }
    }
}

// MARK: - Preview
@available(iOS 16.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView(container: AppContainer.shared)
    }
}