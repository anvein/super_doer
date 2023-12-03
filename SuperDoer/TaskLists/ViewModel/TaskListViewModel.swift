
import Foundation

class TaskListViewModel: TaskListsViewModelType {
    
    // TODO: переделать на private (когда переведу на view model список задач)
     var lists: [[TaskListProtocol]]
    
    private var selectedListIndexPath: IndexPath?
    
    lazy var listEm = TaskListEntityManager()
    
    required init(lists: [[TaskListProtocol]]) {
        self.lists = lists
    }
    
    
    func getCountOfLists() -> Int {
        return lists.count
    }
    
    func getTasksCountInList(withListId listId: Int) -> Int {
        return lists[listId].count
    }
    
    func getTaskListCellViewModel(forIndexPath indexPath: IndexPath) -> TaskListTableViewCellViewModelType? {
        let list = lists[indexPath.section][indexPath.row]
        
        switch list {
        case let taskListCustom as TaskListCustom :
            return TaskListCustomTableViewCellViewModel(list: taskListCustom)
        
        case let taskListSystem as TaskListSystem:
            return TaskListSystemTableViewCellViewModel(list: taskListSystem)
            
        default :
            return nil
        }
    }
    
    func selectTaskList(forIndexPath indexPath: IndexPath) {
        self.selectedListIndexPath = indexPath
    }
    
    func createCustomTaskListWith(title: String) {
        let list = listEm.createCustomListWith(title: title)
        lists[1].insert(list, at: 0)
    }
    
    func getViewModelForSelectedRow() -> TaskListTableViewCellViewModelType? {
        guard let selectedIndexPath = selectedListIndexPath else {
            return nil
        }
        
        let taskList = lists[selectedIndexPath.section][selectedIndexPath.row]
        
        switch taskList {
        case let taskListCustom as TaskListCustom :
            return TaskListCustomTableViewCellViewModel(list: taskListCustom)
        
        case let taskListSystem as TaskListSystem:
            return TaskListSystemTableViewCellViewModel(list: taskListSystem)
            
        default :
            return nil
        }
    }
    
    
}
