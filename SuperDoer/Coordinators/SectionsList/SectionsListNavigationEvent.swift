import Foundation

enum SectionsListNavigationEvent {
    case openDeleteSectionConfirmation(TaskSectionDeletableViewModel)
    case openTasksListInCustomSection(id: UUID)
    case openTasksListInSystemSection
}
