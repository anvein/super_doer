
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
        register(ReminderDateButtonCell.self, forCellReuseIdentifier: ReminderDateButtonCell.className)
        register(DeadlineDateButtonCell.self, forCellReuseIdentifier: DeadlineDateButtonCell.className)
        register(RepeatPeriodButtonCell.self, forCellReuseIdentifier: RepeatPeriodButtonCell.className)
        register(AddFileButtonCell.self, forCellReuseIdentifier: AddFileButtonCell.className)
        register(FileButtonCell.self, forCellReuseIdentifier: FileButtonCell.className)
        register(DescriptionButtonCell.self, forCellReuseIdentifier: DescriptionButtonCell.className)
        register(TaskDetailLabelsButtonCell.self, forCellReuseIdentifier: TaskDetailLabelsButtonCell.className)
    }
    
}
