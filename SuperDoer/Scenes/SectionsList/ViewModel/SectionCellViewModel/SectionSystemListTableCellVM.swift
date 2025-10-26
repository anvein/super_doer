import Foundation

class SectionSystemListTableCellVM: SectionListTableCellVMType {
    
    private var section: TaskSystemSection

    var title: String? {
        return section.title
    }
    
    var tasksCount: String {
        return String(section.tasksCount)
    }
    
    var type: TaskSystemSection.SectionType {
        return section.type
    }
    
    init(section: TaskSystemSection) {
        self.section = section
    }
    
}
