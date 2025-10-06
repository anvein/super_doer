
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
    var content: NSAttributedString?
    var updatedAt: Date?

    init(contentAsHtml: String? = nil, dateUpdatedAt: Date? = nil) {
        self.content = convertToNsAttributedStringFrom(contentAsHtml: contentAsHtml)
        self.updatedAt = dateUpdatedAt
    }

    private func convertToNsAttributedStringFrom(contentAsHtml: String?) -> NSAttributedString? {
//        self.content = NSAttributedString(string: "", attributes: []).data(from: 0..<contentAsHtml.len, documentAttributes: <#T##[NSAttributedString.DocumentAttributeKey : Any]#>)
//        NSAttributedString().data(from: 0.., documentAttributes: <#T##[NSAttributedString.DocumentAttributeKey : Any]#>)
//
//        NSAttributedString(data: Data(), documentAttributes: <#T##AutoreleasingUnsafeMutablePointer<NSDictionary?>?#>)

        if let filledContentAsHtml = contentAsHtml {
            return NSAttributedString(string: filledContentAsHtml)
        } else {
            return nil
        }
    }
}
