import Foundation

enum TaskDetailTableUpdateEvent {
    case addCell(to: IndexPath, cellVM: TaskDetailDataCellViewModelType)
    case updateCell(with: IndexPath, cellVM: TaskDetailDataCellViewModelType)
    case removeCells(with: [IndexPath])

    // move cell
}
