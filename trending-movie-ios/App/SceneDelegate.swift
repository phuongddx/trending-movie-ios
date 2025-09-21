import UIKit
import Factory

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var appFlowCoordinator: AppFlowCoordinator?
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        AppAppearance.setupAppearance()

        window = UIWindow(windowScene: scene)
        let navigationController = UINavigationController()

        window?.rootViewController = navigationController
        appFlowCoordinator = AppFlowCoordinator(navigationController: navigationController)
        appFlowCoordinator?.start()
        window?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save context if needed
    }
}