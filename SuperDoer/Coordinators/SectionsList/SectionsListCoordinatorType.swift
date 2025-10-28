import Foundation
import RxCocoa

protocol SectionsListCoordinatorType: AnyObject {
    var viewModelEventSignal: Signal<SectionsListCoordinatorToVmEvent> { get }

    func startTasksInSectionFlow(_ section: TaskSectionProtocol)
    func startDeleteSectionConfirmation(_ section: CDTaskCustomSection, _ indexPath: IndexPath)
}
