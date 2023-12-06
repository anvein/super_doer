
import Foundation

/// ViewModel для ячейки таблицы с системным списком
class TaskSectionSystemTableViewCellViewModel: TaskSectionsTableViewCellViewModelType {
    
    private var list: TaskSectionSystem
    
    init(section: TaskSectionSystem) {
        self.list = section
    }
    
    var title: String? {
        return list.title
    }
    
    var tasksCount: Int {
        return Int(list.tasksCount)
    }
    
    var type: TaskSectionSystem.SectionType {
        return list.type
    }
    
}
