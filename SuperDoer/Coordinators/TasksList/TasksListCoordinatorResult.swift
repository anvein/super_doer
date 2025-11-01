enum TasksListCoordinatorResult {
    case onDeleteTasksConfirmed([TaskDeletableViewModel])
    case onDeleteTasksCanceled
}
