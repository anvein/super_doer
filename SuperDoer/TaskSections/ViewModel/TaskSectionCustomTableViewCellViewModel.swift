

import Foundation

/// ViewModel для ячейки таблицы с касмтомным списком
class TaskSectionCustomTableViewCellViewModel: TaskSectionsTableViewCellViewModelType {
    
    private var section: TaskSectionCustom
    
    init(section: TaskSectionCustom) {
        self.section = section
    }
    
    var title: String? {
        return section.title
    }
    
    var tasksCount: Int {
        return Int(section.tasksCount)
    }
    
}
