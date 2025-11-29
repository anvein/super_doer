enum TaskRepositoryError: Error {
    case fetchDataError
    case taskNotFound
    case updateTaskError
    case createTaskFailed(error: Error)
    case createFileFalied(error: Error)
    case deleteFileFailed(error: Error)
}
