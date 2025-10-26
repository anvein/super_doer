import UIKit

final class AppCoordinator: BaseCoordinator {
    
    private var window: UIWindow
    private var navigation: UINavigationController
    
    init(window: UIWindow, navigation: UINavigationController) {
        self.window = window
        self.navigation = navigation

        super.init(parent: nil)
    }
    
    override func start() {
        window.rootViewController = navigation
        window.makeKeyAndVisible()

        startTaskSectionsListFlow()
    }

    func startTaskSectionsListFlow() {
        let sectionsListCoordinator = SectionsListCoordinator(
            parent: self,
            navigation: navigation,
            deleteAlertFactory: DIContainer.container.resolve(DeleteItemsAlertFactory.self)!
        )

        addChild(sectionsListCoordinator)
        sectionsListCoordinator.start()
    }


}
