
import Foundation

/// Ячейка "задачи" в таблице со списком задач
class TaskInSectionTableViewCellViewModel: TaskInSectionTableViewCellViewModelType {
    private var task: CDTask
    
    var isCompleted: Bool {
        return task.isCompleted
    }
    
    var isPriority: Bool {
        return task.isPriority
    }
    
    var title: String {
        return task.title ?? "-undefined-"
    }
    
    var sectionTitle: String? {
        return task.section?.title
    }
    
    var deadlineDate: Date? {
        // TODO: отформатировать тут?
        return nil
    }
    
    init(task: CDTask) {
        self.task = task
    }
    
}
