

import UIKit

/// Таблица с кнопками для страницы просмотра / редактирования задачи
class TaskViewButtonsTableView: UITableView {
    
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
        register(DeadlineButtonCell.self, forCellReuseIdentifier: DeadlineButtonCell.identifier)
        register(RepeatButtonCell.self, forCellReuseIdentifier: RepeatButtonCell.identifier)
        register(AddFileButtonCell.self, forCellReuseIdentifier: AddFileButtonCell.identifier)
        register(FileButtonCell.self, forCellReuseIdentifier: FileButtonCell.identifier)
        register(DescriptionButtonCell.self, forCellReuseIdentifier: DescriptionButtonCell.identifier)
        
        register(TaskViewLabelsButtonCell.self, forCellReuseIdentifier: TaskViewLabelsButtonCell.identifier)
    }

    
}

protocol ButtonCellValueProtocol {
    
}

struct AddToMyDayCellValue: ButtonCellValueProtocol {
    var inMyDay: Bool = false
}

struct SubTaskCellValue: ButtonCellValueProtocol {
    var isCompleted: Bool = false
    var title: String
}

struct AddSubTaskCellValue: ButtonCellValueProtocol {
    
}

struct RemindCellValue: ButtonCellValueProtocol {
    var dateTime: Date?
}

struct DeadlineCellValue: ButtonCellValueProtocol {
    var date: Date?
}

struct RepeatCellValue: ButtonCellValueProtocol {
    // TODO: определить параметры
}

struct AddFileCellValue: ButtonCellValueProtocol {
    
}

struct FileCellValue: ButtonCellValueProtocol {
    var fileExtension: String?
    var fileName: String?
    var fileSize: String?
}


struct DescriptionCellValue: ButtonCellValueProtocol {
    var text: NSAttributedString?
    var dateUpdated: String?
}
