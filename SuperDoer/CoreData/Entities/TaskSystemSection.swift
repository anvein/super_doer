import Foundation

/// Системные списки задач
/// Не хранятся в БД, поэтому для них обычный класс
class TaskSystemSection: TaskSectionProtocol {
    enum SectionType {
        case myDay
        case important
        case planned
        case all
        case completed
        case withoutSection
    }
    
    var type: SectionType
    var title: String
    var tasksCount: Int
    
    init(type: SectionType, title: String, tasksCount: Int = 0) {
        self.type = type
        self.title = title
        self.tasksCount = tasksCount
    }
}
