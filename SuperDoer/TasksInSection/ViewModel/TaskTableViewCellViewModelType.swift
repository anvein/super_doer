
import Foundation

/// Протокол для TableViewCell в таблице со списком задач
protocol TaskTableViewCellViewModelType {
    var isCompleted: Bool { get }
    var isPriority: Bool { get }
    var title: String { get }
    
    var section: TaskSectionCustom? { get }
    
    var deadlineDate: Date? { get }
}
