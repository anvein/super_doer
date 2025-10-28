import Foundation
import CoreData

class TaskSectionCoreDataManager {
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
    func getCustomSectionsWithOrder(isActive: Bool? = nil) -> [CDTaskCustomSection] {
        let fetchRequest: NSFetchRequest<CDTaskCustomSection> = CDTaskCustomSection.fetchRequest()
        
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
            let sections = try coreDataStack.viewContext.fetch(fetchRequest)
            return sections
        } catch let error as NSError {
            fatalError("get custom sections error - \(error)")
        }
    }

    func getSection(by id: UUID) -> CDTaskCustomSection? {
        let request = CDTaskCustomSection.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)

        do {
            return try coreDataStack.viewContext.fetch(request).first
        } catch let error as NSError {
            fatalError("getSection id error - \(error)")
        }
    }

    // MARK: insert
    func createCustomSectionWith(title: String, order: Int = 100, isCycled: Bool = false) -> CDTaskCustomSection {
        let section = CDTaskCustomSection(context: coreDataStack.viewContext)
        
        section.id = UUID()
        section.title = title
        section.order = Int32(order)
        section.isCycledList = isCycled
        
        coreDataStack.saveContext()

        return section
    }
    
    
    // MARK: update
    func updateCustomSectionField(title: String, section: CDTaskCustomSection) {
        section.title = title
        coreDataStack.saveContext()
    }
    
    func updateCustomSectionField(isArchive: Bool, section: CDTaskCustomSection) {
        section.isArchived = isArchive
        coreDataStack.saveContext()
    }
    
    
    // MARK: delete
    func deleteSection(_ section: CDTaskCustomSection) {
        coreDataStack.viewContext.delete(section)
        coreDataStack.saveContext()
    }
    
    func deleteSections(_ sections: [CDTaskCustomSection]) {
        let context = coreDataStack.viewContext
        for section in sections {
            context.delete(section)
        }
        
        coreDataStack.saveContext()
    }
    
}
