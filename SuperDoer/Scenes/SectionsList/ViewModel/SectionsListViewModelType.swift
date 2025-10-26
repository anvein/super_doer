import Foundation

protocol SectionsListViewModelType {

    typealias Sections = [[TaskSectionProtocol]]

    var sectionsObservable: UIBoxObservable<Sections> { get }

    func getCountOfTableSections() -> Int
    func getCountTaskSectionsInTableSection(with listId: Int) -> Int
    func getTaskSectionTableCellVM(for indexPath: IndexPath) -> SectionListTableCellVMType?

    func loadInitialData()

    func didSelectTaskSection(with indexPath: IndexPath)
    func didTapDeleteCustomSection(with indexPath: IndexPath)
    func didTapArchiveCustomSection(indexPath: IndexPath)
    func didConfirmCreateCustomSection(title: String)
}
