
import Foundation

/// ViewModel для установки кастомной даты напоминания у задачи
class TaskReminderCustomDateViewModel: CustomDateSetterViewModelType {
    private var task: Task {
        didSet {
            date.value = task.reminderDateTime
            refreshIsShowDeleteButton(fromTask: task)
        }
    }
    
    var isShowReadyButton: Box<Bool> = Box(true)
    var isShowDeleteButton: Box<Bool>
    
    var date: Box<Date?>
    
    var defaultDate: Date {
        return Date().setComponents(hours: 9, minutes: 0, seconds: 0)
    }
    
    init(task: Task) {
        self.task = task
        date = Box(task.reminderDateTime)
        
        isShowDeleteButton = Box(false)
        refreshIsShowDeleteButton(fromTask: task)
    }
    
    private func refreshIsShowDeleteButton(fromTask task: Task) {
        isShowDeleteButton.value = task.reminderDateTime != nil
    }

}
