import UIKit

final class AppCoordinator: BaseCoordinator {

    private lazy var viewController = UIViewController()
    override var rootViewController: UIViewController { viewController }

    init() {
        super.init(parent: nil)
    }

    override func navigate() {
        super.navigate()

        startTaskSectionsListFlow()
    }

    // MARK: - Start childs

    private func startTaskSectionsListFlow() {
        let navCoordinator = NavigationCoordinator(parent: self)

        let sectionsListCoordinator = SectionsListCoordinator(
            parent: navCoordinator,
            deleteAlertFactory: DIContainer.container.resolve(DeleteItemsAlertFactory.self)!
        )
        navCoordinator.setTargetCoordinator(sectionsListCoordinator)

        startChild(navCoordinator) { [weak self] (navigationController: UIViewController) in
            navigationController.modalPresentationStyle = .fullScreen
            self?.rootViewController.present(navigationController, animated: false)
        }
    }

}
