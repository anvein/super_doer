
import Foundation

protocol TaskListTableViewCellViewModelType: AnyObject {
    var title: String? { get }
    var tasksCount: Int { get }
}
