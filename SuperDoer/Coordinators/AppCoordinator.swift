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

//        startTaskSectionsListFlow()


        // TODO: УДАЛИТЬ!!! КОД ДЛЯ РАЗРАБОТКИ!!!
        ///////////////////////////////////////////////////

        // ЭРКРАН СПИСКА ЗАДАЧ
//        let sectionEm = DIContainer.container.resolve(TaskSectionCoreDataManager.self)!
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

        // ЭКРАН ЗАДАЧИ
        let sectionEm = DIContainer.container.resolve(TaskSectionCoreDataManager.self)!
        let taskEm = DIContainer.container.resolve(TaskCoreDataManager.self)!
        let sections = sectionEm.getCustomSectionsWithOrder(isActive: true)

        navigation.pushViewController(.init(), animated: false)
        if let section = sections[safe: 0], let task = section.tasks?.firstObject as? CDTask {

            let tasksDetailCoordinator = TaskDetailCoordinator(
                parent: self,
                navigation: navigation,
                taskId: task.id!
            )
            addChild(tasksDetailCoordinator)
            tasksDetailCoordinator.start()
        } else {
            print("no sections / tasks in section")
            startTaskSectionsListFlow()
        }

        ///////////////////////////////////////////////////
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
