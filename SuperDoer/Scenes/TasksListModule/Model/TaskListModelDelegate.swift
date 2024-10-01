
import Foundation

protocol TaskListModelDelegate: AnyObject {
    func taskListModelBeginUpdates()
    func taskListModelEndUpdates()

    func taskListModelTaskDidCreate(indexPath: IndexPath)
    func taskListModelTaskDidUpdate(in indexPath: IndexPath, taskItem: TaskListItem)
    func taskListModelTaskDidMove(fromIndexPath: IndexPath, toIndexPath: IndexPath, taskItem: TaskListItem)
    func taskListModelTaskDidDelete(indexPath: IndexPath)

    func taskListModelSectionDidInsert(sectionIndex: Int)
    func taskListModelSectionDidDelete(sectionIndex: Int)

}
