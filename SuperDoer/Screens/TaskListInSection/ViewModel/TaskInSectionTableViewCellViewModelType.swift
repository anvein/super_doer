
import Foundation

/// Протокол для TableViewCell в таблице со списком задач
protocol TaskInSectionTableViewCellViewModelType {
    var isCompleted: Bool { get }
    var isPriority: Bool { get }
    var title: String { get }
    
    var deadlineDate: Date? { get }
    
    var sectionTitle: String? { get }
    
}
