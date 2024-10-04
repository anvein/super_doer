
import Foundation

// MARK: delegate protocol for update view (binding)
protocol TaskDetailViewModelBindingDelegate: AnyObject {
    func addCell(toIndexPath indexPath: IndexPath, cellViewModel: TaskDetailDataCellViewModelType)

    func updateCell(withIndexPath indexPath: IndexPath, cellViewModel: TaskDetailDataCellViewModelType)

    func removeCells(withIndexPaths indexPaths: [IndexPath])
}
