import Foundation
import RxCocoa

protocol SectionsListCoordinatorType: AnyObject {
    func startTasksListInSystemSectionFlow()
    func startTasksListInCustomSectionFlow(with sectionId: UUID)

    func startDeleteSectionConfirmation(_ sectionVM: TaskSectionDeletableViewModel)
}
