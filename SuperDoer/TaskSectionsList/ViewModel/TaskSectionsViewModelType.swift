
import Foundation

/// ViewModel страницы списков задач (разделов с задачами)
protocol TaskSectionsViewModelType {
    init(sections: [[TaskSectionProtocol]])
    
    func getCountOfTableSections() -> Int
    
    func getTaskSectionsCountInTableSection(withSectionId listId: Int) -> Int
    
    func getTaskSectionTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskSectionsTableViewCellViewModelType?
    
    func selectTaskSection(forIndexPath indexPath: IndexPath)
    
    func createCustomTaskSectionWith(title: String)
    
    func getViewModelForSelectedRow() -> TaskSectionsTableViewCellViewModelType?
    
}
