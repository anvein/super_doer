
import Foundation

/// ViewModel для установки кастомной даты дедлайна (выполнения задачи)
class TaskDeadlineDateCustomViewModel: CustomDateSetterViewModelType {
    
    var isShowReadyButton: Box<Bool> = Box(true)
    var isShowDeleteButton: Box<Bool> = Box(false)
    
    var deadlineDate: Box<Date?>
    
    var defaultDate: Date {
        return Date()
    }
    
    init(taskDeadlineDate: Date?) {
        deadlineDate = Box(taskDeadlineDate)
    }
    
}
