

import UIKit

/// Таблица с кнопками для страницы просмотра / редактирования задачи
class TaskDataTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
    
        estimatedSectionFooterHeight = 30
        sectionFooterHeight = 30
         
        sectionHeaderTopPadding = 0
        
        separatorStyle = .none
        
        backgroundColor = nil
        
        register(AddSubtaskButtonCell.self, forCellReuseIdentifier: AddSubtaskButtonCell.identifier)
        
        register(AddToMyDayButtonCell.self, forCellReuseIdentifier: AddToMyDayButtonCell.identifier)
        register(RemindButtonCell.self, forCellReuseIdentifier: RemindButtonCell.identifier)
        register(TaskDataDeadlineCell.self, forCellReuseIdentifier: TaskDataDeadlineCell.identifier)
        register(RepeatButtonCell.self, forCellReuseIdentifier: RepeatButtonCell.identifier)
        register(AddFileButtonCell.self, forCellReuseIdentifier: AddFileButtonCell.identifier)
        register(FileButtonCell.self, forCellReuseIdentifier: FileButtonCell.identifier)
        register(DescriptionButtonCell.self, forCellReuseIdentifier: DescriptionButtonCell.identifier)
        
        register(TaskViewLabelsButtonCell.self, forCellReuseIdentifier: TaskViewLabelsButtonCell.identifier)
    }
    
}


// MARK: TaskData classes
protocol TaskDataCellValueProtocol {
    
}

struct AddToMyDayCellValue: TaskDataCellValueProtocol {
    var inMyDay: Bool = false
}

struct SubTaskCellValue: TaskDataCellValueProtocol {
    var isCompleted: Bool = false
    var title: String
}

struct AddSubTaskCellValue: TaskDataCellValueProtocol {
    
}

struct RemindCellValue: TaskDataCellValueProtocol {
    var dateTime: Date?
}

struct DeadlineCellValue: TaskDataCellValueProtocol {
    var date: Date?
}

struct RepeatCellValue: TaskDataCellValueProtocol {
    // TODO: определить параметры
}

struct AddFileCellValue: TaskDataCellValueProtocol {
    
}

struct FileCellValue: TaskDataCellValueProtocol {
    var id: UUID
    var name: String
    var fileExtension: String
    var size: Int
}


struct DescriptionCellValue: TaskDataCellValueProtocol {
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