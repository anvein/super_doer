import Foundation

enum TaskDetailViewModelInputEvent {
    case needLoadInitialData

    case didTapResetValueInMyDay
    case didTapResetValueReminderDate
    case didTapResetValueDeadlineDate
    case didTapResetValueRepeatPeriod

    case didChangeIsCompleted(newValue: Bool)
    case didChangeIsPriority(newValue: Bool)
    case didToggleValueInMyDay

    case didBeginTaskTitleEditing
    case didEndTaskTitleEditing(newValue: String?)

    case didTapTextEditingReadyBarButton

    case didTapOpenDeadlineDateSetter
    case didTapOpenReminderDateSetter
    case didTapOpenRepeatPeriodSetter
    case didTapAddFile
    case didTapFileDelete(indexPath: IndexPath)
    case didTapOpenDescriptionEditor
}
