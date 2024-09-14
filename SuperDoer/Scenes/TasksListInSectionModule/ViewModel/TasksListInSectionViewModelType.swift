
import Foundation

protocol TasksListInSectionViewModelType {
    
    var taskSectionTitle: String { get }
    
    
    func getTasksCount() -> Int
    
    func getTaskInSectionTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskInSectionTableViewCellViewModelType
    
    func getTaskDetailViewModel(forIndexPath indexPath: IndexPath) -> TaskDetailViewModel?
    
    func getTaskDeletableViewModels(forIndexPaths indexPaths: [IndexPath]) -> [TaskDeletableViewModel]
    
    func createNewTaskInCurrentSectionWith(
        title: String,
        inMyDay: Bool,
        reminderDateTime: Date?,
        deadlineAt: Date?,
        description: String?
    )
    
    func deleteTasks(taskViewModels: [DeletableItemViewModelType])
    
    func moveTasksInCurrentList(fromPath: IndexPath, to toPath: IndexPath)
    
}
