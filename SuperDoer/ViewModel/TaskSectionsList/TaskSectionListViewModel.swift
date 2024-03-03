
import Foundation

/// ViewModel страницы с таблицей списков (разделов)
class TaskSectionListViewModel: TaskSectionListViewModelType {

    private static var systemSectionsId = 1
    private static var customSectionsId = 1
    
    var sections: Box<[[TaskSectionProtocol]]> = Box([[]])
    
    private var selectedSectionIndexPath: IndexPath?
    
    // TODO: переделать на DI
    lazy var taskSectionEm = TaskSectionEntityManager()
    
    
    required init(sections: [[TaskSectionProtocol]]) {
        self.sections.value = sections
    }
    
    
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
            return TaskListInSectionViewModel(taskSection: taskSectionCustom)

        case let _ as TaskSectionSystem:
            // TODO: создать тип для системного списка (там будут другие параметры, скорей всего)
            return nil
        default :
            return nil
        }
    }
    
    
    // MARK: model manipulate methods
    func createCustomTaskSectionWith(title: String) {
        let section = taskSectionEm.createCustomSectionWith(title: title)
        sections.value[TaskSectionListViewModel.customSectionsId].insert(section, at: 0)
    }
    
    func deleteSections(withIndexPaths indexPaths: [IndexPath]) {
        var sectionsForDelete = [TaskSectionCustom]()
        for indexPath in indexPaths {
            let section = sections.value[TaskSectionListViewModel.customSectionsId][indexPath.row]
            guard let customSection = section as? TaskSectionCustom else {
                // TODO: залогировать, что сюда попал системный раздел (список)
                return
            }
            
            sectionsForDelete.append(customSection)
            sections.value[TaskSectionListViewModel.customSectionsId].remove(at: indexPath.row)
        }
        
        // TODO: проработать кейс, когда один из разделов не удалится
        taskSectionEm.deleteSections(sectionsForDelete)
    }
    
    func archiveCustomSection(indexPath: IndexPath) {
        let section = sections.value[TaskSectionListViewModel.customSectionsId][indexPath.row]
        guard let customSection = section as? TaskSectionCustom else {
            // TODO: залогировать, что сюда попал системный раздел (список)
            return
        }
        
        taskSectionEm.updateCustomSectionField(isArchive: true, section: customSection)
        sections.value[TaskSectionListViewModel.customSectionsId].remove(at: indexPath.item)
    }
    
}
