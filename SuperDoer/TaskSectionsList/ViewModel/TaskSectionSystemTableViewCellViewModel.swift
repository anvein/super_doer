
import Foundation

/// ViewModel для ячейки таблицы с системным списком
class TaskSectionSystemTableViewCellViewModel: TaskSectionsTableViewCellViewModelType {
    
    private var section: TaskSectionSystem
    
    init(section: TaskSectionSystem) {
        self.section = section
    }
    
    var title: String? {
        return section.title
    }
    
    var tasksCount: Int {
        return Int(section.tasksCount)
    }
    
    var type: TaskSectionSystem.SectionType {
        return section.type
    }
    
    func getTaskSection() -> TaskSectionProtocol /*TaskSectionSystem*/ {
        return section
    }
}
