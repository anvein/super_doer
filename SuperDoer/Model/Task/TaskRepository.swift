import Foundation

final class TaskRepository {
    enum UpdateActionField {
        case title(String?)
        case isCompleted(Bool)
        case isPriority(Bool)
        case inMyDay(Bool)
        case inMyDayToggle
        case deadlineDate(Date?)
        case reminderDateTime(Date?)
        case repeatPeriod(TaskRepeatPeriod?)
        case description(NSAttributedString?)
    }

    private let coreDataStack: CoreDataStack
    private let taskCoreDataSource: TaskCoreDataSource
    private let sectionCoreDataSource: TaskSectionCoreDataSource
    private let taskFileCoreDataSource: TaskFileCoreDataSource

    init(
        coreDataStack: CoreDataStack,
        taskCoreDataSource: TaskCoreDataSource,
        sectionCoreDataSource: TaskSectionCoreDataSource,
        taskFileCoreDataSource: TaskFileCoreDataSource
    ) {
        self.coreDataStack = coreDataStack
        self.taskCoreDataSource = taskCoreDataSource
        self.sectionCoreDataSource = sectionCoreDataSource
        self.taskFileCoreDataSource = taskFileCoreDataSource
    }

    func getTask(by id: UUID) throws -> TaskEntity? {
        do {
            return try taskCoreDataSource.getTaskBy(id: id)
                .map { TaskEntity(cdTask: $0) }
        } catch _ as CoreDataError {
            throw TaskRepositoryError.fetchDataError
        }
    }

    func createTask(with title: String, in section: TasksListSection) throws {
        let context = coreDataStack.viewContext

        do {
            var cdCustomSection: CDTaskCustomSection?
            switch section {
            case .custom(let sectionId):
                if let section = try sectionCoreDataSource.getSection(by: sectionId, from: context) {
                    cdCustomSection = section
                }

            case .system:
                break
            }

            taskCoreDataSource.createWith(title: title, section: cdCustomSection, in: context)
            try context.save()
        } catch {
            throw TaskRepositoryError.createTaskFailed(error: error)
        }
    }

    @discardableResult
    func updateField(_ field: UpdateActionField, taskId: UUID) throws -> TaskEntity {
        guard let cdTask = try? taskCoreDataSource.getTaskBy(id: taskId) else {
            throw TaskRepositoryError.taskNotFound
        }

        switch field {
        case .title(let title):
            cdTask.title = title

        case .isCompleted(let isCompleted):
            cdTask.isCompleted = isCompleted

        case .isPriority(let isPriority):
            cdTask.isPriority = isPriority

        case .inMyDay(let isInMyDay):
            cdTask.inMyDay = isInMyDay

        case .inMyDayToggle:
            cdTask.inMyDay.toggle()

        case .deadlineDate(let date):
            cdTask.deadlineDate = date

        case .reminderDateTime(let date):
            cdTask.reminderDateTime = date

        case .repeatPeriod(let taskRepeatPeriod):
            cdTask.repeatPeriodStruct = taskRepeatPeriod

        case .description(let descriptionText):
            taskCoreDataSource.updateFields(
                descriptionText: descriptionText,
                descriptionUpdatedAt: Date(),
                task: cdTask
            )
        }

        do {
            try coreDataStack.saveViewContext()
        } catch {
            throw TaskRepositoryError.updateTaskError
        }

        return TaskEntity(cdTask: cdTask)
    }

    func createFile(with name: String, ext: String, size: Int, taskId: UUID) throws -> (TaskEntity, TaskFileEntity) {
        do {
            guard let cdTask = try taskCoreDataSource.getTaskBy(id: taskId) else {
                throw NSError(
                    domain: "Repository",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Task with id \(taskId) not found"]
                )
            }

            let taskFile = taskFileCoreDataSource.createWith(
                fileName: name,
                fileExtension: ext,
                fileSize: size,
                task: cdTask
            )
            try coreDataStack.viewContext.save()

            return (
                TaskEntity(cdTask: cdTask),
                TaskFileEntity(cdTaskFile: taskFile)
            )
        } catch {
            throw TaskRepositoryError.createFileFalied(error: error)
        }
    }

    func deleteFile(_ file: TaskFileEntity) throws -> TaskEntity {
        do {
            guard let fileId = file.id else {
                throw ModelError.commonError(descriptoin: "File not have id", error: nil)
            }

            guard let taskId = file.taskId else {
                throw ModelError.commonError(descriptoin: "TaskFile not have taskId", error: nil)
            }

            guard let cdTask = try taskCoreDataSource.getTaskBy(id: taskId) else {
                throw ModelError.commonError(descriptoin: "Task with id \(taskId) not found", error: nil)
            }

            guard let cdTaskFile = try taskFileCoreDataSource.getFile(by: fileId) else {
                throw ModelError.commonError(descriptoin: "TaskFile with id \(fileId) not found", error: nil)
            }

            taskFileCoreDataSource.delete(file: cdTaskFile)
            try coreDataStack.viewContext.save()

            return TaskEntity(cdTask: cdTask)
        } catch {
            throw TaskRepositoryError.deleteFileFailed(error: error)
        }
    }

}
