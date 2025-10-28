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


//        // TODO: УДАЛИТЬ!!! КОД ДЛЯ РАЗРАБОТКИ!!!
//        ///////////////////////////////////////////////////
//        let sectionEm = DIContainer.container.resolve(TaskSectionEntityManager.self)!
//        let sections = sectionEm.getCustomSectionsWithOrder(isActive: true)
//
//        navigation.pushViewController(.init(), animated: false)
//        if let section = sections[safe: 0] {
//            let tasksListCoordinator = TasksListCoordinator(
//                parent: self,
//                navigation: navigation,
//                section: section,
//                deleteAlertFactory: DIContainer.container.resolve(DeleteItemsAlertFactory.self)!
//            )
//
//            addChild(tasksListCoordinator)
//            tasksListCoordinator.start()
//        } else {
//            print("no sections")
//        }
//        ///////////////////////////////////////////////////
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
