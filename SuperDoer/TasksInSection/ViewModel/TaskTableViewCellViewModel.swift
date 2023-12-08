
import Foundation

/// Ячейка "задачи" в таблице со списком задач
class TaskTableViewCellViewModel: TaskTableViewCellViewModelType {
    var isCompleted: Bool
    
    var isPriority: Bool
    
    var title: String
    
    var section: TaskSectionCustom?
    
    var deadlineDate: Date?
    
    // TODO: переделать стандартный инициалайзер
    init(isCompleted: Bool, isPriority: Bool, title: String, section: TaskSectionCustom? = nil, deadlineDate: Date? = nil) {
        self.isCompleted = isCompleted
        self.isPriority = isPriority
        self.title = title
        self.section = section
        self.deadlineDate = deadlineDate
    }
    
}
