import Foundation

struct DescriptionCellViewModel: TaskDetailTableCellViewModelType {
    var text: NSAttributedString?
    var updatedAt: Date?

    init(text: NSAttributedString? = nil, dateUpdatedAt: Date? = nil) {
        self.text = text
        self.updatedAt = dateUpdatedAt
    }
}
