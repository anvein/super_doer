
import Foundation

/// 
protocol TaskSectionsViewModelType {
    init(sections: [[TaskSectionProtocol]])
    
    func getCountOfSections() -> Int
    
    func getTasksCountInSection(withSectionId listId: Int) -> Int
    
    func getTaskSectionCellViewModel(forIndexPath indexPath: IndexPath) -> TaskSectionsTableViewCellViewModelType?
    
    func selectTaskSection(forIndexPath indexPath: IndexPath)
    
    func createCustomTaskSectionWith(title: String)
    
    func getViewModelForSelectedRow() -> TaskSectionsTableViewCellViewModelType?
    
}
