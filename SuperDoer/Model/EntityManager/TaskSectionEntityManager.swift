
import Foundation
import CoreData

class TaskSectionEntityManager: EntityManager {
    // MARK: select
    /// Возвращает пользовательские списки задач
    /// Не удаленные (deletedAt = nil)
    /// Отсортированные по order = ASC + title = ASC
    func getCustomListsWithOrder() -> [TaskSectionCustom] {
        let fetchRequest: NSFetchRequest<TaskSectionCustom> = TaskSectionCustom.fetchRequest()
        
        let deletedAtPredicate = NSPredicate(format: "deletedAt == nil")
        fetchRequest.predicate = deletedAtPredicate
        
        let sortByOrder = NSSortDescriptor(key: "order", ascending: false)
//        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortByOrder, /*sortByTitle*/]
        
        do {
            let sections = try getContext().fetch(fetchRequest)
            return sections
        } catch let error as NSError {
            fatalError("get custom sections error - \(error)")
        }
    }
    
    // MARK: insert
    func createCustomSectionWith(title: String, order: Int = 100, isCycled: Bool = false) -> TaskSectionCustom {
        let section = TaskSectionCustom(context: getContext())
        
        section.id = UUID()
        section.title = title
        section.order = Int32(order)
        section.isCycledList = isCycled
        
        saveContext()
        
        return section
    }
    
    
    // MARK: update
    func updateCustomSectionField(title: String, section: TaskSectionCustom) {
        section.title = title
        saveContext()
    }
}
