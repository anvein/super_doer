
import Foundation

/// ViewModel таблицы страницы с таблицей списков
class TaskSectionsViewModel: TaskSectionsViewModelType {
    
    // TODO: переделать на private (когда переведу на view model список задач)
     var sections: [[TaskSectionProtocol]]
    
    private var selectedSectionIndexPath: IndexPath?
    
    lazy var taskSectionEm = TaskSectionEntityManager()
    
    required init(sections: [[TaskSectionProtocol]]) {
        self.sections = sections
    }
    
    
    func getCountOfSections() -> Int {
        return sections.count
    }
    
    func getTasksCountInSection(withSectionId sectionId: Int) -> Int {
        return sections[sectionId].count
    }
    
    func getTaskSectionCellViewModel(forIndexPath indexPath: IndexPath) -> TaskSectionsTableViewCellViewModelType? {
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
