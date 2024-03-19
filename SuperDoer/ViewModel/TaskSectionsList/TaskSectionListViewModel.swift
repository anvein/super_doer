
import Foundation

/// ViewModel страницы с таблицей списков (разделов)
class TaskSectionListViewModel: TaskSectionListViewModelType {
    
    typealias Sections = [[TaskSectionProtocol]]
    
    
    // MARK: services
    private var sectionEm: TaskSectionEntityManager
    
    
    // MARK: model
    static var systemSectionsId = 0
    static var customSectionsId = 1
    
    private var sections: Box<Sections>
    
    private var selectedSectionIndexPath: IndexPath?
    
    
    // MARK: init / setup
    required init(
        sectionEm: TaskSectionEntityManager,
        sections: Sections
    ) {
        self.sectionEm = sectionEm
        self.sections = Box(sections)
    }
    
    
    // MARK: binding methods
    func bindAndUpdateSections(_ listener: @escaping ([[TaskSectionProtocol]]) -> Void) {
        sections.bindAndUpdateValue(listener: listener)
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
    
    func getTaskSectionTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskSectionListTableViewCellViewModelType? {
        let section = sections.value[indexPath.section][indexPath.row]
        
        switch section {
        case let taskSectionCustom as TaskSectionCustom :
            return TaskSectionCustomListTableViewCellViewModel(section: taskSectionCustom)
        
        case let taskSectionSystem as TaskSectionSystem:
            return TaskSectionSystemListTableViewCellViewModel(section: taskSectionSystem)
            
        default :
            return nil
        }
    }
    
    func selectTaskSection(forIndexPath indexPath: IndexPath) {
        self.selectedSectionIndexPath = indexPath
    }
    
    func getViewModelForSelectedRow() -> TaskSectionListTableViewCellViewModelType? {
        guard let selectedIndexPath = selectedSectionIndexPath else {
            return nil
        }
    
        return getTaskSectionTableViewCellViewModel(forIndexPath: selectedIndexPath)
    }
   
    func getTaskListInSectionViewModel(forIndexPath indexPath: IndexPath) -> TaskListInSectionViewModelType? {
        let section = sections.value[indexPath.section][indexPath.row]
        
        switch section {
        case let taskSectionCustom as TaskSectionCustom :
            let taskEm = DIContainer.shared.resolve(TaskEntityManager.self)!
            return TaskListInSectionViewModel(taskSectionCustom, taskEm: taskEm)
            
        case _ as TaskSectionSystem:
            // TODO: создать тип для системного списка (там будут другие параметры, скорей всего)
            return nil
        default :
            return nil
        }
    }
    
    func getDeletableSectionViewModelFor(indexPath: IndexPath) -> TaskSectionDeletableViewModel? {
        let section = sections.value[indexPath.section][indexPath.row]
        guard let customSection = section as? TaskSectionCustom else {
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
        sections.value[TaskSectionListViewModel.customSectionsId].insert(section, at: 0)
    }
    
    func deleteCustomSection(sectionViewModel: TaskSectionDeletableViewModel) {
        guard let indexPath = sectionViewModel.indexPath else { return }
        let section = sections.value[TaskSectionListViewModel.customSectionsId][indexPath.row]
        guard let customSection = section as? TaskSectionCustom else { return }
        
        sectionEm.deleteSection(customSection)
        sections.value[TaskSectionListViewModel.customSectionsId].remove(at: indexPath.row)
    }
    
    func archiveCustomSection(indexPath: IndexPath) {
        let section = sections.value[TaskSectionListViewModel.customSectionsId][indexPath.row]
        guard let customSection = section as? TaskSectionCustom else {
            // TODO: залогировать, что сюда попал системный раздел (список)
            return
        }
        
        sectionEm.updateCustomSectionField(isArchive: true, section: customSection)
        sections.value[TaskSectionListViewModel.customSectionsId].remove(at: indexPath.item)
    }
    
}
