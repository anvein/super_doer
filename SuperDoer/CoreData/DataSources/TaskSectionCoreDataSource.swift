import CoreData
import Foundation

final class TaskSectionCoreDataSource {
    private let coreDataStack: CoreDataStack

    // MARK: - Init

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    // MARK: select

    /// Возвращает пользовательские списки задач
    /// Не удаленные (deletedAt = nil)
    /// Отсортированные по order = ASC + title = ASC
    /// Параметр isActive влияет на isArchived
    func getCustomSectionsWithOrder(isArchived: Bool? = nil) throws -> [CDTaskCustomSection] {
        let request: NSFetchRequest<CDTaskCustomSection> = CDTaskCustomSection.fetchRequest()
        var predicates: [NSPredicate] = []

        predicates.append(NSPredicate(format: "deletedAt == nil"))

        if let isArchived {
            predicates.append(NSPredicate(format: "isArchived == \(isArchived)"))
        }

        let sortByOrder = NSSortDescriptor(key: "order", ascending: false)
        // let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [sortByOrder /*sortByTitle*/]

        do {
            let sections = try coreDataStack.viewContext.fetch(request)
            return sections
        } catch let error as NSError {
            throw CoreDataError.operationFailed(.fetch, entityName: CDTaskCustomSection.entityName, error: error)
        }
    }

    func getSection(by id: UUID, from context: NSManagedObjectContext? = nil) throws -> CDTaskCustomSection? {
        let context = context ?? coreDataStack.viewContext
        let request = CDTaskCustomSection.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)

        do {
            return try context.fetch(request).first
        } catch let error as NSError {
            throw CoreDataError.operationFailed(.fetch, entityName: CDTaskCustomSection.entityName, error: error)
        }
    }

    // MARK: insert

    func createCustomSectionWith(title: String, order: Int = 100, isCycled: Bool = false) -> CDTaskCustomSection {
        let section = CDTaskCustomSection(context: coreDataStack.viewContext)

        section.id = UUID()
        section.title = title
        section.order = Int32(order)
        section.isCycledList = isCycled

        return section
    }

    // MARK: delete

    func deleteSection(_ section: CDTaskCustomSection) {
        coreDataStack.viewContext.delete(section)
    }

    func deleteSections(_ sections: [CDTaskCustomSection]) {
        for section in sections {
            coreDataStack.viewContext.delete(section)
        }
    }

}
