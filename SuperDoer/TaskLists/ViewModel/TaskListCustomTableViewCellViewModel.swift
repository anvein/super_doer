

import Foundation

class TaskListCustomTableViewCellViewModel: TaskListTableViewCellViewModelType {
    
    private var list: TaskListCustom
    
    init(list: TaskListCustom) {
        self.list = list
    }
    
    var title: String? {
        return list.title
    }
    
    var tasksCount: Int {
        return Int(list.tasksCount)
    }
    
}
