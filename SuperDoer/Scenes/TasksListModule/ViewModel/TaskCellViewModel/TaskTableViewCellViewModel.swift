
import Foundation

class TaskTableViewCellViewModel: TaskTableViewCellViewModelType {

    private var task: TaskListItem

    // MARK: - Services

    private let taskAttributesFormatter: TaskCellAttributesFormatterService

    // MARK: -

    var isCompleted: Bool {
        return task.isCompleted
    }
    
    var isPriority: Bool {
        return task.isPriority
    }
    
    var title: String {
        return task.title
    }

    var attributes: NSAttributedString? {
        return taskAttributesFormatter.formatTaskAttributesForCellInList(from: task)
    }

    // MARK: - Init

    init(
        task: TaskListItem,
        taskAttributesFormatter: TaskCellAttributesFormatterService = .init()
    ) {
        self.task = task
        self.taskAttributesFormatter = taskAttributesFormatter
    }

}
