import UIKit
import Factory

final class AppFlowCoordinator {
    private let navigationController: UINavigationController
    private let container: AppContainer

    init(
        navigationController: UINavigationController,
        container: AppContainer = AppContainer.shared
    ) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let flow = container.moviesSearchFlowCoordinator(navigationController: navigationController)
        flow.start()
    }
}