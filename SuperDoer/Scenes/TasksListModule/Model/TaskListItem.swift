
import Foundation

struct TaskListItem {
    var id: UUID?
    var title: String
    var description: String?
    var isCompleted: Bool
    var isPriority: Bool

    init(
        id: UUID? = nil,
        title: String,
        description: String? = nil,
        isCompleted: Bool,
        isPriority: Bool
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.isPriority = isPriority
    }

    init(cdTask: CDTask) {
        self.id = cdTask.id
        self.title = cdTask.title ?? "No title"
        self.description = cdTask.descriptionText
        self.isCompleted = cdTask.isCompleted
        self.isPriority = cdTask.isPriority
    }
}
