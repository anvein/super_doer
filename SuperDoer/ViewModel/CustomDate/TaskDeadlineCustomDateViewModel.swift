
import Foundation

/// ViewModel для установки кастомной даты дедлайна (выполнения задачи)
class TaskDeadlineCustomDateViewModel: CustomDateViewModel {
    private var task: Task {
        didSet {
            date.value = task.deadlineDate
        }
    }
    var date: Box<Date?>
    
    init(task: Task) {
        self.task = task
        date = Box(task.deadlineDate)
    }
    
}
