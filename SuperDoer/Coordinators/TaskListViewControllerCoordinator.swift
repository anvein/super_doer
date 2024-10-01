
import Foundation

// MARK: - Coordinator protocol

protocol TaskListViewControllerCoordinator: AnyObject {
    func selectTask(viewModel: TaskDetailViewModel)

    func startDeleteProcessTasks(tasksViewModels: [TaskDeletableViewModel])

    func closeTaskListInSection()
}
