import Foundation

class SectionCustomListTableCellVM: SectionListTableCellVMType {

    private var section: CDTaskCustomSection

    var title: String? {
        return section.title
    }

    var tasksCount: String {
        return String(section.tasksCount)
    }

    init(section: CDTaskCustomSection) {
        self.section = section
    }

}
