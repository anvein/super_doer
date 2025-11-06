import UIKit

final class NavigationCoordinator: BaseCoordinator {

    private let navigation: UINavigationController
    private let targetCoordinator: BaseCoordinator

    init(targetCoordinator: BaseCoordinator) {
        self.navigation = UINavigationController()
        self.targetCoordinator = targetCoordinator
    }

    override func start() {
        super.start()

        navigation.delegate = self
        addChild(self)

        targetCoordinator.start()
    }
}

// MARK: - UINavigationControllerDelegate

extension NavigationCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let fromVC = navigationController.transitionCoordinator?.viewController(forKey: .from),
              !navigationController.viewControllers.contains(fromVC) else { return }

        if fromVC === viewController {
            childs.last?.finish()
        }
    }
}
