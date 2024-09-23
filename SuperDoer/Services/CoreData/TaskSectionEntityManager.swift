
import Foundation
import CoreData

class TaskSectionEntityManager {
    private let coreDataStack: CoreDataStack

    // MARK: - Init

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: select
    /// Возвращает пользовательские списки задач
    /// Не удаленные (deletedAt = nil)
    /// Отсортированные по order = ASC + title = ASC
    /// Параметр isActive влияет на isArchived
    func getCustomSectionsWithOrder(isActive: Bool? = nil) -> [TaskSectionCustom] {
        let fetchRequest: NSFetchRequest<TaskSectionCustom> = TaskSectionCustom.fetchRequest()
        
        let deletedAtPredicate = NSPredicate(format: "deletedAt == nil")
        fetchRequest.predicate = deletedAtPredicate
        
        if isActive == false {
            let isActivePridicate = NSPredicate(format: "isArchived == 1")
            fetchRequest.predicate = isActivePridicate
        }
        
        let sortByOrder = NSSortDescriptor(key: "order", ascending: false)
//        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortByOrder, /*sortByTitle*/]
        
        do {
            let sections = try coreDataStack.context.fetch(fetchRequest)
            return sections
        } catch let error as NSError {
            fatalError("get custom sections error - \(error)")
        }
    }
    
    // MARK: insert
    func createCustomSectionWith(title: String, order: Int = 100, isCycled: Bool = false) -> TaskSectionCustom {
        let section = TaskSectionCustom(context: coreDataStack.context)
        
        section.id = UUID()
        section.title = title
        section.order = Int32(order)
        section.isCycledList = isCycled
        
        coreDataStack.saveContext()

        return section
    }
    
    
    // MARK: update
    func updateCustomSectionField(title: String, section: TaskSectionCustom) {
        section.title = title
        coreDataStack.saveContext()
    }
    
    func updateCustomSectionField(isArchive: Bool, section: TaskSectionCustom) {
        section.isArchived = isArchive
        coreDataStack.saveContext()
    }
    
    
    // MARK: delete
    func deleteSection(_ section: TaskSectionCustom) {
        coreDataStack.context.delete(section)
        coreDataStack.saveContext()
    }
    
    func deleteSections(_ sections: [TaskSectionCustom]) {
        let context = coreDataStack.context
        for section in sections {
            context.delete(section)
        }
        
        coreDataStack.saveContext()
    }
    
}
