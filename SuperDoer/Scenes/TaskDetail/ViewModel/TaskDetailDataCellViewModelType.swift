import Foundation

// MARK: TaskData classes

protocol TaskDetailDataCellViewModelType { }

struct AddToMyDayCellViewModel: TaskDetailDataCellViewModelType {
    var inMyDay: Bool = false
}

struct SubTaskCellViewModel: TaskDetailDataCellViewModelType {
    var isCompleted: Bool = false
    var title: String
}

struct AddSubTaskCellViewModel: TaskDetailDataCellViewModelType {

}

struct ReminderDateCellViewModel: TaskDetailDataCellViewModelType {
    var dateTime: Date?
}

struct DeadlineDateCellViewModel: TaskDetailDataCellViewModelType {
    var date: Date?
}

struct RepeatPeriodCellViewModel: TaskDetailDataCellViewModelType {
    // TODO: переделать тип
    var period: String?
}

struct AddFileCellVeiwModel: TaskDetailDataCellViewModelType {

}

struct FileCellViewModel: TaskDetailDataCellViewModelType {
    var id: UUID
    var name: String
    var fileExtension: String
    var size: Int

    var titleForDelete: String {
        return name
    }
}

struct DescriptionCellViewModel: TaskDetailDataCellViewModelType {
    var text: NSAttributedString?
    var updatedAt: Date?

    init(text: NSAttributedString? = nil, dateUpdatedAt: Date? = nil) {
        self.text = text
        self.updatedAt = dateUpdatedAt
    }
}
