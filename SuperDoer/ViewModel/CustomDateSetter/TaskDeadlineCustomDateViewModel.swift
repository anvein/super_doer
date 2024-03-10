
import Foundation

/// ViewModel для установки кастомной даты дедлайна (выполнения задачи)
class TaskDeadlineCustomDateViewModel: CustomDateSetterViewModelType {
    private var task: CDTask {
        didSet {
            date.value = task.deadlineDate
        }
    }
    
    var isShowReadyButton: Box<Bool> = Box(true)
    var isShowDeleteButton: Box<Bool> = Box(false)
    
    var date: Box<Date?>
    
    var defaultDate: Date {
        return Date()
    }
    
    init(task: CDTask) {
        self.task = task
        date = Box(task.deadlineDate)
    }
    
}
