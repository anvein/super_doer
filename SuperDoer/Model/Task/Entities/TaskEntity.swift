import Foundation

struct TaskEntity {
    var id: UUID?
    var title: String
    var sectionTitle: String?
    var description: NSAttributedString?
    var isCompleted: Bool
    var isPriority: Bool
    var isInMyDay: Bool
    var deadlineDate: Date?
    var reminderDateTime: Date?
    var repeatPeriod: TaskRepeatPeriod?
    var files: [TaskFileEntity] = []
    var descriptionText: NSAttributedString?
    var descriptionUpdatedAt: Date?

    init(cdTask: CDTask) {
        self.id = cdTask.id
        self.title = cdTask.titlePrepared
        self.sectionTitle = cdTask.section?.title
        self.description = cdTask.descriptionTextAttributed
        self.isCompleted = cdTask.isCompleted
        self.isPriority = cdTask.isPriority
        self.isInMyDay = cdTask.inMyDay
        self.deadlineDate = cdTask.deadlineDate
        self.reminderDateTime = cdTask.reminderDateTime
        self.repeatPeriod = cdTask.repeatPeriodStruct
        self.files = Self.mapFiles(from: cdTask) ?? []
        self.descriptionText = cdTask.descriptionTextAttributed
        self.descriptionUpdatedAt = cdTask.descriptionUpdatedAt
    }

    func getFile(by id: UUID) -> TaskFileEntity? {
        for file in files {
            if let fileId = file.id, fileId.uuidString == id.uuidString {
                return file
            }
        }

        return nil
    }

    private static func mapFiles(from cdTask: CDTask) -> [TaskFileEntity]? {
        cdTask.files?.compactMap({ (cdFile) -> TaskFileEntity? in
            guard let cdFile = cdFile as? CDTaskFile else { return nil }
            return TaskFileEntity(cdTaskFile: cdFile)
        })
    }
}
