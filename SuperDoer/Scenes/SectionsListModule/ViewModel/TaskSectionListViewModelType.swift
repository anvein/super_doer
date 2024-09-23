
import Foundation

/// ViewModel страницы разделов задач (списков задач)
protocol TaskSectionListViewModelType {

    func bindAndUpdateSections(_ listener: @escaping ([[TaskSectionProtocol]]) -> Void)
    
    func getCountOfTableSections() -> Int
    
    func getCountTaskSectionsInTableSection(withSectionId listId: Int) -> Int
    
    func getTaskSectionTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> SectionListTableViewCellViewModelType?
    
    func getTaskListViewModel(forIndexPath indexPath: IndexPath) -> TasksListViewModelType?
    
    func getDeletableSectionViewModelFor(indexPath: IndexPath) -> TaskSectionDeletableViewModel?
    
    func selectTaskSection(forIndexPath indexPath: IndexPath)
    
    func createCustomTaskSectionWith(title: String)
    
    func deleteCustomSection(sectionViewModel: TaskSectionDeletableViewModel)
    
    func archiveCustomSection(indexPath: IndexPath)
    
}
