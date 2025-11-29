import CoreData

final class TaskCoreDataSource {

    private let coreDataStack: CoreDataStack

    // MARK: - Init

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - Get

    func getTaskBy(id: UUID) throws -> CDTask? {
        let fetchRequest = CDTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(CDTask.idKey) == %@", id.uuidString)

        do {
            return try coreDataStack.viewContext.fetch(fetchRequest).first
        } catch let error {
            throw CoreDataError.operationFailed(.fetch, entityName: CDTask.entityName, error: error)
        }
    }

    func getTasks(in taskSection: CDTaskCustomSection?) throws -> [CDTask] {
        let fetchRequest = CDTask.fetchRequest()
        if let taskSection {
            fetchRequest.predicate = NSPredicate(format: "section == %@", taskSection)
        }

        do {
            return try coreDataStack.viewContext.fetch(fetchRequest)
        } catch let error {
            throw CoreDataError.operationFailed(.fetch, entityName: CDTask.entityName, error: error)
        }
    }

    // MARK: - Insert

    @discardableResult
    func createWith(
        title: String,
        section: CDTaskCustomSection? = nil,
        in context: NSManagedObjectContext? = nil
    ) -> CDTask {
        let context = context ?? coreDataStack.viewContext
        let task = CDTask.self(context: context)
        task.id = UUID()
        task.title = title
        task.section = section
        task.createdAt = Date()

        return task
    }

    // MARK: - Update

    func updateFields(
        descriptionText: NSAttributedString?,
        descriptionUpdatedAt: Date,
        task: CDTask
    ) {
        task.descriptionTextAttributed = descriptionText
        task.descriptionUpdatedAt = descriptionUpdatedAt
    }

    // MARK: - Delete

    func delete(tasks: [CDTask]) {
        for task in tasks {
            coreDataStack.viewContext.delete(task)
        }
    }

    func delete(task: CDTask) {
        coreDataStack.viewContext.delete(task)
    }

}
