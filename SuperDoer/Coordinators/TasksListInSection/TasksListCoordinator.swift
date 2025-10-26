import UIKit

final class TasksListCoordinator: BaseCoordinator {

    private var navigation: UINavigationController
    private let section: CDTaskCustomSection

    init(parent: Coordinator, navigation: UINavigationController, section: CDTaskCustomSection) {
        self.navigation = navigation
        self.section = section
        super.init(parent: parent)
    }

    override func start() {
        let vm = TasksListViewModel(
            coordinator: self,
            repository: TasksListRepository(
                taskSection: section,
                taskCDManager: DIContainer.container.resolve(TaskCoreDataManager.self)!
            ),
            sectionCDManager: DIContainer.container.resolve(TaskSectionEntityManager.self)!
        )

        let vc = TasksListViewController(viewModel: vm)

        navigation.pushViewController(vc, animated: true)
    }

}

// MARK: - TaskListViewControllerCoordinator

extension TasksListCoordinator: TasksListViewControllerCoordinator {
    func selectTask(viewModel: TaskDetailViewModel) {
        let coordinator = TaskDetailCoordinator(
            parent: self,
            navigation: navigation,
            viewModel: viewModel
        )
        addChild(coordinator)
        coordinator.start()
    }

    func startDeleteProcessTasks(tasksViewModels: [TaskDeletableViewModel]) {
//        let coordinator = DeleteItemsConfirmCoordinator(
//            parent: self,
//            navigation: navigation,
//            viewModels: tasksViewModels,
//            delegate: self
//        )
//        addChild(coordinator)
//        coordinator.start()
    }

    func closeTaskListInSection() {
        parent?.removeChild(self)
    }
}

// MARK: - DeleteItemCoordinatorDelegate

//extension TasksListCoordinator: DeleteItemCoordinatorDelegate {
//    func didConfirmDeleteItems(_ items: [DeletableItemViewModelType]) {
//        //private var viewModel: TasksListViewModel
////        viewModel.deleteTasks(taskViewModels: items)
//    }
//}
