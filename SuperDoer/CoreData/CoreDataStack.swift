import CoreData

final class CoreDataStack {
    static let mainModelName = "SuperDoer"

    let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    init(modelName: String, inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: modelName)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            persistentContainer.persistentStoreDescriptions = [description]
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                // TODO: залогировать
                print("CoreData load error: \(error)")
            }
        }

        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.undoManager = nil
    }

    func saveViewContext() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }

    // MARK: - Background context

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            context.automaticallyMergesChangesFromParent = true
            block(context)
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Error saving background context: \(error)")
                }
            }
        }
    }

    func perform<T>(_ block: (NSManagedObjectContext) throws -> T, in context: NSManagedObjectContext) throws -> T? {
        var result: T?
        var caughtError: Error?

        context.performAndWait {
            do {
                result = try block(context)
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                caughtError = error
            }
        }

        if let error = caughtError {
            throw error
        }
        return result
    }
}
