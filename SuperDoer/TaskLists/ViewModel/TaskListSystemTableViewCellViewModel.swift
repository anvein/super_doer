

import Foundation

class TaskListSystemTableViewCellViewModel: TaskListTableViewCellViewModelType {
    
    private var list: TaskListSystem
    
    init(list: TaskListSystem) {
        self.list = list
    }
    
    var title: String? {
        return list.title
    }
    
    var tasksCount: Int {
        return Int(list.tasksCount)
    }
    
    var type: TaskListSystem.ListType {
        return list.type
    }
    
}
