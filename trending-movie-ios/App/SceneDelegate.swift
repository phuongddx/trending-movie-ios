import UIKit
import SwiftUI
import Factory

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let container = AppContainer.shared

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Initialize theme manager early
        DSThemeManager.shared.currentTheme = .dark

        // Create the SwiftUI view
        let contentView: AnyView
        if #available(iOS 16.0, *) {
            contentView = AnyView(ContentView(container: container))
        } else {
            contentView = AnyView(ContentViewLegacy(container: container))
        }

        // Create the window using the specified window scene
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UIHostingController(rootView: contentView)
        window?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save context if needed
    }
}