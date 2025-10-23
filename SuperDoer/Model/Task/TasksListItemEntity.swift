import Foundation

struct TasksListItemEntity {
    var id: UUID?
    var title: String
    var sectionTitle: String?
    var description: String?
    var isCompleted: Bool
    var isPriority: Bool
    var isInMyDay: Bool
    var deadlineDate: Date?

    init(
        id: UUID? = nil,
        title: String,
        sectionTitle: String? = nil,
        description: String? = nil,
        isCompleted: Bool,
        isPriority: Bool,
        isInMyDay: Bool,
        deadlineDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.sectionTitle = sectionTitle
        self.description = description
        self.isCompleted = isCompleted
        self.isPriority = isPriority
        self.isInMyDay = isInMyDay
        self.deadlineDate = deadlineDate
    }

    init(cdTask: CDTask) {
        self.id = cdTask.id
        self.title = cdTask.title ?? "No title"
        self.sectionTitle = cdTask.section?.title
        self.description = cdTask.descriptionText
        self.isCompleted = cdTask.isCompleted
        self.isPriority = cdTask.isPriority
        self.isInMyDay = cdTask.inMyDay
        self.deadlineDate = cdTask.deadlineDate
    }
}
