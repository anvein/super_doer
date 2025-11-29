enum TaskSectionRepositoryError: Error {
    case createFailed
    case renameFailed(error: Error?)
    case fetchFailed(error: Error)
}
