import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SuperDoer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // TODO: обработать ошибку нормально
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("DB url - \(storeDescription.url?.absoluteString ?? "undefined")")
            }
        })
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext () {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                // TODO: обработать ошибку нормально
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
