import Foundation

enum TaskListTableUpdateEvent {
    case beginUpdates
    case endUpdates

    case insertTask(IndexPath, withEditSection: Bool = false)
    case deleteTask(IndexPath, withEditSection: Bool = false)
    case updateTask(IndexPath, TaskTableViewCellViewModel)
    case moveTask(IndexPath, IndexPath, TaskTableViewCellViewModel)

    case insertSection(Int)
    case deleteSection(Int)
}
