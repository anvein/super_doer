import Foundation

protocol TaskDetailCoordinatorType: AnyObject {
    func startReminderDateSetter()
    func startDeadlineDateSetter(deadlineAt: Date?)
    func startRepeatPeriodSetter()
    func startDescriptionEditor(with data: TextEditorData)
    func startAddFile()
    func startDeleteFileConfirmation(viewModel: TaskFileDeletableViewModel)

    func didCloseTaskDetail()
}
