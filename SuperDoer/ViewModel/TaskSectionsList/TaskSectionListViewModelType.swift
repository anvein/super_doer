
import Foundation

/// ViewModel страницы разделов задач (списков задач)
protocol TaskSectionListViewModelType {

    func bindAndUpdateSections(_ listener: @escaping ([[TaskSectionProtocol]]) -> Void)
    
    func getCountOfTableSections() -> Int
    
    func getCountTaskSectionsInTableSection(withSectionId listId: Int) -> Int
    
    func getTaskSectionTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskSectionListTableViewCellViewModelType?
    
    func getTaskListInSectionViewModel(forIndexPath indexPath: IndexPath) -> TaskListInSectionViewModelType?
    
    func selectTaskSection(forIndexPath indexPath: IndexPath)
    
    func createCustomTaskSectionWith(title: String)
    
    func deleteSections(withIndexPaths indexPaths:  [IndexPath])
    
    func archiveCustomSection(indexPath: IndexPath)
    
}
