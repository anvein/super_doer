import Foundation

protocol TaskSectionListViewModelType {

    typealias Sections = [[TaskSectionProtocol]]

    var sectionsObservable: UIBoxObservable<Sections> { get }

    func loadInitialData()

    func getCountOfTableSections() -> Int
    func getCountTaskSectionsInTableSection(withSectionId listId: Int) -> Int

    func getTaskSectionTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> SectionListTableViewCellViewModelType?
    
    func getDeletableSectionViewModelFor(indexPath: IndexPath) -> TaskSectionDeletableViewModel?
    
    func selectTaskSection(with indexPath: IndexPath)

    func createCustomTaskSectionWith(title: String)
    
    func deleteCustomSection(sectionViewModel: TaskSectionDeletableViewModel)
    
    func archiveCustomSection(indexPath: IndexPath)
    
}
