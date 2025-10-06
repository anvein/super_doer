
import Foundation

protocol TasksListVCViewDelegate: AnyObject {
    func tasksListVCViewDidSelectTask(viewModel: TaskDetailViewModel)
    func tasksListVCViewDidSelectDeleteTask(tasksIndexPaths: [IndexPath])
    func tasksListVCViewNavigationTitleDidChange(isVisible: Bool)
}
