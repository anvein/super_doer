import RxCocoa
import Foundation

protocol TaskDetailViewModelOutput: AnyObject {
    var titleDriver: Driver<String> { get }
    var isCompletedDriver: Driver<Bool> { get }
    var isPriorityDriver: Driver<Bool> { get }
    var fieldEditingStateDriver: Driver<TaskDetailViewModelFieldEditingState?> { get }
    var tableUpdateSignal: Signal<TaskDetailTableViewModel.UpdateEvent> { get }

    var countSections: Int { get }

    func getCountRowsInSection(_ sectionIndex: Int) -> Int
    func getTableCellViewModel(for indexPath: IndexPath) -> TaskDetailTableCellViewModelType?
    func canDeleteCell(with indexPath: IndexPath) -> Bool
}
