import UIKit

final class NavigationCoordinator: BaseCoordinator {

    override var rootViewController: UIViewController { navigation }

    private let navigation: UINavigationController
    private var targetCoordinator: BaseCoordinator?

    init(parent: Coordinator) {
        self.navigation = UINavigationController()
        super.init(parent: parent)
    }

    override func navigate() {
        super.navigate()

        guard let targetCoordinator else {
            ConsoleLogger.warning(
                "targetCoordinator is nil on \(Self.description()) - set before start()"
            )
            return
        }

        startChild(targetCoordinator) { [weak self] (targetController: UIViewController) in
            self?.navigation.setViewControllers([targetController], animated: false)
        }
    }

    func setTargetCoordinator(_ coordinator: BaseCoordinator) {
        targetCoordinator = coordinator
    }

}
