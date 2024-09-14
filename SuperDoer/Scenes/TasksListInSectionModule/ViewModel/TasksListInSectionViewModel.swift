
import Foundation

class TasksListInSectionViewModel: TasksListInSectionViewModelType {

    // MARK: services
    private var taskEm: TaskEntityManager
    
    // MARK: data
    private var tasks = [CDTask]() {
        didSet {
            tasksUpdateBinding?()
        }
    }
    
    var tasksUpdateBinding: (() -> ())? // TODO: переделать на Rx???
    
    // TODO: переделать на TaskSectionProtocol
    private var taskSection: TaskSectionCustom
    
    var taskSectionTitle: String {
        return taskSection.title ?? ""
    }
    
    
    // MARK: init
    init(_ taskSection: TaskSectionCustom, taskEm: TaskEntityManager) {
        self.taskEm = taskEm
        
        self.taskSection = taskSection
        self.tasks = taskEm.getTasks(for: taskSection)
    }
    
    
    // MARK: get data for VC methods
    func getTasksCount() -> Int {
        return tasks.count
    }
    
    func getTaskInSectionTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskInSectionTableViewCellViewModelType  {
        let task = tasks[indexPath.row]
        
        return TaskInSectionTableViewCellViewModel(task: task)
    }
    
    func getTaskDetailViewModel(forIndexPath indexPath: IndexPath) -> TaskDetailViewModel? {
        guard let selectedTask = tasks[safe: indexPath.row] else { return nil }

        return TaskDetailViewModel(
            selectedTask,
            taskEm: DIContainer.shared.resolve(TaskEntityManager.self)!,
            taskFileEm: DIContainer.shared.resolve(TaskFileEntityManager.self)!
        )
    }
    
    func getTaskDeletableViewModels(forIndexPaths indexPaths: [IndexPath]) -> [TaskDeletableViewModel] {
        var viewModels: [TaskDeletableViewModel] = []
        for indexPath in indexPaths {
            let viewModel = TaskDeletableViewModel.createFrom(
                task: tasks[indexPath.row],
                indexPath: indexPath
            )
            viewModels.append(viewModel)
        }
        
        return viewModels
    }
    
    
    // MARK: model manipulation methods
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
    
    func deleteTasks(taskViewModels: [DeletableItemViewModelType]) {
        var deleteTasksArray = [CDTask]()
        
        for taskViewModel in taskViewModels {
            guard let indexPath = taskViewModel.indexPath else {
                // TODO: залогировать, что не указан indexPath
                continue
            }
            
            deleteTasksArray.append(tasks[indexPath.row])
            tasks.remove(at: indexPath.row)
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
