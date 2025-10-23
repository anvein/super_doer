import Foundation

// MARK: - Coordinator protocol

protocol TasksListViewControllerCoordinator: AnyObject {
    func selectTask(viewModel: TaskDetailViewModel)

    func startDeleteProcessTasks(tasksViewModels: [TaskDeletableViewModel])

    func closeTaskListInSection()
}
