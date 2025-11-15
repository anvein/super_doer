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
//        return

       // TODO: УДАЛИТЬ!!! КОД ДЛЯ РАЗРАБОТКИ!!!
       ///////////////////////////////////////////////////

       //        // ЭРКРАН СПИСКА ЗАДАЧ
       //        let sectionEm = DIContainer.container.resolve(TaskSectionCoreDataManager.self)!
       //        let sections = sectionEm.getCustomSectionsWithOrder(isActive: true)
       //
       //        navigation.pushViewController(.init(), animated: false)
       //        if let section = sections[safe: 0] {
       //            let tasksListCoordinator = TasksListCoordinator(
       //                parent: self,
       //                navigation: navigation,
       //                sectionId: section.id!,
       //                deleteAlertFactory: DIContainer.container.resolve(DeleteItemsAlertFactory.self)!
       //            )
       //
       //            tasksListCoordinator.start()
       //        } else {
       //            print("no sections")
       //            startTaskSectionsListFlow()
       //        }

       // ЭКРАН ЗАДАЧИ
       let sectionEm = DIContainer.container.resolve(TaskSectionCoreDataManager.self)!
       let sections = sectionEm.getCustomSectionsWithOrder(isActive: true)

       let navigation = UINavigationController()

       navigation.pushViewController(.init(), animated: false)
       if let section = sections[safe: 0], let task = section.tasks?.firstObject as? CDTask {

           let navCoordinator = NavigationCoordinator(parent: self)
           let tasksDetailCoordinator = TaskDetailCoordinator(
               parent: navCoordinator,
               taskId: task.id!,
               deleteAlertFactory: DIContainer.container.resolve(DeleteItemsAlertFactory.self)!
           )
           navCoordinator.setTargetCoordinator(tasksDetailCoordinator)

           startChild(navCoordinator) { [weak self] (navController: UIViewController) in
               guard let navigation = navController as? UINavigationController else { return }

               navigation.modalPresentationStyle = .fullScreen
               self?.rootViewController.present(navigation, animated: false)
           }
       } else {
           print("no sections / tasks in section")
           startTaskSectionsListFlow()
       }

       ///////////////////////////////////////////////////
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
