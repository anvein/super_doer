
import Foundation

class TasksListViewModel: TasksListViewModelType {

    // MARK: - Model

    private let model: TaskListModel

//    private var tasks = [CDTask]()

    var tasksUpdateBinding: (() -> ())? // TODO: переделать на Rx???
    var onTasksListUpdate: ((TasksListUpdateType) -> Void)?

    // TODO: переделать на TaskSectionProtocol
    private var taskSection: CDTaskSectionCustom

    var taskSectionTitle: String {
        return taskSection.title ?? ""
    }

    // MARK: - Init

    init(model: TaskListModel, taskSection: CDTaskSectionCustom) {
        self.model = model
        self.taskSection = taskSection

        self.model.delegate  = self
    }

    // MARK: -

    func viewDidLoad() {
        model.loadTasks()
    }

    // MARK: get data for VC methods

    func getSectionsCount() -> Int {
        return model.getSectionsCount()
    }

    func getTasksCountIn(section: Int) -> Int {
        return model.getTasksCountIn(in: section)
    }
    
    func getTaskTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskTableViewCellViewModelType  {
        let task = model.getTask(for: indexPath)
        return TaskTableViewCellViewModel(task: task)
    }
    
    func getTaskDetailViewModel(forIndexPath indexPath: IndexPath) -> TaskDetailViewModel? {
        let selectedTask = model.getTask(for: indexPath)
        guard let taskId = selectedTask.id else { return nil }

        return TaskDetailViewModel(
            taskId,
            taskEm: DIContainer.shared.resolve(TaskCoreDataManager.self)!,
            taskFileEm: DIContainer.shared.resolve(TaskFileEntityManager.self)!
        )
    }
    
    func getTaskDeletableViewModels(forIndexPaths indexPaths: [IndexPath]) -> [TaskDeletableViewModel] {
        var viewModels: [TaskDeletableViewModel] = []
        for indexPath in indexPaths {
            let viewModel = TaskDeletableViewModel(
                task: model.getTask(for: indexPath),
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
        model.createTaskWith(title: title, section: taskSection)
        // TODO: отловить ошибку, если не получилось создать и показать сообщение об этом
    }
    
    func deleteTasks(taskViewModels: [DeletableItemViewModelType]) {
        var tasksIndexPaths = [IndexPath]()

        for taskViewModel in taskViewModels {
            guard let indexPath = taskViewModel.indexPath else { continue }
            tasksIndexPaths.append(indexPath)
        }
        
        model.deleteTasksWith(indexPaths: tasksIndexPaths)
    }
    
    func moveTasksInCurrentList(fromPath: IndexPath, to toPath: IndexPath) {
        
//        let moveElement = tasks[fromPath.row]
//        tasks[fromPath.row] = tasks[toPath.row]
//        tasks[toPath.row] = moveElement
 
        // TODO: реализовать перемещение в CoreData
    }

    // MARK: - Update

    func switchTaskFieldIsCompletedWith(indexPath: IndexPath) {
        model.updateAndSwitchIsCompletedFieldWith(indexPath: indexPath)
    }

    func switchTaskFieldIsPriorityWith(indexPath: IndexPath) {
        model.updateAndSwitchIsPriorityFieldWith(indexPath: indexPath)
    }

    func switchTaskFieldInMyDayWith(indexPath: IndexPath) {
        model.switchAndUpdateInMyDayFieldWith(indexPath: indexPath)
    }

}

// MARK: - TaskListModelDelegate

extension TasksListViewModel: TaskListModelDelegate {
    func taskListModelBeginUpdates() {
        onTasksListUpdate?(.beginUpdates)
    }

    func taskListModelEndUpdates() {
        onTasksListUpdate?(.endUpdates)
    }


    func taskListModelTaskDidCreate(indexPath: IndexPath) {
        onTasksListUpdate?(.insertTask(indexPath))
    }
    
    func taskListModelTaskDidUpdate(in indexPath: IndexPath, taskItem: TaskListItem) {
        onTasksListUpdate?(.updateTask(
            indexPath,
            TaskTableViewCellViewModel(task: taskItem)
        ))
    }
    
    func taskListModelTaskDidMove(fromIndexPath: IndexPath, toIndexPath: IndexPath, taskItem: TaskListItem) {
        onTasksListUpdate?(.moveTask(
            fromIndexPath,
            toIndexPath,
            TaskTableViewCellViewModel(task: taskItem)
        ))
    }
    
    func taskListModelTaskDidDelete(indexPath: IndexPath) {
        onTasksListUpdate?(.deleteTask(indexPath))
    }
    
    func taskListModelSectionDidInsert(sectionIndex: Int) {
        onTasksListUpdate?(.insertSection(sectionIndex))
    }
    
    func taskListModelSectionDidDelete(sectionIndex: Int) {
        onTasksListUpdate?(.deleteSection(sectionIndex))
    }

}
