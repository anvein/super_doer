import Foundation

protocol TaskListTableDataSource: AnyObject {
    func getSectionsCount() -> Int
    func getCountRowsInSection(with sectionIndex: Int) -> Int
    func getCellViewModel(for indexPath: IndexPath) -> TaskTableCellViewModelType
}
