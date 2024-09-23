
import Foundation

protocol TaskListVCViewDelegate: AnyObject {
    func taskListVCViewDidSelectTask(viewModel: TaskDetailViewModel)
    func taskListVCViewDidSelectDeleteTask(tasksIndexPaths: [IndexPath])
    func taskListVCViewNavigationTitleDidChange(isVisible: Bool)
}
