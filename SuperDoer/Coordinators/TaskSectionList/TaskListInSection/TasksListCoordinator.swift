
import UIKit

final class TasksListCoordinator: BaseCoordinator {
    private var navigation: UINavigationController
    private var viewModel: TasksListViewModel
    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        viewModel: TasksListViewModel
    ) {
        self.navigation = navigation
        self.viewModel = viewModel
        super.init(parent: parent)
    }
    
    override func start() {
        let vc = TasksListViewController(
            coordinator: self,
            viewModel: viewModel
        )
        navigation.pushViewController(vc, animated: true)
    }
    
}

// MARK: - TaskListViewControllerCoordinator

extension TasksListCoordinator: TaskListViewControllerCoordinator {
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
        let coordinator = DeleteItemCoordinator(
            parent: self,
            navigation: navigation,
            viewModels: tasksViewModels,
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    func closeTaskListInSection() {
        parent?.removeChild(self)
    }
}

// MARK: - DeleteItemCoordinatorDelegate

extension TasksListCoordinator: DeleteItemCoordinatorDelegate {
    func didConfirmDeleteItems(_ items: [DeletableItemViewModelType]) {
        viewModel.deleteTasks(taskViewModels: items)
    }
}
