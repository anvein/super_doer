import Foundation
import RxCocoa

protocol TasksListCoordinatorType: AnyObject {
    var viewModelEventSignal: Signal<TasksListCoordinatorToVmEvent> { get }

    func startTaskDetailFlow(for taskId: UUID)
    func startDeleteTasksConfirmation(for items: [(TasksListItemEntity, IndexPath)])
}
