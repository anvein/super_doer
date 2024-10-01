
import Foundation

protocol TasksListViewModelType {
    
    var taskSectionTitle: String { get }

    func viewDidLoad()

    func getSectionsCount() -> Int
    func getTasksCountIn(section: Int) -> Int

    func getTaskTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskTableViewCellViewModelType
    
    func getTaskDetailViewModel(forIndexPath indexPath: IndexPath) -> TaskDetailViewModel?
    
    func getTaskDeletableViewModels(forIndexPaths indexPaths: [IndexPath]) -> [TaskDeletableViewModel]
    
    func createNewTaskInCurrentSectionWith(
        title: String,
        inMyDay: Bool,
        reminderDateTime: Date?,
        deadlineAt: Date?,
        description: String?
    )

    func switchTaskFieldIsCompletedWith(indexPath: IndexPath)
    func switchTaskFieldIsPriorityWith(indexPath: IndexPath)
    func switchTaskFieldInMyDayWith(indexPath: IndexPath)

    func deleteTasks(taskViewModels: [DeletableItemViewModelType])
    
    func moveTasksInCurrentList(fromPath: IndexPath, to toPath: IndexPath)
    
}
