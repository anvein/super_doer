import CoreData
import Foundation

final class TaskFileCoreDataSource {

    private let coreDataStack: CoreDataStack

    // MARK: - Init

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    // MARK: get

    func getFile(by id: UUID) throws -> CDTaskFile? {
        let fetchRequest = CDTaskFile.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)

        do {
            return try coreDataStack.viewContext.fetch(fetchRequest).first
        } catch let error {
            throw CoreDataError.operationFailed(.fetch, entityName: CDTaskFile.entityName, error: error)
        }
    }

    // MARK: insert

    func createWith(
        fileName: String,
        fileExtension: String,
        fileSize: Int,
        task: CDTask,
        in context: NSManagedObjectContext? = nil
    ) -> CDTaskFile {
        let context = context ?? coreDataStack.viewContext
        let file = CDTaskFile(context: context)
        file.id = UUID()
        file.fileName = fileName
        file.fileExtension = fileExtension
        file.fileSize = Int32(fileSize)
        file.task = task

        return file
    }

    // MARK: delete

    func delete(file: CDTaskFile, in context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.viewContext
        context.delete(file)
    }
}
