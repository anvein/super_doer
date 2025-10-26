import Foundation

protocol SectionsListViewModelType {

    typealias Sections = [[TaskSectionProtocol]]

    var sectionsObservable: UIBoxObservable<Sections> { get }

    func getCountOfTableSections() -> Int
    func getCountTaskSectionsInTableSection(with listId: Int) -> Int

    func loadInitialData()
    func didTapDeleteCustomSection(with indexPath: IndexPath)



    func getTaskSectionTableViewVM(forIndexPath indexPath: IndexPath) -> SectionListTableCellVMType?
    
    func selectTaskSection(with indexPath: IndexPath)

    func createCustomTaskSectionWith(title: String)
    
    func archiveCustomSection(indexPath: IndexPath)

}
