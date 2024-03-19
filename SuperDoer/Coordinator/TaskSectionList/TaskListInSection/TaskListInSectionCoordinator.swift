
import UIKit

final class TaskListInSectionCoordinator: BaseCoordinator {
    private var navigation: UINavigationController
    private var viewModel: TaskListInSectionViewModel
    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        viewModel: TaskListInSectionViewModel
    ) {
        self.navigation = navigation
        self.viewModel = viewModel
        super.init(parent: parent)
    }
    
    override func start() {
        let vc = TaskListInSectionViewController(
            coordinator: self,
            viewModel: viewModel
        )
        navigation.pushViewController(vc, animated: true)
    }
    
}


// MARK: - coordinator methods for controller
extension TaskListInSectionCoordinator: TaskListInSectionViewControllerCoordinator {
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



extension TaskListInSectionCoordinator: DeleteItemCoordinatorDelegate {
    func didConfirmDeleteItems(_ items: [DeletableItemViewModelType]) {
        viewModel.deleteTasks(taskViewModels: items)
    }
}
