import Foundation

enum TaskDetailNavigationEvent {
    case openDeadlineDateSetter(deadlineAt: Date?)
    case openReminderDateSetter
    case openRepeatPeriodSetter
    case openDescriptionEditor(TextEditorData)
    case openAddFile
    case openDeleteFileConfirmation(viewModel: TaskFileDeletableViewModel)
}
