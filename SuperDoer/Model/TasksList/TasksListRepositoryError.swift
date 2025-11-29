enum TasksListRepositoryError: Error {
    case loadDataFailed
    case failedCreateTask(error: Error? = nil)
    case failedDeleteTasks(error: Error)
}
