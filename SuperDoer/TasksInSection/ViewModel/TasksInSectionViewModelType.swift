
import Foundation

protocol TasksInSectionViewModelType {
    
    // TODO: после переделки на viewModel удалить из протокола свойства
    var tasks: [Task] { get set }
    var taskSection: TaskSectionCustom? { get set }
    var taskEm: TaskEntityManager { get }
    
    
    func getCountTasksInSection() -> Int
    
    func getTaskTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskTableViewCellViewModelType
    
}
