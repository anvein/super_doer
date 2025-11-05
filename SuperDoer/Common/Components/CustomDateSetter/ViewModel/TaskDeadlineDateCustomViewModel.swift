import Foundation

/// ViewModel для установки кастомной даты дедлайна (выполнения задачи)
class TaskDeadlineDateCustomViewModel: CustomDateSetterViewModelType {

    private var isShowReadyButton: UIBox<Bool> = UIBox(true)
    private var isShowDeleteButton: UIBox<Bool> = UIBox(false)

    private var deadlineDate: UIBox<Date?>

    var defaultDate: Date {
        return Date()
    }

    // MARK: - Observable

    var isShowReadyButtonObservable: UIBoxObservable<Bool> { isShowReadyButton.asObservable() }
    var isShowDeleteButtonObservable: UIBoxObservable<Bool> { isShowDeleteButton.asObservable() }
    var deadlineDateObservable: UIBoxObservable<Date?> { deadlineDate.asObservable() }

    // MARK: - Init

    init(taskDeadlineDate: Date?) {
        deadlineDate = UIBox(taskDeadlineDate)
    }
    
}
