

import Foundation

/// ViewModel для ячейки таблицы с касмтомным списком
class SectionCustomListTableViewCellViewModel: SectionListTableViewCellViewModelType {
    
    private var section: CDTaskSectionCustom
    
    var title: String? {
        return section.title
    }
    
    var tasksCount: String {
        return String(section.tasksCount)
    }
    
    init(section: CDTaskSectionCustom) {
        self.section = section
    }
    
}
