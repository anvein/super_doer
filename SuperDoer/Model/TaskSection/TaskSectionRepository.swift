final class TaskSectionRepository {
    private let coreDataManager: TaskSectionCoreDataManager
    private let systemSectionsFactory: SystemSectionsFactory

    init(coreDataManager: TaskSectionCoreDataManager, systemSectionsFactory: SystemSectionsFactory) {
        self.coreDataManager = coreDataManager
        self.systemSectionsFactory = systemSectionsFactory
    }

    func getActiveCustomSectionsListWithOrder() -> [CDTaskCustomSection] {
        return coreDataManager.getCustomSectionsWithOrder()
    }

    func getSystemSectionsList() -> [TaskSystemSection] {
        // TODO: предусмотреть, чтобы в случае скрывания списков они не создавались (настройки брать в UserDefaults / CoreData)
        return systemSectionsFactory.buildSections()
    }

    func archiveCustomSection(_ section: CDTaskCustomSection) {
        coreDataManager.updateCustomSectionField(isArchive: true, section: section)
    }

    func createCustomSection(title: String) -> CDTaskCustomSection {
        coreDataManager.createCustomSectionWith(title: title)
    }

    func deleteCustomSection(_ section: CDTaskCustomSection) {
        coreDataManager.deleteSection(section)
    }

}
