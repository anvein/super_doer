

import UIKit

/// Таблица с кнопками для страницы просмотра / редактирования задачи
class TaskDetailTableView: UITableView {
    
    convenience init() {
        self.init(frame: .zero, style: .plain)
    }
    
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
        register(ReminderDateButtonCell.self, forCellReuseIdentifier: ReminderDateButtonCell.identifier)
        register(DeadlineDateButtonCell.self, forCellReuseIdentifier: DeadlineDateButtonCell.identifier)
        register(RepeatPeriodButtonCell.self, forCellReuseIdentifier: RepeatPeriodButtonCell.identifier)
        register(AddFileButtonCell.self, forCellReuseIdentifier: AddFileButtonCell.identifier)
        register(FileButtonCell.self, forCellReuseIdentifier: FileButtonCell.identifier)
        register(DescriptionButtonCell.self, forCellReuseIdentifier: DescriptionButtonCell.identifier)
        
        register(TaskDetailLabelsButtonCell.self, forCellReuseIdentifier: TaskDetailLabelsButtonCell.identifier)
    }
    
}
