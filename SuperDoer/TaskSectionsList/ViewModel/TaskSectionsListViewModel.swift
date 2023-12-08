
import Foundation

/// ViewModel страницы с таблицей списков (разделов)
class TaskSectionsListViewModel: TaskSectionsViewModelType {
    
    private var sections: [[TaskSectionProtocol]]
    
    private var selectedSectionIndexPath: IndexPath?
    
    lazy var taskSectionEm = TaskSectionEntityManager()
    
    required init(sections: [[TaskSectionProtocol]]) {
        self.sections = sections
    }
    
    func getCountOfTableSections() -> Int {
        return sections.count
    }
    
    func getTaskSectionsCountInTableSection(withSectionId sectionId: Int) -> Int {
        return sections[sectionId].count
    }
    
//    func getTasksCountInSection(withSectionId listId: Int) -> Int {
//        return Int.random(in: 0...11)
//    }
    
    func getTaskSectionTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskSectionsTableViewCellViewModelType? {
        let section = sections[indexPath.section][indexPath.row]
        
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
    
    func createCustomTaskSectionWith(title: String) {
        let section = taskSectionEm.createCustomSectionWith(title: title)
        sections[1].insert(section, at: 0)
    }
    
    func getViewModelForSelectedRow() -> TaskSectionsTableViewCellViewModelType? {
        guard let selectedIndexPath = selectedSectionIndexPath else {
            return nil
        }
        
        let taskSection = sections[selectedIndexPath.section][selectedIndexPath.row]
        
        switch taskSection {
        case let taskSectionCustom as TaskSectionCustom :
            return TaskSectionCustomTableViewCellViewModel(section: taskSectionCustom)
        
        case let taskSectionSystem as TaskSectionSystem:
            return TaskSectionSystemTableViewCellViewModel(section: taskSectionSystem)
            
        default :
            return nil
        }
    }
    
    
}
