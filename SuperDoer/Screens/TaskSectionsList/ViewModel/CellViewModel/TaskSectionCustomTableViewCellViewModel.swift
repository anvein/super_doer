

import Foundation

/// ViewModel для ячейки таблицы с касмтомным списком
class TaskSectionCustomTableViewCellViewModel: TaskSectionTableViewCellViewModelType {
    
    private var section: TaskSectionCustom
    
    var title: String? {
        return section.title
    }
    
    var tasksCount: String {
        return String(section.tasksCount)
    }
    
    init(section: TaskSectionCustom) {
        self.section = section
    }
    
}
