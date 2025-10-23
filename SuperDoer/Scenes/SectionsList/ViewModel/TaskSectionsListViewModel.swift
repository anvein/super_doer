
import Foundation

/// ViewModel страницы с таблицей списков (разделов)
class TaskSectionsListViewModel {

   
    typealias SectionGroup = [[TaskSectionProtocol]]

    // MARK: - Services

    private var sectionEm: TaskSectionEntityManager


    // MARK: - Model

    static var systemSectionsId = 0
    static var customSectionsId = 1

    private var sections: UIBox<SectionGroup>
    private var selectedSectionIndexPath: IndexPath?

    // MARK: - Init

    required init(
        sectionEm: TaskSectionEntityManager,
        sections: SectionGroup
    ) {
        self.sectionEm = sectionEm
        self.sections = UIBox(sections)
    }
}

// MARK: - TaskSectionListViewModelType

extension TaskSectionsListViewModel: TaskSectionListViewModelType {

    // MARK: - Observable

    var sectionsObservable: UIBoxObservable<Sections> { sections.asObservable() }

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
    
    func selectTaskSection(forIndexPath indexPath: IndexPath) {
        self.selectedSectionIndexPath = indexPath
    }
    
    func getViewModelForSelectedRow() -> SectionListTableViewCellViewModelType? {
        guard let selectedIndexPath = selectedSectionIndexPath else {
            return nil
        }
    
        return getTaskSectionTableViewCellViewModel(forIndexPath: selectedIndexPath)
    }
   
    func getTaskListViewModel(forIndexPath indexPath: IndexPath) -> TasksListViewModelType? {
        guard let section = sections.value[safe: indexPath.section]?[safe: indexPath.row] else { return nil }

        switch section {
        case let taskSectionCustom as CDTaskSectionCustom:
            let taskCDManager = DIContainer.shared.resolve(TaskCoreDataManager.self)!
            return TasksListViewModel(
                repository: TasksListRepository(
                    taskSection: section,
                    taskCDManager: taskCDManager
                ),
                sectionCDManager: DIContainer.shared.resolve(TaskSectionEntityManager.self)!
            )

        case _ as TaskSectionSystem:
            // TODO: создать тип для системного списка (там будут другие параметры, скорей всего)
            return nil
        default :
            return nil
        }
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

