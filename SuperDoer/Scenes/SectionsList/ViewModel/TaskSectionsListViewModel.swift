import Foundation

final class TaskSectionsListViewModel {

    typealias SectionGroup = [[TaskSectionProtocol]]

    // MARK: - Services

    private let coordinator: TaskSectionsListViewControllerCoordinator
    private let sectionEm: TaskSectionEntityManager
    private let systemSectionsBuilder: SystemSectionsBuilder

    // MARK: - Model

    static var systemSectionsId = 0
    static var customSectionsId = 1

    private var sections: UIBox<SectionGroup> = .init(SectionGroup())
    private var selectedSectionIndexPath: IndexPath?

    // MARK: - Init

    required init(
        coordinator: TaskSectionsListViewControllerCoordinator,
        sectionEm: TaskSectionEntityManager,
        systemSectionsBuilder: SystemSectionsBuilder
    ) {
        self.coordinator = coordinator
        self.sectionEm = sectionEm
        self.systemSectionsBuilder = systemSectionsBuilder

        self.sections = UIBox(SectionGroup())
    }

}

// MARK: - TaskSectionListViewModelType

extension TaskSectionsListViewModel: TaskSectionListViewModelType {

    // MARK: - Observable

    var sectionsObservable: UIBoxObservable<Sections> { sections.asObservable() }

    func loadInitialData() {
        var sections: [[TaskSectionProtocol]] = [[], []]

        sections[TaskSectionsListViewModel.systemSectionsId] = systemSectionsBuilder.buildSections()
        sections[TaskSectionsListViewModel.customSectionsId] = sectionEm.getCustomSectionsWithOrder()

        self.sections.value = sections
    }

    // MARK: get data for VC functions
    func getCountOfTableSections() -> Int {
        return sections.value.count
    }
    
    func getCountTaskSectionsInTableSection(withSectionId sectionId: Int) -> Int {
        return sections.value[sectionId].count
    }
    
//    func getTasksCountInSection(withSectionId id: Int) -> Int {
//        return Int.random(in: 0...11)
//    }
    
    func getTaskSectionTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> SectionListTableViewCellViewModelType? {
        let section = sections.value[indexPath.section][indexPath.row]
        
        switch section {
        case let taskSectionCustom as CDTaskSectionCustom :
            return SectionCustomListTableViewCellViewModel(section: taskSectionCustom)
        
        case let taskSectionSystem as TaskSectionSystem:
            return SectionSystemListTableViewCellViewModel(section: taskSectionSystem)
            
        default :
            return nil
        }
    }
    
    func selectTaskSection(with indexPath: IndexPath) {
        guard let section = sections.value[safe: indexPath.section]?[safe: indexPath.row] else { return }

        coordinator.startTasksInSectionFlow(section)

        // TODO: надо ли это? (вроде нет)
        self.selectedSectionIndexPath = indexPath
    }
    
    func getViewModelForSelectedRow() -> SectionListTableViewCellViewModelType? {
        guard let selectedIndexPath = selectedSectionIndexPath else {
            return nil
        }
    
        return getTaskSectionTableViewCellViewModel(forIndexPath: selectedIndexPath)
    }
    
    func getDeletableSectionViewModelFor(indexPath: IndexPath) -> TaskSectionDeletableViewModel? {
        let section = sections.value[indexPath.section][indexPath.row]
        guard let customSection = section as? CDTaskSectionCustom else {
            return nil
        }
        
        return TaskSectionDeletableViewModel.createFrom(
            section: customSection,
            indexPath: indexPath
        )
    }
    
    // MARK: model manipulate methods
    func createCustomTaskSectionWith(title: String) {
        let section = sectionEm.createCustomSectionWith(title: title)
        sections.value[TaskSectionsListViewModel.customSectionsId].insert(section, at: 0)
    }
    
    func deleteCustomSection(sectionViewModel: TaskSectionDeletableViewModel) {
        guard let indexPath = sectionViewModel.indexPath else { return }
        let section = sections.value[TaskSectionsListViewModel.customSectionsId][indexPath.row]
        guard let customSection = section as? CDTaskSectionCustom else { return }
        
        sectionEm.deleteSection(customSection)
        sections.value[TaskSectionsListViewModel.customSectionsId].remove(at: indexPath.row)
    }
    
    func archiveCustomSection(indexPath: IndexPath) {
        let section = sections.value[TaskSectionsListViewModel.customSectionsId][indexPath.row]
        guard let customSection = section as? CDTaskSectionCustom else {
            // TODO: залогировать, что сюда попал системный раздел (список)
            return
        }
        
        sectionEm.updateCustomSectionField(isArchive: true, section: customSection)
        sections.value[TaskSectionsListViewModel.customSectionsId].remove(at: indexPath.item)
    }
    
}

