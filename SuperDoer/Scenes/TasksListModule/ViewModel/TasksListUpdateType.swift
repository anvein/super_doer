
import Foundation

enum TasksListUpdateType {
    case beginUpdates
    case endUpdates

    case insertTask(IndexPath)
    case deleteTask(IndexPath)
    case updateTask(IndexPath)
    case moveTask(IndexPath, IndexPath, TaskTableViewCellViewModel)

    case insertSection(Int)
    case deleteSection(Int)
}
