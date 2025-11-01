import Foundation

enum TasksListNavigationEvent {
    case openTaskDetail(taskId: UUID)
    case openDeleteTasksConfirmation([TaskDeletableViewModel])
}
