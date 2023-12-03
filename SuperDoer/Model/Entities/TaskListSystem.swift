
import Foundation

/// Системные списки задач
/// Не хранятся в БД, поэтому для них обычный класс
class TaskListSystem: TaskListProtocol {
    enum ListType {
        case myDay
        case important
        case planned
        case all
        case completed
        case withoutSection
    }
    
    var type: ListType
    var title: String
    var tasksCount: Int
    
    init(type: ListType, title: String, tasksCount: Int = 0) {
        self.type = type
        self.title = title
        self.tasksCount = tasksCount
    }
}
