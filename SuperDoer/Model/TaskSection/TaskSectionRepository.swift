import Foundation

final class TaskSectionRepository {
    private let coreDataSource: TaskSectionCoreDataSource
    private let coreDataStack: CoreDataStack
    private let systemSectionsFactory: SystemSectionsFactory

    init(
        coreDataSource: TaskSectionCoreDataSource,
        coreDataStack: CoreDataStack,
        systemSectionsFactory: SystemSectionsFactory
    ) {
        self.coreDataSource = coreDataSource
        self.coreDataStack = coreDataStack
        self.systemSectionsFactory = systemSectionsFactory
    }

    func getSection(by id: UUID) throws -> TaskCustomSection? {
        do {
            return try coreDataSource.getSection(by: id)
                .map { TaskCustomSection(cdSectionCustom: $0) }
        } catch {
            throw TaskSectionRepositoryError.fetchFailed(error: error)
        }
    }

    func getActiveCustomSectionsListWithOrder() -> [CDTaskCustomSection] {
        return (try? coreDataSource.getCustomSectionsWithOrder()) ?? []
    }

    func getSystemSectionsList() -> [TaskSystemSection] {
        // TODO: предусмотреть, чтобы в случае скрывания списков они не создавались (настройки брать в UserDefaults / CoreData)
        return systemSectionsFactory.buildSections()
    }

    func archiveCustomSection(_ section: CDTaskCustomSection) {
        section.isArchived = true

        do {
            try coreDataStack.saveViewContext()
        } catch {

        }
    }

    func createCustomSection(title: String) throws -> CDTaskCustomSection {
        let cdSection = coreDataSource.createCustomSectionWith(title: title)

        do {
            try coreDataStack.saveViewContext()
            return cdSection
        } catch {
            throw TaskSectionRepositoryError.createFailed
        }
    }

    func deleteCustomSection(_ section: CDTaskCustomSection) {
        coreDataSource.deleteSection(section)
    }

    func updateCustomSectionField(title: String, with customSectionId: UUID) throws -> TaskCustomSection {
        guard let cdCustomSection = try? coreDataSource.getSection(by: customSectionId) else {
            throw TaskSectionRepositoryError.renameFailed(error: nil)
        }

        do {
            cdCustomSection.title = title
            try coreDataStack.saveViewContext()
            return TaskCustomSection(cdSectionCustom: cdCustomSection)
        } catch {
            throw TaskSectionRepositoryError.renameFailed(error: error)
        }
    }

}
