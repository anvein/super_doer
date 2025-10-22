import Foundation

enum TaskListTableUpdateEvent {
    case beginUpdates
    case endUpdates

    case insertTask(IndexPath)
    case deleteTask(IndexPath)
    case updateTask(IndexPath, TaskTableViewCellViewModel)
    case moveTask(IndexPath, IndexPath, TaskTableViewCellViewModel)

    case insertSection(Int)
    case deleteSection(Int)
}
