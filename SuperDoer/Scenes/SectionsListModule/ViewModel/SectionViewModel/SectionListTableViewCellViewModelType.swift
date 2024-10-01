
import Foundation

/// ViewModel базовый для ячейки списка разделов
protocol SectionListTableViewCellViewModelType: AnyObject {
    var title: String? { get }
    var tasksCount: String { get }
}
