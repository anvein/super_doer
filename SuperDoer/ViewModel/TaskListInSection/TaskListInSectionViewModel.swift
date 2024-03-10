
import Foundation

class TaskListInSectionViewModel: TaskListInSectionViewModelType {
    
    // TODO: переделать на DI-контейнер
    private lazy var taskEm = TaskEntityManager()
    
    
    // MARK: data
    private var tasks = [CDTask]() {
        didSet {
            tasksUpdateBinding?()
        }
    }
    
    var tasksUpdateBinding: (() -> ())? // TODO: переделать на Box
    
    // TODO: переделать на TaskSectionProtocol
    private var taskSection: TaskSectionCustom
    
    
    var taskSectionTitle: String {
        return taskSection.title ?? ""
    }
    
    init(taskSection: TaskSectionCustom) {
        self.taskSection = taskSection
        self.tasks = taskEm.getTasks(for: taskSection)
    }
    
    
    
    func getTasksCount() -> Int {
        return tasks.count
    }
    
    func getTaskInSectionTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskInSectionTableViewCellViewModelType  {
        let task = tasks[indexPath.row]
        
        return TaskInSectionTableViewCellViewModel(task: task)
    }
    
    func getTaskViewModel(forIndexPath indexPath: IndexPath) -> TaskDetailViewModel {
        let selectedTask = tasks[indexPath.row]
        
        return TaskDetailViewModel(task: selectedTask)
    }
    
    func createNewTaskInCurrentSectionWith(
        title: String,
        inMyDay: Bool,
        reminderDateTime: Date?,
        deadlineAt: Date?,
        description: String?
    ) {
        let task = taskEm.createWith(title: title, section: taskSection)
        // TODO: отловить ошибку, если не получилось создать и показать сообщение об этом
        
        tasks.insert(task, at: 0)
    }
    
    func deleteTasks(tasksIndexPaths: [IndexPath]) {
        var deleteTasksArray = [CDTask]()
        
        for taskIndexPath in tasksIndexPaths {
            deleteTasksArray.append(tasks[taskIndexPath.row])
            tasks.remove(at: taskIndexPath.row)
        }
        
        taskEm.delete(tasks: deleteTasksArray)
    }
    
    func moveTasksInCurrentList(fromPath: IndexPath, to toPath: IndexPath) {
        let moveElement = tasks[fromPath.row]
        tasks[fromPath.row] = tasks[toPath.row]
        tasks[toPath.row] = moveElement
 
        // TODO: реализовать перемещение в CoreData
    }
    
}
