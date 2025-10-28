enum TasksListCoordinatorToVmEvent {
    case onDeleteTasksConfirmed([TaskDeletableViewModel])
    case onDeleteTasksCanceled
}
