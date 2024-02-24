
import UIKit
import CoreData

/// Entity manager for Core Data entities (кто-то называет его CoreData Manager)
class EntityManager {
    private var managedObjectContext: NSManagedObjectContext? = nil
    
    func getContext() -> NSManagedObjectContext {
        if let safeManagedObjectContext = managedObjectContext {
            return safeManagedObjectContext
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let safeManagedObjectContext = appDelegate.persistentContainer.viewContext

            managedObjectContext = safeManagedObjectContext

            return safeManagedObjectContext
        }
    }
    
    func saveContext () {
        let context = getContext()
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
