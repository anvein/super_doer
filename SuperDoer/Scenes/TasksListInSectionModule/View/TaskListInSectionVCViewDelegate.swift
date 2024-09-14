
import Foundation

protocol TaskListInSectionVCViewDelegate: AnyObject {
    func taskListInSectionVCViewDidSelectTask(viewModel: TaskDetailViewModel)
    func taskListInSectionVCViewDidSelectDeleteTask(tasksIndexPaths: [IndexPath])
}
