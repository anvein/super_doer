
import Foundation

/// ViewModel базовый для ячейки списка разделов
protocol TaskSectionListTableViewCellViewModelType: AnyObject {
    var title: String? { get }
    var tasksCount: String { get }
}
