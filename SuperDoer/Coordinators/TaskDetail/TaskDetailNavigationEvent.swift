import Foundation

enum TaskDetailNavigationEvent {
    case openDeadlineDateSetter(deadlineAt: Date?)
    case openReminderDateSetter(dateTime: Date?)
    case openRepeatPeriodSetter(repeatPeriod: TaskRepeatPeriod?)
    case openDescriptionEditor(TextEditorData)
    case openAddFile
    case openDeleteFileConfirmation(TaskFileDeletableViewModel)
}
