
import Foundation

/// ViewModel базовый для ячейки списка ("списка задач")
protocol TaskSectionsTableViewCellViewModelType: AnyObject {
    var title: String? { get }
    var tasksCount: Int { get }
    
    func getTaskSection() -> TaskSectionProtocol
}
