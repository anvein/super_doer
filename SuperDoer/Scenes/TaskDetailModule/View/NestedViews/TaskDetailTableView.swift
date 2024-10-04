
import UIKit

final class TaskDetailTableView: UITableView {

    // MARK: - Init
    init() {
        super.init(frame: .zero, style: .plain)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        delaysContentTouches = false
        sectionHeaderTopPadding = 0
        
        separatorStyle = .none
        backgroundColor = nil
        
        register(TaskDetailAddSubtaskCell.self, forCellReuseIdentifier: TaskDetailAddSubtaskCell.className)
        register(TaskDetailAddToMyDayCell.self, forCellReuseIdentifier: TaskDetailAddToMyDayCell.className)
        register(TaskDetailReminderDateCell.self, forCellReuseIdentifier: TaskDetailReminderDateCell.className)
        register(TaskDetailDeadlineDateCell.self, forCellReuseIdentifier: TaskDetailDeadlineDateCell.className)
        register(TaskDetailRepeatPeriodCell.self, forCellReuseIdentifier: TaskDetailRepeatPeriodCell.className)
        register(TaskDetailAddFileCell.self, forCellReuseIdentifier: TaskDetailAddFileCell.className)
        register(TaskDetailFileCell.self, forCellReuseIdentifier: TaskDetailFileCell.className)
        register(TaskDetailDescriptionCell.self, forCellReuseIdentifier: TaskDetailDescriptionCell.className)
        register(TaskDetailLabelsButtonCell.self, forCellReuseIdentifier: TaskDetailLabelsButtonCell.className)
    }
    
}
