import Foundation
import RxCocoa

protocol TaskDetailCoordinatorType: AnyObject {
    var viewModelEventSignal: Signal<TaskDetailCoordinatorVmEvent> { get }

    func startReminderDateSetter()
    func startDeadlineDateSetter(deadlineAt: Date?)
    func startRepeatPeriodSetter()
    func startDecriptionEditor(with data: TextEditorData)
    func startAddFile()
    func startDeleteFileConfirmation(viewModel: TaskFileDeletableViewModel)

    func didCloseTaskDetail()
}
