
import Foundation

// MARK: - Coordinator protocol

protocol TaskListInSectionViewControllerCoordinator: AnyObject {
    func selectTask(viewModel: TaskDetailViewModel)

    func startDeleteProcessTasks(tasksViewModels: [TaskDeletableViewModel])

    func closeTaskListInSection()
}
