import UIKit

final class AppCoordinator: BaseCoordinator {

    private lazy var viewController = UIViewController()
    override var rootViewController: UIViewController { viewController }

    init() {
        super.init(parent: nil)
    }

    override func navigate() {
        super.navigate()

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

        //        // ЭКРАН ЗАДАЧИ
        //        let sectionEm = DIContainer.container.resolve(TaskSectionCoreDataManager.self)!
        //        let sections = sectionEm.getCustomSectionsWithOrder(isActive: true)
        //
        //        let navigation = UINavigationController()
        //
        //        navigation.pushViewController(.init(), animated: false)
        //        if let section = sections[safe: 0], let task = section.tasks?.firstObject as? CDTask {
        //
        //            let tasksDetailCoordinator = TaskDetailCoordinator(
        //                parent: self,
        //                navigation: navigation,
        //                taskId: task.id!,
        //                deleteAlertFactory: DIContainer.container.resolve(DeleteItemsAlertFactory.self)!
        //            )
        //            startChild(tasksDetailCoordinator) { [weak self] (controller: UIViewController) in
        //                controller.modalPresentationStyle = .fullScreen
        //                self?.rootViewController.present(controller, animated: false)
        //            }
        //        } else {
        //            print("no sections / tasks in section")
        //            startTaskSectionsListFlow()
        //        }
        //
        //        ///////////////////////////////////////////////////

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
