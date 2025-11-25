import Foundation
import RxCocoa
import OrderedCollections

protocol SectionsListViewModelInout {
    var didUpdatedData: Signal<OrderedDictionary<SectionsListGroupViewModel, [TaskSectionCellViewModel]>> { get }

    func loadInitialData()

    func didTapOpenTasksListInSection(with indexPath: IndexPath)
    func didTapDeleteCustomSection(with indexPath: IndexPath)
    func didTapArchiveCustomSection(with indexPath: IndexPath)
    func didConfirmCreateCustomSection(title: String)
}
