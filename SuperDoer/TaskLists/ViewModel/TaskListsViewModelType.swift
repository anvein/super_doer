
import Foundation

protocol TaskListsViewModelType {
    init(lists: [[TaskListProtocol]])
    
    func getCountOfLists() -> Int
    
    func getTasksCountInList(withListId listId: Int) -> Int
    
    func getTaskListCellViewModel(forIndexPath indexPath: IndexPath) -> TaskListTableViewCellViewModelType?
    
    func selectTaskList(forIndexPath indexPath: IndexPath)
    
    func createCustomTaskListWith(title: String)
    
    func getViewModelForSelectedRow() -> TaskListTableViewCellViewModelType?
    
}
