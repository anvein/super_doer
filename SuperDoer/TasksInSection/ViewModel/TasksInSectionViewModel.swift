
import Foundation

class TasksInSectionViewModel: TasksInSectionViewModelType {

    // TODO: переделать на DI-контейнер
    lazy var taskEm = TaskEntityManager()
    
    
    // MARK: data
    var tasks = [Task]()
    
    // TODO: переделать на TaskSectionProtocol
    var taskSection: TaskSectionCustom?
    
    
    init(taskSection: TaskSectionCustom) {
        self.taskSection = taskSection
        self.tasks = taskEm.getTasks(for: taskSection)
    }
    
    
    func getCountTasksInSection() -> Int {
        return tasks.count
    }
    
    func getTaskTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskTableViewCellViewModelType  {
        let viewModel = TaskTableViewCellViewModel(isCompleted: true, isPriority: true, title: "default", section: nil, deadlineDate: nil)
        
        return viewModel
    }
    
}
