
import Foundation

/// ViewModel для ячейки таблицы с системным списком
class TaskSectionSystemTableViewCellViewModel: TaskSectionTableViewCellViewModelType {
    
    private var section: TaskSectionSystem

    var title: String? {
        return section.title
    }
    
    var tasksCount: String {
        return String(section.tasksCount)
    }
    
    var type: TaskSectionSystem.SectionType {
        return section.type
    }
    
    init(section: TaskSectionSystem) {
        self.section = section
    }
    
}
