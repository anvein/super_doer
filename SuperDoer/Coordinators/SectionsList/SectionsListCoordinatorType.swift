import Foundation
import RxCocoa

protocol SectionsListCoordinatorType: AnyObject {
    var viewModelEventSignal: Signal<SectionsListCoordinatorToVmEvent> { get }

    func startTasksListInSystemSectionFlow()
    func startTasksListInCustomSectionFlow(with sectionId: UUID)

    func startDeleteSectionConfirmation(_ section: CDTaskCustomSection, _ indexPath: IndexPath)
}
