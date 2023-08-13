

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

        estimatedSectionHeaderHeight = 1
        sectionHeaderHeight = 1
        sectionIndexBackgroundColor = .blue
        
        estimatedSectionFooterHeight = 0
        sectionFooterHeight = 0
        fillerRowHeight = 0
        
        sectionHeaderTopPadding = 0
        
        separatorStyle = .none
        
        backgroundColor = nil
        
        register(AddSubtaskButtonCell.self, forCellReuseIdentifier: AddSubtaskButtonCell.identifier)
        
        register(AddToMyDayButtonCell.self, forCellReuseIdentifier: AddToMyDayButtonCell.identifier)
        register(RemindButtonCell.self, forCellReuseIdentifier: RemindButtonCell.identifier)
        register(DeadlineButtonCell.self, forCellReuseIdentifier: DeadlineButtonCell.identifier)
        register(RepeatButtonCell.self, forCellReuseIdentifier: RepeatButtonCell.identifier)
        register(AddFileButtonCell.self, forCellReuseIdentifier: AddFileButtonCell.identifier)
        
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

// ячейка файла

// описание задачи
