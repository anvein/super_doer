
import Foundation

/// Ячейка "задачи" в таблице со списком задач
class TaskTableViewCellViewModel: TaskTableViewCellViewModelType {
    private var task: TaskListItem

    var isCompleted: Bool {
        return task.isCompleted
    }
    
    var isPriority: Bool {
        return task.isPriority
    }
    
    var title: String {
        return task.title
    }
    
    var sectionTitle: String? {
        return ""
//        return task.section?.title
    }
    
    var deadlineDate: Date? {
        // TODO: отформатировать тут?
        return nil
    }
    
    init(task: TaskListItem) {
        self.task = task
    }
    
}
