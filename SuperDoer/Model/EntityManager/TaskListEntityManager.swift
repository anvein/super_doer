
import Foundation
import CoreData

class TaskListEntityManager: EntityManager {
    // MARK: select
    /// Возвращает пользовательские списки задач
    /// Не удаленные (deletedAt = nil)
    /// Отсортированные по order = ASC + title = ASC
    func getCustomListsWithOrder() -> [TaskListCustom] {
        let fetchRequest: NSFetchRequest<TaskListCustom> = TaskListCustom.fetchRequest()
        
        let deletedAtPredicate = NSPredicate(format: "deletedAt == nil")
        fetchRequest.predicate = deletedAtPredicate
        
        let sortByOrder = NSSortDescriptor(key: "order", ascending: true)
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortByOrder, sortByTitle]
        
        do {
            let sections = try getContext().fetch(fetchRequest)
            return sections
        } catch let error as NSError {
            fatalError("get custom sections error - \(error)")
        }
    }
    
    // MARK: insert
    func createCustomListWith(title: String, order: Int = 100, isCycled: Bool = false) -> TaskListCustom {
        let section = TaskListCustom(context: getContext())
        
        section.id = UUID()
        section.title = title
        section.order = Int32(order)
        section.isCycledList = isCycled
        
        saveContext()
        
        return section
    }
    
}
