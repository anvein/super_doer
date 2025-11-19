import UIKit

final class AppCoordinator: BaseCoordinator {

    private lazy var navigation = UINavigationController()
    override var rootViewController: UIViewController { navigation }
    private let di: AppDI

    init(di: AppDI) {
        self.di = di
        super.init(parent: nil)
    }

    override func navigate() {
        super.navigate()

        startTaskSectionsListFlow()
        return

        // swiftlint:disable all
        // TODO: УДАЛИТЬ!!! КОД ДЛЯ РАЗРАБОТКИ!!!
        ///////////////////////////////////////////////////

        //        // ЭРКРАН СПИСКА ЗАДАЧ
        //        let sectionEm = diContainer.container.resolve(TaskSectionCoreDataManager.self)!
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
        let sectionEm = di.container.resolve(TaskSectionCoreDataManager.self)!
        let sections = sectionEm.getCustomSectionsWithOrder(isActive: true)

        let navigation = UINavigationController()

        navigation.pushViewController(.init(), animated: false)
        if let section = sections[safe: 0], let task = section.tasks?.firstObject as? CDTask {

            let navCoordinator = NavigationCoordinator(parent: self)
            let tasksDetailCoordinator = TaskDetailCoordinator(
                parent: navCoordinator,
                taskId: task.id!,
                factory: di.assembler.resolver.resolve(TaskDetailDependencyFactoryType.self)!
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

        // swiftlint:enable all
        ///////////////////////////////////////////////////
    }

    // MARK: - Start childs

    // swiftlint:disable force_unwrapping
    private func startTaskSectionsListFlow() {
        let navCoordinator = NavigationCoordinator(parent: self, navigation: navigation)

        let sectionsListCoordinator = SectionsListCoordinator(
            parent: navCoordinator,
            factory: di.container.resolve(SectionsListDependencyFactoryType.self)!
        )
        navCoordinator.setTargetCoordinator(sectionsListCoordinator)

        startChild(navCoordinator) { _ in }
    }
    // swiftlint:enable force_unwrapping

}
