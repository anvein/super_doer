import Foundation

protocol TaskDetailCoordinatorType: AnyObject {
    func startReminderDateSetter()
    func startDeadlineDateSetter(deadlineAt: Date?)
    func startRepeatPeriodSetter()
    func startDescriptionEditor(with data: TextEditorData)
    func startAddFileSourceSelect()
    func startDeleteFileConfirmation(viewModel: TaskFileDeletableViewModel)

    func didCloseTaskDetail()
}
