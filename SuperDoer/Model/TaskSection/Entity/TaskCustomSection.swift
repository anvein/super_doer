import Foundation

struct TaskCustomSection: TaskSectionProtocol {
    let id: UUID?
    let isArchived: Bool
    let isCycledList: Bool
    let order: Int
    let title: String?
    let titleEmoji: String?
    let deletedAt: Date?

    var fullTitle: String {
        var resultEmoji: String = ""
        if let titleEmoji {
            resultEmoji = titleEmoji + " "
        }

        return "\(resultEmoji)\(title ?? "")"
    }

    init(cdSectionCustom: CDTaskCustomSection) {
        self.id = cdSectionCustom.id
        self.isArchived = cdSectionCustom.isArchived
        self.isCycledList = cdSectionCustom.isCycledList
        self.order = Int(cdSectionCustom.order)
        self.title = cdSectionCustom.title
        self.titleEmoji = cdSectionCustom.titleEmoji
        self.deletedAt = cdSectionCustom.deletedAt
    }
}
