
import Foundation

/// ViewModel базовый для ячейки списка разделов
protocol TaskSectionTableViewCellViewModelType: AnyObject {
    var title: String? { get }
    var tasksCount: String { get }
}
