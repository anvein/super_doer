import UIKit

final class AppCoordinator: BaseCoordinator {
    
    private var window: UIWindow

    private var navigation: UINavigationController?
    override var rootViewController: UIViewController? { navigation }

    init(window: UIWindow) {
        self.window = window

        super.init(parent: nil)
    }
    
    override func startCoordinator() {
        let navigation = UINavigationController()
        self.navigation = navigation

        window.rootViewController = navigation
        window.makeKeyAndVisible()

        startTaskSectionsListFlow(navigation: navigation)
    }

    // MARK: - Start childs

    private func startTaskSectionsListFlow(navigation: UINavigationController) {
        let navCoordinator = NavigationCoordinator(
            parent: self,
            navigation: navigation
        )

        let sectionsListCoordinator = SectionsListCoordinator(
            parent: navCoordinator,
            navigation: navigation,
            deleteAlertFactory: DIContainer.container.resolve(DeleteItemsAlertFactory.self)!
        )
        navCoordinator.setTargetCoordinator(sectionsListCoordinator)

        startChild(navCoordinator)
    }

}
