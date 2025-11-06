import Foundation
import RxCocoa

/// ViewModel для установки кастомной даты напоминания у задачи

class TaskReminderCustomDateViewModel: CustomDateSetterViewModelType {
    var isShowReadyButton: Driver<Bool> = .empty()
    var isShowDeleteButton: Driver<Bool>  = .empty()

    var date: Driver<Date>  = .empty()

    var inputEvents: PublishRelay<CustomDateSetterInputEvent> = .init()
}

//class TaskReminderCustomDateViewModel: CustomDateSetterViewModelType {
//    
//    private var task: CDTask {
//        didSet {
//            deadlineDate.value = task.reminderDateTime
//            refreshIsShowDeleteButton(fromTask: task)
//        }
//    }
//    
//    private var isShowReadyButton: UIBox<Bool> = UIBox(true)
//    private  var isShowDeleteButton: UIBox<Bool>
//
//    private  var deadlineDate: UIBox<Date?>
//
//
//    var defaultDate: Date {
//        return Date().setComponents(hours: 9, minutes: 0, seconds: 0)
//    }
//
//    // MARK: - Observable
//
//    var isShowReadyButtonObservable: UIBoxObservable<Bool> { isShowReadyButton.asObservable() }
//    var isShowDeleteButtonObservable: UIBoxObservable<Bool> { isShowDeleteButton.asObservable() }
//    var deadlineDateObservable: UIBoxObservable<Date?> { deadlineDate.asObservable() }
//
//    // MARK: - Init
//
//    init(task: CDTask) {
//        self.task = task
//        deadlineDate = UIBox(task.reminderDateTime)
//        
//        isShowDeleteButton = UIBox(false)
//        refreshIsShowDeleteButton(fromTask: task)
//    }
//
//    // MARK: -
//
//    private func refreshIsShowDeleteButton(fromTask task: CDTask) {
//        isShowDeleteButton.value = task.reminderDateTime != nil
//    }
//
//}
