
import Foundation

protocol TaskListInSectionViewModelType {
    
    var taskSectionTitle: String { get }
    
    
    func getTasksCount() -> Int
    
    func getTaskInSectionTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskInSectionTableViewCellViewModelType
    
    func getTaskViewModel(forIndexPath indexPath: IndexPath) -> TaskViewModel
    
    func createNewTaskInCurrentSectionWith(
        title: String,
        inMyDay: Bool,
        reminderDateTime: Date?,
        deadlineAt: Date?,
        description: String?
    )
    
    func deleteTasks(tasksIndexPaths: [IndexPath])
    
    func moveTasksInCurrentList(fromPath: IndexPath, to toPath: IndexPath)
}
