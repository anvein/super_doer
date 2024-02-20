
import Foundation

/// ViewModel страницы с таблицей списков (разделов)
class TaskSectionsListViewModel /*: TaskSectionsViewModelType*/ {
    
    var sections: Box<[[TaskSectionProtocol]]> = Box([[]])
    
    private var selectedSectionIndexPath: IndexPath?
    
    lazy var taskSectionEm = TaskSectionEntityManager()
    
    
    required init(sections: [[TaskSectionProtocol]]) {
        self.sections.value = sections
    }
    
    
    func getCountOfTableSections() -> Int {
        return sections.value.count
    }
    
    func getTaskSectionsCountInTableSection(withSectionId sectionId: Int) -> Int {
        return sections.value[sectionId].count
    }
    
//    func getTasksCountInSection(withSectionId id: Int) -> Int {
//        return Int.random(in: 0...11)
//    }
    
    func getTaskSectionTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskSectionTableViewCellViewModelType? {
        let section = sections.value[indexPath.section][indexPath.row]
        
        switch section {
        case let taskSectionCustom as TaskSectionCustom :
            return TaskSectionCustomTableViewCellViewModel(section: taskSectionCustom)
        
        case let taskSectionSystem as TaskSectionSystem:
            return TaskSectionSystemTableViewCellViewModel(section: taskSectionSystem)
            
        default :
            return nil
        }
    }
    
    func selectTaskSection(forIndexPath indexPath: IndexPath) {
        self.selectedSectionIndexPath = indexPath
    }
    
    func getViewModelForSelectedRow() -> TaskSectionTableViewCellViewModelType? {
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

        case let taskSectionSystem as TaskSectionSystem:
            // TODO: создать тип для системного списка (там будут другие параметры, скорей всего)
            return nil
        default :
            return nil
        }
    }
    
    
    // MARK: model manipulate methods
    func createCustomTaskSectionWith(title: String) {
        let section = taskSectionEm.createCustomSectionWith(title: title)
        sections.value[1].insert(section, at: 0)
    }
    
    func updateSectionTitleRandomWith(indexPath: IndexPath) {
        let title = "Section updated \(Int.random(in: 0...100))"
        let section = sections.value[indexPath.section][indexPath.item]
        
        taskSectionEm.updateCustomSectionField(title: title, section: section as! TaskSectionCustom)
        sections.forceUpdate()
    }
    
}
