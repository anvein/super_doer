
import Foundation

protocol TaskCreateBottomPanelDelegate: AnyObject {

    func taskCreateBottomPanelDidTapCreateButton(
        title: String,
        inMyDay: Bool,
        reminderDateTime: Date?,
        deadlineAt: Date?,
        description: String?
    )

    func taskCreateBottomPanelDidChangedState(newState: TaskCreateBottomPanel.State)
}
